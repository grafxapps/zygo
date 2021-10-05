//
//  InstructorViewController.swift
//  Zygo
//
//  Created by Som on 28/06/21.
//  Copyright © 2021 Somparkash. All rights reserved.
//

import UIKit
import AVKit
import SDWebImage

//MARK: -
class InstructorViewController: UIViewController {
    
    @IBOutlet weak var tblInstructor: UITableView!
    @IBOutlet weak var tblInstructorHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tblInstructorTopWithVideoConstraint: NSLayoutConstraint!
    @IBOutlet weak var tblInstructorTopWithInfoConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var btnInsta: UIButton!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var btnVideoPlaySmall: UIButton!
    @IBOutlet weak var btnVideoPlaybig: UIButton!
    @IBOutlet weak var playerLoader: UIActivityIndicatorView!
    @IBOutlet weak var seekBar: UISlider!
    @IBOutlet weak var videoControlsView: UIView!
    @IBOutlet weak var videoPlayerView: UIView!
    @IBOutlet weak var videoPlayerContentView: UIView!
    @IBOutlet weak var videoPlayerFullScreenView: UIView!
    
    @IBOutlet weak var videoThumbnailImageView: UIImageView!
    @IBOutlet weak var videoBigThumbnailImageView: UIImageView!
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerBGView: UIView!
    
    @IBOutlet weak var videoControlsBottomConstrait: NSLayoutConstraint!
    @IBOutlet weak var videoControlsCenterConstrait: NSLayoutConstraint!
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    
    let viewModel = InstructorViewModel()
    
    private var playerLayer: AVPlayerLayer!
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var statusObservation: NSKeyValueObservation?
    private var timeObserverToken: Any?
    private var playerCurrentTime: CMTime = CMTime.zero
    private var playerStatus: PlayerStatus = .notStarted
    private let videoPlayerRatio: CGFloat = 1.772
    
    //MARK: - UIViewController LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.videoThumbnailImageView.layer.cornerRadius = 10.0
        self.videoThumbnailImageView.layer.masksToBounds = true
        self.videoThumbnailImageView.isHidden = true
        self.videoBigThumbnailImageView.isHidden = true
        
        if self.viewModel.instructor.instructorVideo.isEmpty{
            self.viewModel.arrInstuctorSections = [.workoutTitle, .workouts]
            self.tblInstructorTopWithInfoConstraint.priority = .defaultHigh
            self.tblInstructorTopWithVideoConstraint.priority = .defaultLow
            self.videoPlayerContentView.isHidden = true
        }else{
            self.videoPlayerContentView.isHidden = false
            self.viewModel.arrInstuctorSections = [.workoutTitle, .workouts]
            if URL(string: self.viewModel.instructor.instructorVideo) != nil{
                //Show thumbnail
                if !self.viewModel.instructor.instructorVideoThumbnail.isEmpty{
                    self.videoThumbnailImageView.isHidden = false
                    self.videoThumbnailImageView.sd_setImage(with: URL(string: self.viewModel.instructor.instructorVideoThumbnail), placeholderImage: nil, options: .progressiveLoad, completed: nil)
                    
                    self.videoBigThumbnailImageView.sd_setImage(with: URL(string: self.viewModel.instructor.instructorVideoThumbnail), placeholderImage: nil, options: .progressiveLoad, completed: nil)
                }
            }
        }
        
        self.setupInfo(self.viewModel.instructor)
        
