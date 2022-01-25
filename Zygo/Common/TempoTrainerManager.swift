//
//  TempoTrainerManager.swift
//  Zygo
//
//  Created by Som on 17/02/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit
import AVFoundation

final class TempoTrainerManager: NSObject {

    var currentTrainer: TemoTrainer?
    
    static let shared = TempoTrainerManager()
    var strokeTimer: DispatchSourceTimer?
    var demoTimer: DispatchSourceTimer?
    var demoCompletion: (() -> Void)?

    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    private override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(reinstateBackgroundTask), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    deinit {
      NotificationCenter.default.removeObserver(self)
    }
    
    func startPlaySound(for trainer: TemoTrainer){
        
        self.currentTrainer = trainer
        PreferenceManager.shared.tempoTrainer = trainer
        
        let type = trainer.soundType
        
        guard let soundURL = self.getSoundFile(type) else{
            Helper.shared.alert(title: Constants.appName, message: "This sound isn't available at the moment.")
            return
        }
        
        self.setupPlayer(with: soundURL)
        
        switch trainer.type {
        case .strokeRate:
            let strokeInterval = Double(60)/Double(trainer.strokesPerMinute)
            self.startTimer(TimeInterval(strokeInterval))
        case .lapInterval:
            let secondsInterval = trainer.secondsPerLap
            self.startTimer(TimeInterval(secondsInterval))
        }
        
    }
    
    func playSound(for type: SoundType){
        
        guard let soundURL = self.getSoundFile(type) else{
            Helper.shared.alert(title: Constants.appName, message: "This sound isn't available at the moment.")
            return
        }
        
        self.setupPlayer(with: soundURL)
        AppDelegate.app.tempoPlayer?.play()
    }
    
    func stopTrainer(){
        self.stopStrokeTimer()
        AppDelegate.app.tempoPlayer?.pause()
        AppDelegate.app.tempoPlayer = nil
        self.currentTrainer = nil
    }
    
    private func startTimer(_ interval: TimeInterval){
        self.stopStrokeTimer()
        AppDelegate.app.tempoPlayer?.play()
        
        let queue = DispatchQueue(label: "com.zygo.ios.timer", attributes: .concurrent)

        strokeTimer = DispatchSource.makeTimerSource(queue: queue)
        strokeTimer?.schedule(deadline: .now(), repeating: interval, leeway: .milliseconds(100))
        
        strokeTimer?.setEventHandler { // `[weak self]` only needed if you reference `self` in this closure and you want to prevent strong reference cycle
            DispatchQueue.main.async {
                AppDelegate.app.tempoPlayer?.pause()
                AppDelegate.app.tempoPlayer?.currentTime = 0
                AppDelegate.app.tempoPlayer?.play()
            }
        }
        
        strokeTimer?.resume()
        
        if Helper.shared.isDemoMode{
            let demoQueue = DispatchQueue(label: "com.zygo.ios.timer.demo", attributes: .concurrent)
            demoTimer = DispatchSource.makeTimerSource(queue: demoQueue)
            demoTimer?.schedule(deadline: .now(), repeating: 1, leeway: .milliseconds(100))
            
            demoTimer?.setEventHandler { // `[weak self]` only needed if you reference `self` in this closure and you want to prevent strong reference cycle
                DispatchQueue.main.async {
                    if Helper.shared.isDemoLimitComplete(){
                        self.demoCompletion?()
                        return
                    }
                }
            }
            
            demoTimer?.resume()
        }
        
        /*strokeTimer = Timer(timeInterval: interval, repeats: true, block: { (timerObj) in
            AppDelegate.app.tempoPlayer?.pause()
            AppDelegate.app.tempoPlayer?.currentTime = 0
            AppDelegate.app.tempoPlayer?.play()
        })*/
        
        self.registerBackgroundTask()
        
        //RunLoop.current.add(strokeTimer!, forMode: .common)
    }
    
    private func stopStrokeTimer(){
        //strokeTimer?.invalidate()
        strokeTimer = nil
        demoTimer = nil
        
        if backgroundTask != .invalid {
          endBackgroundTask()
        }
    }
    
    private func playSound(_ type: SoundType){
        
        guard let soundURL = self.getSoundFile(type) else{
            Helper.shared.alert(title: Constants.appName, message: "This sound isn't available at the moment.")
            return
        }
        
        self.setupPlayer(with: soundURL)
    }
    
    
    private func setupPlayer(with url: URL){
        do{
            try AppDelegate.app.tempoPlayer = AVAudioPlayer(contentsOf: url)
            AppDelegate.app.tempoPlayer?.volume = 1.0
            AppDelegate.app.tempoPlayer?.numberOfLoops = 0
            AppDelegate.app.tempoPlayer?.prepareToPlay()
        }catch{
            print("Unable to setup Temp Audio Player")
        }
        
    }
    
    func getSoundDuration(_ type: SoundType) -> Double{
        
        guard let soundURL = self.getSoundFile(type) else{
            return -1
        }
        let asset = AVAsset(url: soundURL)
        return asset.duration.seconds
    }
    
    func getSoundFile(_ type: SoundType) -> URL?{
        
        var resourceName: String = ""
        switch type {
        case .beep:
            resourceName = "sound_beep"
        case .ding:
            resourceName = "sound_ding"
        case .drop:
            resourceName = "sound_drop"
        }
        
        return Bundle.main.url(forResource: resourceName, withExtension: "wav")
        
    }
    
    
    func registerBackgroundTask() {
      backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
        self?.endBackgroundTask()
      }
      assert(backgroundTask != .invalid)
    }
    
    func endBackgroundTask() {
      print("Background task ended.")
      UIApplication.shared.endBackgroundTask(backgroundTask)
      backgroundTask = .invalid
    }
    
    @objc func reinstateBackgroundTask() {
      if strokeTimer != nil && backgroundTask == .invalid {
        registerBackgroundTask()
      }
    }
    
    struct TemoTrainer {
        
        var type: TempoTrainerType = .strokeRate
        var soundType: SoundType = .drop
        var strokesPerMinute: Int = 0
        var secondsPerLap: Int = 0
        
        init(_ dict: [String: Any]) {
            self.type = TempoTrainerType(rawValue: (dict["type"] as? String ?? "")) ?? .strokeRate
            self.soundType = SoundType(rawValue: (dict["soundType"] as? String ?? "")) ?? .drop
            self.strokesPerMinute = dict["strokesPerMinute"] as? Int ?? 0
            self.secondsPerLap = dict["secondsPerLap"] as? Int ?? 0
        }
        
        func toDict() -> [String: Any]{
            return [
                "type" : self.type.rawValue,
                "soundType": self.soundType.rawValue,
                "strokesPerMinute": self.strokesPerMinute,
                "secondsPerLap": self.secondsPerLap
            ]
            
        }
    }
}

enum TempoTrainerType: String{
    case strokeRate = "strokeRate"
    case lapInterval = "lapInterval"
}

enum SoundType: String{
    case drop = "drop"
    case ding = "ding"
    case beep = "beep"
}
