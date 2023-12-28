//
//  WalkieTalkieVC.swift
//  Zygo
//
//  Created by Som Parkash on 24/11/23.
//  Copyright © 2023 Somparkash. All rights reserved.
//

import UIKit

//MARK: -
class WalkieTalkieVC: UIViewController {
    
    @IBOutlet weak var ttsOuterContentView: UIView!
    @IBOutlet weak var ttsInnerContentView: UIView!
    
    @IBOutlet weak var connectZygoView: UIView!
    @IBOutlet weak var subscriptionView: UIView!
    
    @IBOutlet weak var btnSubscription: UIButton!
    @IBOutlet weak var lblConnectZygo: UILabel!
    
    private var audioController: AudioController = AudioController()
    private var scanningTimer: Timer?
    
    //MARK: - UIViewcontroller LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addObservers()
        self.loadUIWithSubscription()
        self.setupUI()
    }
    
    
    //MARK: - Setups
    func addObservers(){
        self.removeObservers()
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    func removeObservers(){
        NotificationCenter.default.removeObserver(self)
    }
     
    @objc func applicationDidBecomeActive(){
        self.loadUIWithSubscription()
    }
    
    func setupUI(){
        ttsOuterContentView.layer.cornerRadius = (ScreenSize.SCREEN_WIDTH - 100.0)/2.0
        ttsOuterContentView.clipsToBounds = true
        
        ttsInnerContentView.layer.cornerRadius = (ScreenSize.SCREEN_WIDTH - 110.0)/2.0
        ttsInnerContentView.clipsToBounds = true
        
        connectZygoView.layer.cornerRadius = (ScreenSize.SCREEN_WIDTH - 110.0)/2.0
        connectZygoView.clipsToBounds = true
        
        btnSubscription.layer.cornerRadius = 10
        btnSubscription.clipsToBounds = true
        
    }
    
    func showTapToEndView(){
        self.ttsInnerContentView.isHidden = false
        self.ttsInnerContentView.alpha = 0.0
        UIView.animate(withDuration: 0.3) {
            self.ttsInnerContentView.alpha = 1.0
        }
    }
    
    func hideTapToEndView(){
        UIView.animate(withDuration: 0.3) {
            self.ttsInnerContentView.alpha = 0.0
        } completion: { isCompleted in
            self.ttsInnerContentView.isHidden = true
        }
    }
    
    func hapticFeedback(){
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred();
    }
    
    func loadUIWithSubscription(){
        
        if !SubscriptionManager.shared.isValidSubscription(){
            subscriptionView.isHidden = false
            ttsOuterContentView.isHidden = false
            ttsOuterContentView.backgroundColor = UIColor.appDisableGrayColor()
            ttsOuterContentView.isUserInteractionEnabled = false
            return
        }
        
        ttsOuterContentView.backgroundColor = UIColor.appBlueColor()
        subscriptionView.isHidden = true
        ttsOuterContentView.isUserInteractionEnabled = true
        checkBLEDevice()
    }
    
    func checkBLEDevice(){
        //Check If device is connected or not
        if !BluetoothManager.shared.isBluetoothAudioConnected(){
            //Show loading for device searching and connecting
            self.showConnectZygoView()
            self.setupScanningTimer()
            return
        }
        
        self.stopScanning()
        self.hideConnecZygoView()
    }
    
    func startDeviceSearching(){
        BLEConnectionManager.shared.stopScanning()
        BLEConnectionManager.shared.startAutoConnectScanning { [weak self] in
            DispatchQueue.main.async {
                self?.hideConnecZygoView()
            }
        }
    }
    
    func showConnectZygoView(){
        
        if !connectZygoView.isHidden {
            return
        }
        
        self.ttsOuterContentView.isHidden = true
        self.connectZygoView.isHidden = false
        self.lblConnectZygo.isHidden = false
        self.connectZygoView.alpha = 0.0
        self.lblConnectZygo.alpha = 0.0
        UIView.animate(withDuration: 0.7) {
            self.connectZygoView.alpha = 1.0
            self.lblConnectZygo.alpha = 1.0
        } completion: { isCompleted in
            
        }
    }
    
    func hideConnecZygoView(){
        self.ttsOuterContentView.isHidden = false
        self.ttsOuterContentView.alpha = 0.0
        UIView.animate(withDuration: 0.7) {
            self.connectZygoView.alpha = 0.0
            self.lblConnectZygo.alpha = 0.0
            self.ttsOuterContentView.alpha = 1.0
        } completion: { isCompleted in
            self.connectZygoView.isHidden = true
            self.lblConnectZygo.isHidden = true
        }
    }
    
    //MARK: - UIButton Action
    @IBAction func tapToSpeakAction(_ sender: UIButton){
        self.hapticFeedback()
        self.showTapToEndView()
        let status = self.audioController.startIOUnit()
        if status != 0{
            self.audioController.stopIOUnit()
            self.audioController = AudioController()
            let status = self.audioController.startIOUnit()
            if status != 0{
                Helper.shared.alert(title: Constants.appName, message: "Faild to start audio, please try again later.")
                self.hapticFeedback()
                self.hideTapToEndView()
                self.audioController.stopIOUnit()
            }
        }
    }
    
    @IBAction func tapToEndAction(_ sender: UIButton){
        self.hapticFeedback()
        self.hideTapToEndView()
        self.audioController.stopIOUnit()
    }
    
    @IBAction func backAction(_ sender: UIButton){
        self.removeObservers()
        self.stopScanning()
        self.audioController.stopIOUnit()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func openBLESettings(_ sender: UIButton){
        Helper.shared.openUrl(url: URL(string: UIApplication.openSettingsURLString))
    }
    
    @IBAction func subscriptionAction(_ sender: UIButton){
        let storyBoard = UIStoryboard(name: "Registration", bundle: nil)
        let navigationController = storyBoard.instantiateViewController(withIdentifier: "SubscriptionViewController") as! SubscriptionViewController
        navigationController.isFromDemoMode = true
        self.navigationController?.pushViewController(navigationController, animated: true)
    }
    
    //MARK: -
}

//MARK: TIMER
extension WalkieTalkieVC{
    func stopScanning(){
        stopTimer()
    }
    
    
    private func setupScanningTimer(){
        self.stopTimer()
        
        self.scanningTimer = Timer(timeInterval: 5, repeats: true, block: { [weak self] (timerObj) in
            print("Timer Scanning")
            if BluetoothManager.shared.isBluetoothAudioConnected(){
                self?.stopTimer()
                self?.hideConnecZygoView()
            }
        })
        
        RunLoop.current.add(self.scanningTimer!, forMode: .common)
    }
    
    private func stopTimer(){
        scanningTimer?.invalidate()
        scanningTimer = nil
    }
}