        self.registerCustomCells()
        self.viewModel.getInstructorDetail {
            
            self.setupInfo(self.viewModel.instructor)
            self.tblInstructor.reloadData()
            self.updateContentSize()
            
            if self.viewModel.instructor.instructorVideo.isEmpty{
                self.videoPlayerContentView.isHidden = true
                self.viewModel.arrInstuctorSections = [.workoutTitle, .workouts]
                self.tblInstructorTopWithInfoConstraint.priority = .defaultHigh
                self.tblInstructorTopWithVideoConstraint.priority = .defaultLow
            }else{
                self.videoPlayerContentView.isHidden = false
                self.viewModel.arrInstuctorSections = [.workoutTitle, .workouts]
                if let url = URL(string: self.viewModel.instructor.instructorVideo){
                    self.setupPlayer(url)
                    self.tblInstructorTopWithInfoConstraint.priority = .defaultLow
                    self.tblInstructorTopWithVideoConstraint.priority = .defaultHigh
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateContentSize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIDevice.current.setValue(NSNumber(value: UIDeviceOrientation.portrait.rawValue), forKey: "orientation")
    }
    
    //MARK: - Setups
    @objc func updateContentSize(){
        
        let rowHeight = Helper.shared.getWorkoutCellHeight() + 18.0
        let totalHeight = rowHeight * CGFloat(self.viewModel.arrWorkouts.count)
        self.tblInstructorHeightConstraint.constant = totalHeight + 44.0 //self.tblInstructor.contentSize.height
        self.view.layoutIfNeeded()
        self.mainScrollView.layoutIfNeeded()
    }
    
    func setupInfo(_ item: WorkoutInstructorDTO){
        self.lblName.text = "\(item.instructorFirstName) \(item.instructorLastName)"
        
        let newDescription = item.instructorBio.htmlToAttributedString
        newDescription?.addAttribute(.foregroundColor, value: self.lblDescription.textColor!, range: NSRange(location: 0, length: newDescription?.string.count ?? 0))
        newDescription?.addAttribute(.font, value: UIFont.appRegular(with: 13.0), range: NSRange(location: 0, length: newDescription?.string.count ?? 0))
        
        self.lblDescription.attributedText = newDescription
        
        self.profileImageView.image = UIImage(named: "icon_default")
        if !item.instructorPic.isEmpty{
            self.profileImageView.sd_setImage(with: URL(string: item.instructorPic.getImageURL()), placeholderImage: UIImage(named: "icon_default"), options: .refreshCached, completed: nil)
        }
        
        self.btnInsta.isHidden = false
        if item.socialMedia.isEmpty{
            self.btnInsta.isHidden = true
        }
    }
    
    func registerCustomCells(){
        self.tblInstructor.register(UINib(nibName: InstructorProfileTVC.identifier, bundle: nil), forCellReuseIdentifier: InstructorProfileTVC.identifier)
        self.tblInstructor.register(UINib(nibName: InstructorVideoTVC.identifier, bundle: nil), forCellReuseIdentifier: InstructorVideoTVC.identifier)
        self.tblInstructor.register(UINib(nibName: WorkoutInfoTVC.identifier, bundle: nil), forCellReuseIdentifier: WorkoutInfoTVC.identifier)
        self.tblInstructor.register(UINib(nibName: InstructorWorkoutTitleTVC.identifier, bundle: nil), forCellReuseIdentifier: InstructorWorkoutTitleTVC.identifier)
        
        self.tblInstructor.separatorStyle = .none
    }
    
    @objc func setupPlayer(_ mURL: URL){
        
        self.showPlayerLoader()
        self.removeObservers()
        DispatchQueue.global(qos: .default).async {
            let asset = AVAsset(url: mURL)
            
            self.playerItem = AVPlayerItem(asset: asset)
            self.player = AVPlayer(playerItem: self.playerItem!)
            self.player?.automaticallyWaitsToMinimizeStalling = false
            DispatchQueue.main.async {
                self.playerLayer = AVPlayerLayer(player: self.player!)
                self.playerLayer.cornerRadius = 10.0
                self.playerLayer.masksToBounds = true
                self.playerLayer?.frame = CGRect(x: 0, y: 0, width: (ScreenSize.SCREEN_WIDTH - 40.0), height: (ScreenSize.SCREEN_WIDTH - 40.0)/self.videoPlayerRatio)
                self.playerLayer?.videoGravity = .resizeAspectFill
                self.seekBar.minimumValue = 0
                self.seekBar.maximumValue = Float(asset.duration.seconds)
                
                self.playerCurrentTime = CMTime(seconds: 0, preferredTimescale: asset.duration.timescale)
                self.videoPlayerView.layer.addSublayer(self.playerLayer!)
                self.addObservers()
            }
            
        }
        
    }
    
    func addObservers(){
        //self.removeObservers()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerStalled), name: .AVPlayerItemPlaybackStalled, object: playerItem)
        
        self.statusObservation = playerItem?.observe(\AVPlayerItem.status) {
            [unowned self] object, change in
            NSLog("playerItem status change \(object.status.rawValue)")
            if object.status == .readyToPlay {
                self.hidePlayerLoader()
                if self.playerStatus == .running{
                    self.playPlayer()
                }
                
                self.player?.currentItem?.outputs.first?.suppressesPlayerRendering = true;
                self.player?.volume = 1.0
            }else if object.status == .failed{
                
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
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
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
    
    
    @objc func playerStalled() {
        if playerStatus == .running{
            self.player?.play()
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
                if self.btnVideoPlaySmall.isSelected{//If player was already playing then need to play
                    self.playPlayer()
                }
            } else {
                self.pausePlayer()
            }
            
        default: ()
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
    }
    
    func pausePlayer(){
        self.player?.pause()
        self.btnVideoPlaySmall.isSelected = false
        self.playerStatus = .paused
    }
    
    @objc func playPlayer(){
        self.player?.play()
        self.btnVideoPlaySmall.isSelected = true
        self.playerStatus = .running
    }
    
    func showPlayerLoader(){
        playerLoader.startAnimating()
        playerLoader.isHidden = false
        self.btnVideoPlaybig.isHidden = true
    }
    
    func hidePlayerLoader(){
        self.playerLoader.stopAnimating()
        self.playerLoader.isHidden = true
        self.btnVideoPlaybig.isHidden = false
    }
    
    //MARK: - UIButton Actions
    @objc @IBAction func instaAction(_ sender: UIButton){
        if !self.viewModel.instructor.socialMedia.isEmpty{
            Helper.shared.openUrl(url: URL(string: self.viewModel.instructor.socialMedia))
        }
    }
    
    @IBAction func videoPlayAction(_ sender: UIButton){
        UIView.animate(withDuration: 0.4) {
            self.btnVideoPlaybig.alpha = 0.0
            self.videoThumbnailImageView.alpha = 0.0
            self.videoBigThumbnailImageView.alpha = 0.0
        } completion: { (isComplete) in
            if isComplete{
                self.btnVideoPlaybig.isHidden = true
                self.videoThumbnailImageView.isHidden = true
                self.videoBigThumbnailImageView.isHidden = true
            }
        }
        
        self.videoControlsView.isHidden = false
        self.videoControlsView.slideIn(from: .bottom)
        self.playPlayer()
    }
    
    @IBAction func videoPlayPauseAction(_ sender: UIButton){
        if self.btnVideoPlaySmall.isSelected{
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
    
    @IBAction func backAction(_ sender: UIButton){
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: -
}

//MARK: - UITableView Datasources and Delegates
extension InstructorViewController: UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.arrInstuctorSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.viewModel.arrInstuctorSections[section] == .workouts{
            return self.viewModel.arrWorkouts.count
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.viewModel.arrInstuctorSections[indexPath.section]
        if item == .profile{
            let cell = tableView.dequeueReusableCell(withIdentifier: InstructorProfileTVC.identifier) as! InstructorProfileTVC
            cell.setupInfo(self.viewModel.instructor)
            cell.btnInsta.addTarget(self, action: #selector(self.instaAction(_:)), for: .touchUpInside)
            cell.selectionStyle = .none
            return cell
        }else if item == .video{
            let cell = tableView.dequeueReusableCell(withIdentifier: InstructorVideoTVC.identifier) as! InstructorVideoTVC
            
            if self.playerLayer != nil{
                let eLayer = cell.videoContentView.subviews.first?.layer.sublayers?.first as? AVPlayerLayer
                
                if eLayer == nil{
                    self.playerLayer?.frame = cell.videoContentView.bounds
                    //CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH, height: ScreenSize.SCREEN_HEIGHT)
                    cell.videoContentView.layer.addSublayer(self.playerLayer!)
                }else{
                    eLayer?.frame = cell.videoContentView.bounds
                }
            }
            
            cell.selectionStyle = .none
            return cell
        }else if item == .workoutTitle{
            let cell = tableView.dequeueReusableCell(withIdentifier: InstructorWorkoutTitleTVC.identifier) as! InstructorWorkoutTitleTVC
            let last = self.viewModel.instructor.instructorFirstName.last?.lowercased()
            if last == "s"{
                cell.lblTitle.text = "\(self.viewModel.instructor.instructorFirstName)‘ Workouts"
            }else{
                cell.lblTitle.text = "\(self.viewModel.instructor.instructorFirstName)'s Workouts"
            }
            
            cell.selectionStyle = .none
            return cell
        }else if item == .workouts{
            let cell : WorkoutInfoTVC = tableView.dequeueReusableCell(withIdentifier: WorkoutInfoTVC.identifier) as! WorkoutInfoTVC
            cell.selectionStyle = .none
            let item = self.viewModel.arrWorkouts[indexPath.row]
            cell.setupWorkoutInfo(item: item)
            return cell
        }else{
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = self.viewModel.arrInstuctorSections[indexPath.section]
        if item == .workouts{
            let workoutItem = self.viewModel.arrWorkouts[indexPath.row]
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let playerVC = storyboard.instantiateViewController(withIdentifier: "WorkoutDetailViewController") as! WorkoutDetailViewController
            playerVC.workoutItem = workoutItem
            playerVC.isFromInstructor = true
            playerVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(playerVC, animated: true)
            tableView.deselectRow(at: indexPath, animated: true)
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
                    self.view.bringSubviewToFront(self.videoPlayerFullScreenView)
                    self.view.bringSubviewToFront(self.videoControlsView)
                    
                    if self.playerStatus == .notStarted{
                        if URL(string: self.viewModel.instructor.instructorVideo) != nil{
                            //Show thumbnail
                            if !self.viewModel.instructor.instructorVideoThumbnail.isEmpty{
                                self.videoBigThumbnailImageView.isHidden = false
                                self.view.bringSubviewToFront(self.videoBigThumbnailImageView)
                            }
                        }
                    }
                }
                
            }
            print("Device is landscape")
        }else{
            self.videoBigThumbnailImageView.isHidden = true
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
            self.view.bringSubviewToFront(self.headerBGView)
            self.view.bringSubviewToFront(self.headerView)
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    /* override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
     return .all
     }*/
    
}
