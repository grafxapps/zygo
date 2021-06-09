//
//  WorkoutPlayerViewController.swift
//  Zygo
//
//  Created by Som on 06/02/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit
import AVKit

//MARK: -
class WorkoutPlayerViewController: UIViewController, FeedbackSheetViewControllerDelegates {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblInstructorName: UILabel!
    @IBOutlet weak var lblLevel: UILabel!
    @IBOutlet weak var levelView: UIView!
    @IBOutlet weak var lblCurrentTime: UILabel!
    @IBOutlet weak var lblEndTime: UILabel!
    @IBOutlet weak var instructorImageView: UICircleImageView!
    @IBOutlet weak var txtDescription: UITextView!
    @IBOutlet weak var workoutImage: UIImageView!
    @IBOutlet weak var seekBar: UISlider!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var endWorkout: UIButton!
    
    @IBOutlet weak var playerLoader: UIActivityIndicatorView!
    
    @IBOutlet weak var descriptionHeightConstrait: NSLayoutConstraint!
    @IBOutlet weak var introViewBottomConstrait: NSLayoutConstraint!
    
    var workoutItem: WorkoutDTO!
    var localWorkout: Workout?
    
    private var playerItem: AVPlayerItem?
    private var player: AVPlayer?
    private var playerCurrentTime: CMTime = CMTime.zero
    private var playerEndTime: CMTime = CMTime.zero
    private var playerStatus: PlayerStatus = .notStarted
    private var isSkipShow: Bool = false
    
    private var statusObservation: NSKeyValueObservation?
    private var timeObserverToken: Any?
    
