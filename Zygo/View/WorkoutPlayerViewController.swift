//
//  WorkoutPlayerViewController.swift
//  Zygo
//
//  Created by Som on 06/02/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit
import AVKit
import SimpleAnimation
import SideMenuSwift

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
    @IBOutlet weak var videoSeekBar: UISlider!
    
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var btnVideoPlayBig: UIButton!
    @IBOutlet weak var btnVideoPlaySmall: UIButton!
    
    @IBOutlet weak var endWorkout: UIButton!
    
    @IBOutlet weak var playerLoader: UIActivityIndicatorView!
    
    @IBOutlet weak var descriptionHeightConstrait: NSLayoutConstraint!
    @IBOutlet weak var introViewBottomConstrait: NSLayoutConstraint!
    @IBOutlet weak var videoControlsBottomConstrait: NSLayoutConstraint!
    @IBOutlet weak var videoControlsCenterConstrait: NSLayoutConstraint!
    
    @IBOutlet weak var videoPlayerFullScreenView: UIView!
    @IBOutlet weak var videoPlayerContentView: UIView!
    @IBOutlet weak var videoPlayerView: UIView!
    @IBOutlet weak var videoControlsView: UIView!
    @IBOutlet weak var skipVideo: UIView!
    
    @IBOutlet weak var audioControlsView: UIView!
    @IBOutlet weak var audioContentView: UIView!
    
    var workoutItem: WorkoutDTO!
    var localWorkout: Workout?
    
    private var playerItem: AVPlayerItem?
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var playerCurrentTime: CMTime = CMTime.zero
    private var playerEndTime: CMTime = CMTime.zero
    private var playerStatus: PlayerStatus = .notStarted
    private var isSkipShow: Bool = false
    
    private var statusObservation: NSKeyValueObservation?
    private var timeObserverToken: Any?
    
    private let viewModel = WorkoutPlayerViewModel()
    private let videoPlayerRatio: CGFloat = 1.772
    private var isClosingVideo: Bool = false
    
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        if AppDelegate.app.tempoPlayer == nil{
            Helper.shared.resetDemoModeTime()
        }
        
        self.setupUI()
        self.setupDetailInfo(workoutItem)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        
        if !item.introVideo.isEmpty{
            
            guard let url = URL(string: item.introVideo.getImageURL()) else{
                return
            }
            self.setupVideoPlayer(url)
            
            
        }else if !item.audioURL.isEmpty{
            
            //Hide Video content and controls view
            self.videoPlayerContentView.isHidden = true
            self.videoControlsView.isHidden = true
            
            guard var url = URL(string: item.audioURL.getImageURL()) else{
                return
            }
            
            if localWorkout != nil{
                url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                url.appendPathComponent("DownloadedAudios/\(localWorkout!.workoutIdentifier).mp3")
            }
            
            self.setupAudioPlayer(url)
        }else if !item.closingVideo.isEmpty{
            
            guard let url = URL(string: item.closingVideo.getImageURL()) else{
                return
            }
            self.isClosingVideo = true
            self.setupVideoPlayer(url)
            
        }
    }
    
    func setupVideoPlayer(_ mURL: URL){
        
        self.showPlayerLoader()
        self.removeObservers()
        DispatchQueue.global(qos: .default).async {
            let asset = AVAsset(url: mURL)
            
            self.playerItem = AVPlayerItem(asset: asset)
            self.player = AVPlayer(playerItem: self.playerItem!)
            self.player?.automaticallyWaitsToMinimizeStalling = false
            DispatchQueue.main.async {
                self.playerLayer = AVPlayerLayer(player: self.player!)
                self.playerLayer?.frame = CGRect(x: 0, y: 0, width: (ScreenSize.SCREEN_WIDTH - 40.0), height: (ScreenSize.SCREEN_WIDTH - 40.0)/self.videoPlayerRatio)
                self.playerLayer?.cornerRadius = 10.0
                self.playerLayer?.masksToBounds = true
                self.playerLayer?.videoGravity = .resizeAspectFill
                self.videoSeekBar.minimumValue = 0
                self.videoSeekBar.maximumValue = Float(asset.duration.seconds)
                
                self.lblCurrentTime.text = Double(0).toMS()
                self.lblEndTime.text = Double(asset.duration.seconds).toMS()
                self.playerCurrentTime = CMTime(seconds: 0, preferredTimescale: asset.duration.timescale)
                self.playerEndTime = asset.duration
                self.videoPlayerView.layer.addSublayer(self.playerLayer!)
                self.addObservers()
            }
            
        }
        
    }
    
    func setupAudioPlayer(_ mURL: URL){
        
        self.showPlayerLoader()
        self.removeObservers()
        
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
        if isVideo{
            self.videoSeekBar.value = Float(time)
        }else{
            self.seekBar.value = Float(time)
            self.updateSkipIntroView()
        }
        
        self.lblCurrentTime.text = Double(time).toMS()
    }
    
    func pausePlayer(){
        self.player?.pause()
        if isVideo{
            self.btnVideoPlaySmall.isSelected = false
        }else{
            Helper.shared.stopDemoTime()
            self.btnPlay.isSelected = false
        }
        
        self.playerStatus = .paused
    }
    
    @objc func playPlayer(){
        
        if !Helper.shared.isTestUser{
            if UIScreen.main.isCaptured {
                Helper.shared.alert(title: Constants.appName, message: "Please stop screen recording to play this workout.")
                return
            }
        }
        
        self.player?.play()
        if isVideo{
            self.btnVideoPlaySmall.isSelected = true
            self.btnVideoPlayBig.isHidden = true
        }else{
            
            if Helper.shared.isDemoLimitComplete(){
                
                Helper.shared.stopTempoTrainerOnController()
                
                let alert = CustomAlertWithCloseVC(nibName: "CustomAlertWithCloseVC", bundle: nil, title: Constants.appName, message: "Start your free trial to access all of our content.", buttonTitle: "Subscribe") { (isYes) in
                    if isYes{
                        //Push To Subscribe screen
                        Helper.shared.pushToSubscriptionScreen(from: self)
                    }else{
                        Helper.shared.log(event: .WORKOUTCANCEL, params: [:])
                        self.back()
                    }
                }
                
                alert.transitioningDelegate = self
                alert.modalPresentationStyle = .custom
                self.present(alert, animated: true, completion: nil)
                
                self.stopAndRemovePlayer()
                return
            }
            Helper.shared.startDemoTime()
            self.btnPlay.isSelected = true
        }
        
        self.playerStatus = .running
    }
    
    var isVideo: Bool{
        return self.playerLayer != nil
    }
    
    func showPlayerLoader(){
        playerLoader.startAnimating()
        playerLoader.isHidden = false
        self.btnPlay.isHidden = true
    }
    
    func hidePlayerLoader(){
        self.playerLoader.stopAnimating()
        self.playerLoader.isHidden = true
        if isVideo{
            self.btnVideoPlayBig.isHidden = false
        }else{
            self.btnPlay.isHidden = false
        }
        
    }
    
    func isWorkoutHalfCompleted() -> Bool{
        
        if self.isVideo && !self.isClosingVideo{
            if !self.workoutItem.audioURL.isEmpty{//Audio Workout is there
                return false
            }
        }
        
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
        
        
        if Helper.shared.isDemoMode{
            Helper.shared.stopTempoTrainerOnController()
            let alert = CustomAlertWithCloseVC(nibName: "CustomAlertWithCloseVC", bundle: nil, title: Constants.appName, message: "Start your free trial to access all of our content.", buttonTitle: "Subscribe") { (isYes) in
                if isYes{
                    //Push To Subscribe screen
                    Helper.shared.pushToSubscriptionScreen(from: self)
                }else{
                    Helper.shared.log(event: .WORKOUTCANCEL, params: [:])
                    self.back()
                }
            }
            
            alert.transitioningDelegate = self
            alert.modalPresentationStyle = .custom
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        self.viewModel.completeWorkout(workoutItem.workoutId, timeInWater, timeElapsed) { (isCompleted, workoutLogId) in
            Helper.shared.log(event: .ENDWORKOUT, params: [:])
            if isCompleted{
                print("Workout completed successfully!!")
                
                let currentTempo = TempoTrainerManager.shared.currentTrainer
                if currentTempo != nil{
                    //Reset Tempo Trainer
                    TempoTrainerManager.shared.startTime = DateHelper.shared.currentLocalDateTime
                }
                
                let feedbackVC = FeedbackSheetViewController(nibName: "FeedbackSheetViewController", bundle: nil, workoutItem: self.workoutItem, achievements: self.viewModel.arrAchievements, workoutLogId: workoutLogId, timeElapsed: timeElapsed)
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
    
    func showAudioContent(completion: @escaping () -> Void){
        self.audioControlsView.isHidden = false
        self.audioControlsView.alpha = 0
        
        self.audioContentView.isHidden = false
        self.audioContentView.alpha = 0
        
        UIView.animate(withDuration: 1.0) {
            self.audioControlsView.alpha = 1
            self.audioContentView.alpha = 1
        } completion: { (complete) in
            completion()
        }
        
    }
    
    func hideAudioContent(completion: @escaping () -> Void){
        
        UIView.animate(withDuration: 1.0) {
            self.audioControlsView.alpha = 0
            self.audioContentView.alpha = 0
        } completion: { (complete) in
            self.audioContentView.isHidden = true
            self.audioControlsView.isHidden = true
            completion()
        }
    }
    
    func showVideoContent(completion: @escaping () -> Void){
        self.videoControlsView.isHidden = false
        self.videoControlsView.alpha = 0
        
        self.videoPlayerContentView.isHidden = false
        self.videoPlayerContentView.alpha = 0
        
        UIView.animate(withDuration: 1.0) {
            self.videoControlsView.alpha = 1
            self.videoPlayerContentView.alpha = 1
        } completion: { (complete) in
            completion()
        }
        
    }
    
    func hideVideoContent(completion: @escaping () -> Void){
        
        UIView.animate(withDuration: 1.0) {
            self.videoPlayerContentView.alpha = 0
            self.videoControlsView.alpha = 0
            self.skipVideo.alpha = 0
        } completion: { (complete) in
            self.videoPlayerContentView.isHidden = true
            self.videoControlsView.isHidden = true
            self.skipVideo.isHidden = true
            completion()
        }
    }
    
    //MARK: - Observers
    func addObservers(){
        //self.removeObservers()
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerStalled), name: .AVPlayerItemPlaybackStalled, object: playerItem)
        
        self.statusObservation = playerItem?.observe(\AVPlayerItem.status) {
            [unowned self] object, change in
            NSLog("playerItem status change \(object.status.rawValue)")
            if object.status == .readyToPlay {
                self.hidePlayerLoader()
                
                if !isVideo{
                    self.showAudioContent(){
                        
                    }
                    self.playPlayer()
                }else if self.isClosingVideo{
                    self.skipVideo.isHidden = true
                    self.showVideoContent {
                        
                    }
                    self.videoPlayAction(UIButton())
                }else{//Video
                    
                    self.showVideoContent {
                        if !self.workoutItem.audioURL.isEmpty || !self.workoutItem.closingVideo.isEmpty{
                            self.skipVideo.isHidden = false
                            self.skipVideo.slideIn(from: .bottom)
                        }
                    }
                    
                    //if self.playerStatus == .running{
                    self.videoPlayAction(UIButton())
                    //}
                }
                
                self.player?.currentItem?.outputs.first?.suppressesPlayerRendering = true;
                self.player?.volume = 1.0
            }else if object.status == .failed{
                Helper.shared.alert(title: Constants.appName, message: "Failed to load media. Please try again."){
                    Helper.shared.log(event: .WORKOUTCANCEL, params: [:])
                    self.back()
                }
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
            if self?.isVideo ?? true{
                
                //Check for audio if available then show audio player other wise check for end video if availabe then play it. else complete workout
                
                self?.playerLayer?.removeFromSuperlayer()
                self?.playerLayer = nil
                
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                
                if self?.isClosingVideo ?? false{
                    self?.completeWorkout()
                }else{
                    if !(self?.workoutItem.audioURL.isEmpty ?? true){
                        
                        //Hide Video Content view and controls
                        self?.hideVideoContent {
                            self?.videoSeekBar.value = 0
                            self?.seekBar.value = 0
                            
                            guard var url = URL(string: self?.workoutItem.audioURL.getImageURL() ?? "") else{
                                self?.completeWorkout()
                                return
                            }
                            
                            if self!.localWorkout != nil{
                                url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                                url.appendPathComponent("DownloadedAudios/\(self!.localWorkout!.workoutIdentifier).mp3")
                            }
                            
                            self?.setupAudioPlayer(url)
                        }
                        
                    }else if !(self?.workoutItem.closingVideo.isEmpty ?? true){
                        
                        self?.isClosingVideo = true
                        self?.hideVideoContent {
                            guard let url = URL(string: self?.workoutItem.closingVideo.getImageURL() ?? "") else{
                                self?.completeWorkout()
                                return
                            }
                            
                            self?.setupVideoPlayer(url)
                        }
                        
                    }else{
                        self?.completeWorkout()
                    }
                }
            }else{//Audio complete
                if !(self?.workoutItem.closingVideo.isEmpty ?? true){
                    self?.isClosingVideo = true
                    //Show Video Content view and controls
                    self?.hideAudioContent {
                        guard let url = URL(string: self?.workoutItem.closingVideo.getImageURL() ?? "") else{
                            self?.completeWorkout()
                            return
                        }
                        
                        self?.setupVideoPlayer(url)
                    }
                }else{
                    self?.completeWorkout()
                }
            }
        }
        
        self.addPeriodicTimeObserver()
    }
    
    @objc func playerStalled() {
        if playerStatus == .running{
            self.player?.play()
        }
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
            if !(self?.isVideo ?? false){
                if Helper.shared.isDemoLimitComplete(){
                    self?.stopAndRemovePlayer()
                    Helper.shared.stopTempoTrainerOnController()
                    let alert = CustomAlertWithCloseVC(nibName: "CustomAlertWithCloseVC", bundle: nil, title: Constants.appName, message: "Start your free trial to access all of our content.", buttonTitle: "Subscribe") { (isYes) in
                        if isYes{
                            //Push To Subscribe screen
                            Helper.shared.pushToSubscriptionScreen(from: self!)
                        }else{
                            self?.back()
                        }
                    }
                    
                    alert.transitioningDelegate = self
                    alert.modalPresentationStyle = .custom
                    self?.present(alert, animated: true, completion: nil)
                    return
                }
            }
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
            Helper.shared.stopLoading()
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
                        Helper.shared.log(event: .WORKOUTCANCEL, params: [:])
                        //self.completeWorkout()
                    }
                }
            }else{
                Helper.shared.log(event: .WORKOUTCANCEL, params: [:])
                self.back()
            }
        }else{
            Helper.shared.log(event: .WORKOUTCANCEL, params: [:])
            self.back()
        }
    }
    
    func back(){
        self.removeObservers()
        self.stopAndRemovePlayer()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func videoPlayAction(_ sender: UIButton){
        UIView.animate(withDuration: 0.4) {
            self.btnVideoPlayBig.alpha = 0.0
        } completion: { (isComplete) in
            if isComplete{
                self.btnVideoPlayBig.isHidden = true
            }
        }
        
        //self.videoControlsView.isHidden = false
        //self.videoControlsView.slideIn(from: .bottom)
        
        self.playPlayer()
    }
    
    @IBAction func videoPlayPauseAction(_ sender: UIButton){
        if self.btnVideoPlaySmall.isSelected{
            self.pausePlayer()
        }else{
            self.playPlayer()
        }
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
        if isVideo{
            self.updateCurrentTime(time: Double(videoSeekBar.value))
        }else{
            self.updateCurrentTime(time: Double(seekBar.value))
        }
        
        self.player?.seek(to: self.playerCurrentTime)
    }
    
    @IBAction func seekBarValueChangeEnd(_ sender: UISlider){
        if isVideo{
            self.updateCurrentTime(time: Double(videoSeekBar.value))
        }else{
            self.updateCurrentTime(time: Double(seekBar.value))
            let timeScale = self.playerCurrentTime.timescale
            let tempplayerCurrentTime = CMTime(seconds: Double(seekBar.value), preferredTimescale: timeScale)
            
            Helper.shared.demoTotalSeconds = Int(tempplayerCurrentTime.seconds)
            Helper.shared.startDemoTime()
        }
        
        self.player?.seek(to: self.playerCurrentTime)
        
        
        
        self.playPlayer()
    }
    
    @IBAction func endWorkoutAction(_ sender: UIButton){
        if self.isClosingVideo{
            self.completeWorkout()
        }else{
            if self.isWorkoutHalfCompleted(){
                self.completeWorkout()
            }else{
                Helper.shared.alertYesNoActions(title: nil, message: "Are you sure you want to end this workout?", yesActionTitle: "Yes", noActionTitle: "No") { (isYes) in
                    if isYes{
                        //self.completeWorkout()
                        Helper.shared.log(event: .WORKOUTCANCEL, params: [:])
                        self.back()
                    }
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
    
    @IBAction func skipVideoAction(){
        
        self.playerLayer?.removeFromSuperlayer()
        self.playerLayer = nil
        
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        
        if !(self.workoutItem.audioURL.isEmpty){
            
            //Hide Video Content view and controls
            self.hideVideoContent {
                guard var url = URL(string: self.workoutItem.audioURL.getImageURL()) else{
                    self.completeWorkout()
                    return
                }
                
                if self.localWorkout != nil{
                    url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    url.appendPathComponent("DownloadedAudios/\(self.localWorkout!.workoutIdentifier).mp3")
                }
                
                self.setupAudioPlayer(url)
            }
        }else if !(self.workoutItem.closingVideo.isEmpty){
            
            self.isClosingVideo = true
            
            self.hideVideoContent {
                guard let url = URL(string: self.workoutItem.closingVideo.getImageURL()) else{
                    self.completeWorkout()
                    return
                }
                
                self.setupVideoPlayer(url)
            }
        }else{
            self.completeWorkout()
        }
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        if (UIDevice.current.orientation.isLandscape) {
            
            DispatchQueue.main.async {
                self.videoControlsView.translatesAutoresizingMaskIntoConstraints = false
                if self.playerLayer != nil{
                    self.playerLayer?.removeFromSuperlayer()
                    self.videoPlayerFullScreenView.isHidden = false
                    self.playerLayer?.frame = self.view.frame
                    self.playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
                    self.videoPlayerFullScreenView.layer.addSublayer(self.playerLayer!)
                    
                    self.videoControlsBottomConstrait.priority = .defaultLow
                    self.videoControlsCenterConstrait.priority = .defaultHigh
                    
                    self.view.layoutIfNeeded()
                    self.view.bringSubviewToFront(self.videoControlsView)
                }
                
            }
            print("Device is landscape")
        }else{
            
            self.videoPlayerFullScreenView.isHidden = true
            self.videoControlsView.translatesAutoresizingMaskIntoConstraints = false
            if self.playerLayer != nil{
                let contentHeight = (ScreenSize.SCREEN_WIDTH - 40.0)/self.videoPlayerRatio
                self.playerLayer?.removeFromSuperlayer()
                self.playerLayer?.frame = CGRect(x: 0, y: 0, width: (ScreenSize.SCREEN_WIDTH - 40.0), height: contentHeight)
                self.videoPlayerView.layer.addSublayer(self.playerLayer!)
            }
            
            self.videoControlsBottomConstrait.priority = .defaultHigh
            self.videoControlsCenterConstrait.priority = .defaultLow
            self.view.layoutIfNeeded()
            self.view.bringSubviewToFront(self.videoControlsView)
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
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

extension WorkoutPlayerViewController: UIViewControllerTransitioningDelegate{
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentingAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissingAnimator()
    }
    
}



enum PlayerStatus {
    case running
    case notStarted
    case paused
}
