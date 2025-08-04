//
//  AudioPlayerManager.swift
//  Zygo

import UIKit
import AVKit
import MediaPlayer
import SDWebImage

let commandCenter = MPRemoteCommandCenter.shared()

final class AudioPlayerManager: NSObject {
    
    static let shared = AudioPlayerManager()
    
    var player: AVPlayer?
    //var playerItem: AVPlayerItem?
    private var nowPlayingInfo: [String: Any] = [:]
    var currentInfoItem: PlayerAudioItem?
    var arrAVPlayerItemAssetss: [AVURLAsset] = []
    
    var currentIndex: Int = -1
    private var songImageView: UIImageView = UIImageView()
    private var timeObserverToken: Any!
    var observer: NSKeyValueObservation?
    
    var isSeekBar = false
    private var isPlayerStopped: Bool = false
    var isCancelLoading: Bool = false
    
    var onPause: (() -> Void)?
    var onPlay: (() -> Void)?
    var onLoading: (() -> Void)?
    var onLoaded: (() -> Void)?
    var onFinish: (() -> Void)?
    var onError: ((String) -> Void)?
    var onNext: (() -> Void)?
    var onBack: (() -> Void)?
    
    private override init() {
    }
    
    //MARK: - Player
    func setupPlayer(item: PlayerAudioItem) {
        self.isSeekBar = false
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
        
        self.onLoading?()
        DispatchQueue.global().async { [self] in
            
            self.currentIndex = 0
            self.currentInfoItem = item
            
            if let url = self.currentInfoItem?.fileURL {
                
                self.onLoading?()
                let asset = AVURLAsset(url: url)
                asset.loadValuesAsynchronously(forKeys: ["playable"]) {
                    
                    var error: NSError? = nil
                    let status = asset.statusOfValue(forKey: "playable", error: &error)
                    switch status{
                    case .loaded:
                        print("loaded")
                        self.onLoaded?()
                        
                        let avitem = AVPlayerItem(asset: asset)
                        self.player = AVPlayer(playerItem: avitem)
                        self.player?.automaticallyWaitsToMinimizeStalling = false
                        self.addPeriodicTimeObserver()
                        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
                        //player?.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
                        self.addObserveValue()
                        DispatchQueue.main.async {
                            self.setupMediaPlayerControl()
                            self.setupNotificationView()
                            print("Is Player Cancel: \(self.isCancelLoading)")
                            if self.isCancelLoading{
                                self.isCancelLoading = false
                                self.onLoaded?()
                                return
                            }
                            DispatchQueue.global(qos: .background).async {
                                //self.play()
                            }
                        }
                        
                    case .loading:
                        print("loading")
                    case .failed:
                        if let err = error{
                            let msg = err.localizedDescription
                            self.onError?(msg)
                            return
                        }
                        
                        self.onError?("Failed to load.")
                        print("failed")
                    case .cancelled:
                        print("cancelled")
                    case .unknown:
                        print("unknown")
                    @unknown default:
                        print("unknown")
                    }
                }
            }
        }
    }
    
    func stopPlayer(){
        
        isPlayerStopped = true
        
        self.pausePlayer()
    
        if player?.currentItem != nil {
            self.removeObservers()
            player?.replaceCurrentItem(with: nil)
            //player = nil
        }
        
    }
    
    func setPlayerEnabled(){
        isPlayerStopped = false
    }
    
    func removeCompletionHandlers(){
        AudioPlayerManager.shared.onPlay = nil
        AudioPlayerManager.shared.onPause = nil
        AudioPlayerManager.shared.onLoading = nil
        AudioPlayerManager.shared.onLoaded = nil
        AudioPlayerManager.shared.onFinish = nil
        AudioPlayerManager.shared.onError = nil
    }
    
    func removeObservers() {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        self.observer?.invalidate()
        self.observer = nil
        //player?.removeObserver(self, forKeyPath: "timeControlStatus")
        self.removePeriodicTimeObserver()
        NotificationCenter.default.removeObserver(self)
    }
    