    private let viewModel = WorkoutPlayerViewModel()
    
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupDetailInfo(workoutItem)
    }
    
    //MARK: - Setup
    func setupUI(){
        
        txtDescription.textContainerInset = UIEdgeInsets.zero
        
        txtDescription.textContainer.lineBreakMode = .byWordWrapping
        seekBar.setThumbImage(UIImage(named: "icon_thumb"), for: .normal)
        seekBar.setThumbImage(UIImage(named: "icon_thumb"), for: .highlighted)
        
        endWorkout.alpha = 0.5
        endWorkout.layer.borderWidth = 2.0
        endWorkout.layer.borderColor = UIColor.appTitleDarkColor().cgColor
        endWorkout.layer.cornerRadius = 5.0
        endWorkout.layer.masksToBounds = true
        self.setupContentSize()
    }
    
    func setupContentSize(){
        
        if workoutItem.workoutDescription.isDescriptionEmpty(){
            descriptionHeightConstrait.constant = 0.0
            return
        }
        
        let screenWidth = ScreenSize.SCREEN_WIDTH
        let screenHeight = ScreenSize.SCREEN_HEIGHT
        let endBtnHeight: CGFloat = 5 + 55 + 10
        let playBtnHeight: CGFloat = 60 + 5
        let sliderHeight: CGFloat = 35 + 20
        let imageHeight: CGFloat = ((screenWidth - 40.0)/2.4) + 20//1:2.4
        
        let topHeaderHeight: CGFloat = 60.0 + UIApplication.statuBarFrame().height + UIApplication.BottomSpace()
        let topImageHeight: CGFloat = 100.0// minimum
        let instructorHeight: CGFloat = 55
        
        let descriptionHeigt: CGFloat = workoutItem.workoutDescription.size(withMaxWidth: (screenWidth - 40.0), maxheight: .greatestFiniteMagnitude, font: txtDescription.font!).height
        
        //workoutItem.workoutDescription.height(withConstrainedWidth: (screenWidth - 40.0), font: txtDescription.font!)
        let bottomRequiredHeight = endBtnHeight + playBtnHeight + sliderHeight + imageHeight
        let topRequiredheight = topHeaderHeight + topImageHeight + instructorHeight
        
        let requirdHeight = bottomRequiredHeight + topRequiredheight
        let pendingHeight = abs(screenHeight - requirdHeight)
        if descriptionHeigt > pendingHeight{
            descriptionHeightConstrait.constant = pendingHeight
        }else{
            descriptionHeightConstrait.constant = descriptionHeigt
        }
    }
    
    func setupDetailInfo(_ item: WorkoutDTO){
        
        self.lblTitle.text = "\("\(String(format: "%.f", item.workoutDuration)) min") \(item.workoutName)"
        self.lblInstructorName.text = "\(item.instructor.instructorFirstName) \(item.instructor.instructorLastName)"
        
        self.instructorImageView.image = UIImage(named: "icon_default")
        if !item.instructor.instructorPic.isEmpty{
            self.instructorImageView.sd_setImage(with: URL(string: item.instructor.instructorPic.getImageURL()), placeholderImage: UIImage(named: "icon_default"), options: .refreshCached, completed: nil)
            
        }
        
        self.workoutImage.image = nil
        self.workoutImage.backgroundColor = .white
        if !item.thumbnailURL.isEmpty{
            self.workoutImage.sd_setImage(with: URL(string: item.thumbnailURL.getImageURL()), placeholderImage: nil, options: .refreshCached, completed: nil)
        }
        
        if item.difficultyLevel.title.lowercased() == "all levels"{
            self.lblLevel.text = ""
            self.levelView.isHidden = true
        }else{
            self.lblLevel.text = item.difficultyLevel.title
            self.levelView.isHidden = false
        }
        
        let newDescription = item.workoutDescription.htmlToAttributedString
        newDescription?.addAttribute(.foregroundColor, value: self.txtDescription.textColor!, range: NSRange(location: 0, length: newDescription?.string.count ?? 0))
        self.txtDescription.attributedText = newDescription
        
        guard var url = URL(string: item.audioURL.getImageURL()) else{
            return
        }
        
        if localWorkout != nil{
            url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            url.appendPathComponent("DownloadedAudios/\(localWorkout!.workoutIdentifier).mp3")
        }
        
        self.setupAudioPlayer(url)
    }
    
    func setupAudioPlayer(_ mURL: URL){
        
        self.showPlayerLoader()
        
        DispatchQueue.global(qos: .default).async {
            let asset = AVAsset(url: mURL)
            
            self.playerItem = AVPlayerItem(asset: asset)
            self.player = AVPlayer(playerItem: self.playerItem!)
            self.player?.automaticallyWaitsToMinimizeStalling = false
            DispatchQueue.main.async {
                
                
                self.seekBar.minimumValue = 0
                self.seekBar.maximumValue = Float(asset.duration.seconds)
                
                self.lblCurrentTime.text = Double(0).toMS()
                self.lblEndTime.text = Double(asset.duration.seconds).toMS()
                self.playerCurrentTime = CMTime(seconds: 0, preferredTimescale: asset.duration.timescale)
                self.playerEndTime = asset.duration
                
                self.addObservers()
            }
            
        }
        
    }
    
    func stopAndRemovePlayer(){
        self.removePeriodicTimeObserver()
        
        self.player?.pause()
        self.player = nil
        
        self.playerItem = nil
    }
    
    func updateCurrentTime(time: Double){
        let timeScale = self.playerCurrentTime.timescale
        self.playerCurrentTime = CMTime(seconds: time, preferredTimescale: timeScale)
        self.seekBar.value = Float(time)
        self.lblCurrentTime.text = Double(time).toMS()
        self.updateSkipIntroView()
        
    }
    
    func pausePlayer(){
        self.player?.pause()
        self.btnPlay.isSelected = false
        self.playerStatus = .paused
    }
    
    @objc func playPlayer(){
        self.player?.play()
        self.btnPlay.isSelected = true
        self.playerStatus = .running
    }
    
    func showPlayerLoader(){
        playerLoader.startAnimating()
        playerLoader.isHidden = false
        self.btnPlay.isHidden = true
    }
    
    func hidePlayerLoader(){
        self.playerLoader.stopAnimating()
        self.playerLoader.isHidden = true
        self.btnPlay.isHidden = false
    }
    
    func isWorkoutHalfCompleted() -> Bool{
        let cTime = self.playerCurrentTime.seconds
        let eTime = self.playerEndTime.seconds
        if cTime > (eTime/2.0){
            return true
        }
        
        return false
    }
    
    func completeWorkout(){
        var timeInWater: Int = -1
        if workoutItem.isInWater{
            timeInWater = Int(self.playerCurrentTime.seconds) - workoutItem.workoutStartsAt
            if timeInWater < 0{
                timeInWater = 0
            }
        }
        
        var timeElapsed = Int(self.playerCurrentTime.seconds) - workoutItem.workoutStartsAt
        if timeElapsed < 0{
            timeElapsed = 0
        }
        
        self.pausePlayer()
        
        self.viewModel.completeWorkout(workoutItem.workoutId, timeInWater, timeElapsed) { (isCompleted) in
            if isCompleted{
                print("Workout completed successfully!!")
                
                let feedbackVC = FeedbackSheetViewController(nibName: "FeedbackSheetViewController", bundle: nil, workoutItem: self.workoutItem, achievements: self.viewModel.arrAchievements)
                feedbackVC.delegate = self
                feedbackVC.modalPresentationStyle = .overFullScreen
                self.present(feedbackVC, animated: true, completion: nil)
            }
        }
    }
    
    func feedbackDone() {
        self.removeObservers()
        self.stopAndRemovePlayer()
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    //MARK: - Observers
    func addObservers(){
        self.removeObservers()
        
        self.statusObservation = playerItem?.observe(\AVPlayerItem.status) {
            [unowned self] object, change in
            NSLog("playerItem status change \(object.status.rawValue)")
            if object.status == .readyToPlay {
                self.hidePlayerLoader()
                self.playPlayer()
                self.player?.currentItem?.outputs.first?.suppressesPlayerRendering = true;
                self.player?.volume = 1.0
            }
        }
        
        
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(handleInterruption),
                       name: AVAudioSession.interruptionNotification,
                       object: nil)
        
        
        nc.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem, queue: .main) { [weak self] _ in
            self?.player?.seek(to: CMTime.zero)
            self?.pausePlayer()
            self?.completeWorkout()
        }
        
        self.addPeriodicTimeObserver()
    }
    
    func removeObservers(){
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        self.removePeriodicTimeObserver()
        NotificationCenter.default.removeObserver(self)
        self.statusObservation = nil
    }
    
    func addPeriodicTimeObserver() {
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.1, preferredTimescale: timeScale)
        
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: time,
                                                            queue: .main) {
            [weak self] time in
            //If pleayer reacg end then start again
            let playerTime = self?.player?.currentTime().seconds ?? 0
            self?.updateCurrentTime(time: playerTime)
        }
    }
    
    func removePeriodicTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            player?.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    
    
    //MARK: - NSNotification Actions
    @objc func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        switch type {
        case .began:
            print("interruption began")
        case .ended:
            print("interruption ended")
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                if self.btnPlay.isSelected{//If player was already playing then need to play
                    self.playPlayer()
                }
            } else {
                self.pausePlayer()
            }
            
        default: ()
        }
    }
    
    //MARK: - UIButton Actions
    @IBAction func backAction(_ sender: UIButton){
        
        if playerStatus != .notStarted{
            
            if self.isWorkoutHalfCompleted(){
                Helper.shared.alertYesNoActions(title: nil, message: "End workout without logging it?", yesActionTitle: "Yes", noActionTitle: "No") { (isYes) in
                    if isYes{
                        //self.back()
                        self.removeObservers()
                        self.stopAndRemovePlayer()
                        self.navigationController?.popToRootViewController(animated: true)
                        //self.completeWorkout()
                    }
                }
            }else{
                self.back()
            }
        }else{
            self.back()
        }
    }
    
    func back(){
        self.removeObservers()
        self.stopAndRemovePlayer()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func playPauseAction(_ sender: UIButton){
        if self.btnPlay.isSelected{
            self.pausePlayer()
        }else{
            self.playPlayer()
        }
    }
    
    @IBAction func seekBarValueChangeAction(_ sender: UISlider){
        self.pausePlayer()
        self.updateCurrentTime(time: Double(seekBar.value))
        self.player?.seek(to: self.playerCurrentTime)
    }
    
    @IBAction func seekBarValueChangeEnd(_ sender: UISlider){
        self.updateCurrentTime(time: Double(seekBar.value))
        self.player?.seek(to: self.playerCurrentTime)
        self.playPlayer()
    }
    
    @IBAction func endWorkoutAction(_ sender: UIButton){
        if self.isWorkoutHalfCompleted(){
            self.completeWorkout()
        }else{
            Helper.shared.alertYesNoActions(title: nil, message: "Are you sure you want to end this workout?", yesActionTitle: "Yes", noActionTitle: "No") { (isYes) in
                if isYes{
                    //self.completeWorkout()
                    self.back()
                }
            }
        }
    }
    
    @IBAction func skipIntroAction(){
        self.pausePlayer()
        self.updateCurrentTime(time: Double(workoutItem.workoutStartsAt + 1))//Add one second more for hide skip view
        self.player?.seek(to: self.playerCurrentTime)
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        self.perform(#selector(self.playPlayer), with: nil, afterDelay: 1)//Play after one second delay as per documentation
    }
}

//MARK: - Skip Intro
extension WorkoutPlayerViewController{
    
    func updateSkipIntroView(){
        
        //If audio total time is less than workouStartAt time then hide skip intro view
        if Int(self.playerEndTime.seconds) <= workoutItem.workoutStartsAt{
            if self.isSkipShow{
                self.hideSkipIntro()
            }
            return
        }
        
        //If current player time is zero then no need to show the skip view
        if Int(self.playerCurrentTime.seconds) <= 0{
            if self.isSkipShow{
                self.hideSkipIntro()
            }
            return
        }
        
        if Int(self.playerCurrentTime.seconds) < workoutItem.workoutStartsAt{
            if !self.isSkipShow{
                self.showSkipIntro()
            }
        }else{
            if self.isSkipShow{
                self.hideSkipIntro()
            }
        }
    }
    
    func showSkipIntro(){
        self.isSkipShow = true
        UIView.animate(withDuration: 0.4) {
            self.introViewBottomConstrait.constant = 5
            self.view.layoutIfNeeded()
        }
    }
    
    func hideSkipIntro(){
        self.isSkipShow = false
        UIView.animate(withDuration: 0.4) {
            self.introViewBottomConstrait.constant = -45
            self.view.layoutIfNeeded()
        }
    }
}

enum PlayerStatus {
    case running
    case notStarted
    case paused
}
