//
//  RequestDataVC.swift
//  Zygo
//
//  Created by Som on 03/04/22.
//  Copyright © 2022 Somparkash. All rights reserved.
//

import UIKit

//MARK: -
class RequestDataVC: UIViewController {
    
    @IBOutlet weak var btnRequestData: UIButton!
    @IBOutlet weak var txtLog: UITextView!
    @IBOutlet weak var txtHIDData: UITextView!
    
    @IBOutlet weak var txtNumberOfTimes: UITextField!
    @IBOutlet weak var txtInterval: UITextField!
    
    var workoutItem: WorkoutDTO?
    
    var numberOfTimes: Int = 1
    var afterNumberOfMilliSeconds: Double = 1000
    
    var numberOfPlay: Int = 0
    var numberOfPause: Int = 0
    
    var log: String = ""
    
    //MARK: - UIViewcontroller LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AudioPlayerManager.shared.setupMediaPlayerNotificationView()
        
        self.btnRequestData.layer.cornerRadius = 5.0
        self.btnRequestData.layer.masksToBounds = true
        
        self.setupWorkoutPlayer()
    }
    
    //MARK: - Setups
    func setupWorkoutPlayer(){
        log = ""
        self.txtLog.text = log
        self.txtHIDData.text = ""
        self.numberOfTimes = 1
        self.txtNumberOfTimes.text = "1"
        self.afterNumberOfMilliSeconds = 1000
        self.txtInterval.text = "1000"
        self.numberOfPlay = 0
        self.numberOfPause = 0
        
        AudioPlayerManager.shared.onLoaded = {
            
            DispatchQueue.main.async {
                self.btnRequestData.isUserInteractionEnabled = true
                self.btnRequestData.alpha = 1.0
            }
        }
        
        AudioPlayerManager.shared.onPlay = {
            DispatchQueue.main.async {
                self.numberOfPlay += 1
                
                self.log += "Play         \(Date().toFormat(format: "HH:mm:ss.SSS"))\n"
                self.txtLog.text = self.log
                self.perform(#selector(self.pause), with: nil, afterDelay: self.afterNumberOfMilliSeconds/1000.0)
            }
        }
        
        AudioPlayerManager.shared.onPause = {
            DispatchQueue.main.async {
                self.numberOfPause += 1
                self.log += "Pause       \(Date().toFormat(format: "HH:mm:ss.SSS"))\n"
                self.txtLog.text = self.log
                if self.numberOfPause >= self.numberOfTimes{
                    return
                }
                
                self.perform(#selector(self.play), with: nil, afterDelay: self.afterNumberOfMilliSeconds/1000.0)
            }
        }
        
        self.btnRequestData.isUserInteractionEnabled = false
        self.btnRequestData.alpha = 0.5
        
        let name = workoutItem?.workoutName ?? "Zygo Workout"
        let item = PlayerAudioItem(songName: name, albumName: "Zygo", artistName: "Zygo", fileURL: URL(string: workoutItem?.audioURL ?? ""), songImage: URL(string: workoutItem?.thumbnailURL ?? ""))
        AudioPlayerManager.shared.setupPlayer(item: item)
        
    }
    
    //MARK: - UIButton Actions
    @IBAction func backAction(){
        AudioPlayerManager.shared.stopPlayer()
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func requestDataAction(){
        self.numberOfPlay = 0
        self.numberOfPause = 0
        self.txtLog.text = ""
        self.log = ""
        self.numberOfTimes = Int(self.txtNumberOfTimes.text!) ?? 1
        self.afterNumberOfMilliSeconds = Double(self.txtInterval.text!) ?? 1000
        
        self.play()
        self.txtHIDData.becomeFirstResponder()
    }
    
    @IBAction func resetAction(){
        self.setupWorkoutPlayer()
    }

    @objc func play(){
        AudioPlayerManager.shared.playPlayer()
    }
    
    @objc func pause(){
        AudioPlayerManager.shared.pausePlayer()
    }
    
    
    //MARK: -

    
}