    func removePeriodicTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            player?.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func addPeriodicTimeObserver() {
        
        let time = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        //let time = CMTimeMakeWithSeconds(1, preferredTimescale: 1)
        self.timeObserverToken = player?.addPeriodicTimeObserver(forInterval: time, queue: DispatchQueue.main) { (CMTime) -> Void in
            if self.player?.currentItem?.status == .readyToPlay {
                let playerTime : Float64 = self.player?.currentTime().seconds ?? 0
                var uDict:[String: Any] = [:]
                uDict["playerValue"] = playerTime
                uDict["playerIndex"] = NSNumber(value: self.currentIndex)
                if self.isSeekBar {
                    //self.isSeekBar = false
                }else {
                    NotificationCenter.default.post(name: Notification.Name("updateSeekBar"), object: nil, userInfo: uDict)
                }
            }
        }
    }
    
    fileprivate func play() {
        if isPlayerStopped{
            return
        }
        player?.play()
    }
    
    fileprivate func pause() {
        player?.pause()
    }
    
    fileprivate func next() {
        print("nextTrackCommand")
        DispatchQueue.main.async {
            self.onNext?()
        }
    }
    
    fileprivate func previous() {
        if self.currentIndex > 0 {
            print("previousTrackCommand")
            DispatchQueue.main.async {
                self.onBack?()
            }
        }
    }
    
    @objc func playerDidFinishPlaying() {
        DispatchQueue.main.async {
            self.onFinish?()
        }
    }
    
    //MARK: - Media Control
    
    private func setupNotificationView() {
        //nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = self.currentInfoItem?.songName
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = self.currentInfoItem?.albumName
        nowPlayingInfo[MPMediaItemPropertyArtist] = self.currentInfoItem?.artistName
        
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player?.currentItem?.asset.duration.seconds ?? 0//Current song duration
        
        if let url = self.currentInfoItem?.songImage {
            
            self.songImageView.sd_setImage(with: url, placeholderImage: nil, options: .refreshCached) { (image, error, type, url) in
                if image != nil{
                    self.nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: CGSize(width: 300.0, height: 300.0), requestHandler: { (size) -> UIImage in
                        return image!
                    })
                    MPNowPlayingInfoCenter.default().nowPlayingInfo = self.nowPlayingInfo
                }
            }
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    private func setupMediaPlayerControl() {
        commandCenter.nextTrackCommand.isEnabled = false
        commandCenter.previousTrackCommand.isEnabled = false
    }
    
    func setupMediaPlayerNotificationView() {
        commandCenter.nextTrackCommand.removeTarget(self)
        commandCenter.previousTrackCommand.removeTarget(self)
        commandCenter.pauseCommand.removeTarget(self)
        commandCenter.playCommand.removeTarget(self)
        commandCenter.changePlaybackPositionCommand.removeTarget(self)
        
        let commands = [commandCenter.playCommand, commandCenter.pauseCommand, commandCenter.nextTrackCommand, commandCenter.previousTrackCommand, commandCenter.bookmarkCommand, commandCenter.changePlaybackPositionCommand, commandCenter.changePlaybackRateCommand, commandCenter.dislikeCommand, commandCenter.enableLanguageOptionCommand, commandCenter.likeCommand, commandCenter.ratingCommand, commandCenter.seekBackwardCommand, commandCenter.seekForwardCommand, commandCenter.skipBackwardCommand, commandCenter.skipForwardCommand, commandCenter.stopCommand, commandCenter.togglePlayPauseCommand]
        
        
        for cmd in commands{
            cmd.removeTarget(self)
            cmd.isEnabled = false
        }
        
        commandCenter.nextTrackCommand.isEnabled = false
        commandCenter.previousTrackCommand.isEnabled = false
        
        commandCenter.playCommand.addTarget { [unowned self] remoteEvent in
            self.play()
            return .success
        }
        commandCenter.pauseCommand.addTarget { [unowned self] remoteEvent in
            self.pause()
            return .success
        }
        commandCenter.changePlaybackPositionCommand.addTarget{ remoteEvent in
            if let event = remoteEvent as? MPChangePlaybackPositionCommandEvent {
                self.player?.seek(to: CMTime(seconds: event.positionTime, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), completionHandler: { (success) in
                    //guard let self = self else {return}
                    //if success {
                    //player.rate = playerRate
                    //}
                })
                return .success
            }
            return .success
        }
        commandCenter.previousTrackCommand.addTarget { [unowned self] remoteEvent in
            self.previous()
            return .success
        }
        commandCenter.nextTrackCommand.addTarget { [unowned self] remoteEvent in
            self.next()
            return .success
        }
    }
    
    func addObserveValue(){
        if self.observer != nil{
            self.observer?.invalidate()
            self.observer = nil
        }
        
        self.observer = player?.observe(\.timeControlStatus, options: [.old, .new]) { [weak self] tplayer, change in
            switch self?.player?.timeControlStatus {
            case .paused:
                self?.nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(self?.player?.currentTime() ?? CMTime.zero)
                self?.nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 0
                MPNowPlayingInfoCenter.default().nowPlayingInfo = self?.nowPlayingInfo
                print("paused")
                DispatchQueue.main.async {
                    AudioPlayerManager.shared.isCancelLoading = false
                    self?.onPause?()
                }
            case .waitingToPlayAtSpecifiedRate:
                // nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(player?.currentTime() ?? CMTime.zero)
                self?.nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 0
                MPNowPlayingInfoCenter.default().nowPlayingInfo = self?.nowPlayingInfo
                print("waiting")
                DispatchQueue.main.async {
                    //self.onLoading?()
                }
                
            case .playing:
                print("Now Playing")
                DispatchQueue.main.async {
                    if self?.isCancelLoading ?? false{
                        self?.isCancelLoading = false
                        self?.pausePlayer()
                        return
                    }
                }
                
                self?.nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(self?.player?.currentTime() ?? CMTime.zero)
                self?.nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1
                MPNowPlayingInfoCenter.default().nowPlayingInfo = self?.nowPlayingInfo
                DispatchQueue.main.async {
                    self?.onPlay?()
                }
            case .none:
                print("None")
            @unknown default:
                print("unknown")
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        
        if keyPath != "timeControlStatus"{
            return
        }
        
        if object is AVPlayer {
            switch player?.timeControlStatus {
            case .paused:
                nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(player?.currentTime() ?? CMTime.zero)
                nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 0
                MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
                print("paused")
                DispatchQueue.main.async {
                    //AudioPlayerManager.shared.isCancelLoading = false
                    self.onPause?()
                }
            case .waitingToPlayAtSpecifiedRate:
                // nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(player?.currentTime() ?? CMTime.zero)
                nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 0
                MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
                print("waiting")
                DispatchQueue.main.async {
                    //self.onLoading?()
                }
                
            case .playing:
                print("Now Playing")
                DispatchQueue.main.async {
                    if self.isCancelLoading{
                        self.isCancelLoading = false
                        self.pausePlayer()
                        return
                    }
                }
                
                self.nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(player?.currentTime() ?? CMTime.zero)
                self.nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1
                MPNowPlayingInfoCenter.default().nowPlayingInfo = self.nowPlayingInfo
                DispatchQueue.main.async {
                    self.onPlay?()
                }
            case .none:
                print("None")
            @unknown default:
                print("unknown")
            }
        }
    }
    
    func seeked(duration: Double) {
        
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(player?.currentTime() ?? CMTime.zero)
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        
        let time = CMTime(seconds: duration, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player?.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero ){ isCompleted in
            if isCompleted {
                self.isSeekBar = false
            }else {
                self.isSeekBar = true
            }
            self.nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(self.player?.currentTime() ?? CMTime.zero)
            self.nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1
            MPNowPlayingInfoCenter.default().nowPlayingInfo = self.nowPlayingInfo
        }
    }
    
    func pausePlayer() {
        self.pause()
        
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(player?.currentTime() ?? CMTime.zero)
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    func playPlayer() {
        self.isSeekBar = false
        self.play()
        self.nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(player?.currentTime() ?? CMTime.zero)
        self.nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1
        MPNowPlayingInfoCenter.default().nowPlayingInfo = self.nowPlayingInfo
    }
    
    @objc func changePlaybackPositionCommand(_ event: MPChangePlaybackPositionCommandEvent) -> MPRemoteCommandHandlerStatus {
        _ = event.positionTime
        //use time to update your track time
        return MPRemoteCommandHandlerStatus.success
    }
}

struct PlayerAudioItem {
    
    var songName: String = ""
    var albumName: String = ""
    var artistName: String = ""
    var fileURL: URL?
    var songImage: URL?
}
