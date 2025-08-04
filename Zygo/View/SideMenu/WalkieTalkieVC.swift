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
    @IBOutlet weak var connectingWalkiTalkieView: UIView!
    @IBOutlet weak var subscriptionView: UIView!
    
    @IBOutlet weak var tapToSpeakView: UIView!
    @IBOutlet weak var tapToEndView: UIView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var btnSubscription: UIButton!
    @IBOutlet weak var lblConnectZygo: UILabel!
    
    private var audioController: AudioController?
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
        
        activityIndicator.isHidden = true
        
        ttsOuterContentView.layer.cornerRadius = (ScreenSize.SCREEN_WIDTH - 100.0)/2.0
        ttsOuterContentView.clipsToBounds = true
        
        ttsInnerContentView.layer.cornerRadius = (ScreenSize.SCREEN_WIDTH - 110.0)/2.0
        ttsInnerContentView.clipsToBounds = true
        
        connectZygoView.layer.cornerRadius = (ScreenSize.SCREEN_WIDTH - 110.0)/2.0
        connectZygoView.clipsToBounds = true
        connectingWalkiTalkieView.layer.cornerRadius = (ScreenSize.SCREEN_WIDTH - 110.0)/2.0
        connectingWalkiTalkieView.clipsToBounds = true
        
        btnSubscription.layer.cornerRadius = 10
        btnSubscription.clipsToBounds = true
        
    }
    
    func showTapToEndView(){
        self.activityIndicator.isHidden = true
        self.tapToEndView.isHidden = false
        self.ttsInnerContentView.backgroundColor = .white
        self.ttsInnerContentView.isUserInteractionEnabled = true
        
        self.ttsInnerContentView.isHidden = false
        self.ttsInnerContentView.alpha = 0.0
        UIView.animate(withDuration: 0.3) {
            self.ttsInnerContentView.alpha = 1.0
        } completion: { isCompleted in
            self.tapToSpeakView.isHidden = false
            self.ttsOuterContentView.backgroundColor = UIColor.appBlueColor()
            self.ttsOuterContentView.isUserInteractionEnabled = true
        }
    }
    
    func hideTapToEndView(){
        self.activityIndicator.isHidden = true
        self.tapToSpeakView.isHidden = false
        self.ttsOuterContentView.backgroundColor = UIColor.appBlueColor()
        self.ttsOuterContentView.isUserInteractionEnabled = true
        
        UIView.animate(withDuration: 0.3) {
            self.ttsInnerContentView.alpha = 0.0
        } completion: { isCompleted in
            self.ttsInnerContentView.isHidden = true
            
            
            
            self.tapToEndView.isHidden = false
            self.ttsInnerContentView.backgroundColor = .white
            self.ttsInnerContentView.isUserInteractionEnabled = true
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
        if BluetoothManager.shared.isZygoDeviceConencted(){
            if !BluetoothManager.shared.isBluetoothAudioConnected(){
                Helper.shared.alert(title: Constants.appName, message: "Select your Zygo in your phone's list of Bluetooth devices to pair the device.")
            }
        }
        
        if !BluetoothManager.shared.isBluetoothAudioConnected() || !BluetoothManager.shared.isZygoDeviceConencted(){
            //Show loading for device searching and connecting
            if self.audioController?.isAudioControllerStarted ?? false{
                self.hapticFeedback()
                self.hideTapToEndView()
                self.audioController?.stopIOUnit()
            }
            self.showConnectZygoView()
            self.setupScanningTimer()
            self.startDeviceSearching()
            return
        }
        
        self.stopScanning()
        self.hideConnecZygoView()
        self.hideConnectingWalkieTalkieView()
        self.readZygoStatusAndUpdateMode()
    }
    
    func startDeviceSearching(){
        BLEConnectionManager.shared.stopScanning()
        BLEConnectionManager.shared.startAutoConnectScanning { [weak self] in
            DispatchQueue.main.async {
                self?.hideConnecZygoView()
                self?.hideConnectingWalkieTalkieView()
                self?.readZygoStatusAndUpdateMode()
            }
        }
    }
    
    func readZygoStatusAndUpdateMode(){
        
        if BluetoothManager.shared.isZygoDeviceConencted(){
            if !BluetoothManager.shared.isBluetoothAudioConnected(){
                Helper.shared.alert(title: Constants.appName, message: "Select your Zygo in your phone's list of Bluetooth devices to pair the device.")
            }
        }
        
        if BluetoothManager.shared.isZygoDeviceConencted() && BluetoothManager.shared.isBluetoothAudioConnected() {
            
            BluetoothManager.shared.readCommunicationMode { communicationMode in
                if communicationMode == "30"{
                    //Normal
                    if self.audioController?.isAudioControllerStarted ?? false{
                        self.tapToEndAction(UIButton())
                    }
                }else if communicationMode == "31"{
                    //Quick
                    if !(self.audioController?.isAudioControllerStarted ?? false){
                        self.tapToSpeakAction(UIButton())
                    }
                }
            }
        }
        
    }
    
    func showConnectZygoView(){
        
        if !connectZygoView.isHidden {
            return
        }
        
        self.connectingWalkiTalkieView.isHidden = true
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
    
    func showConnectingWalkieTalkieView(){
        
        if !connectingWalkiTalkieView.isHidden {
            return
        }
        
        self.ttsOuterContentView.isHidden = true
        self.connectingWalkiTalkieView.isHidden = false
        self.lblConnectZygo.isHidden = false
        self.connectingWalkiTalkieView.alpha = 0.0
        self.lblConnectZygo.alpha = 0.0
        UIView.animate(withDuration: 0.7) {
            self.connectingWalkiTalkieView.alpha = 1.0
            self.lblConnectZygo.alpha = 1.0
        } completion: { isCompleted in
            
        }
    }
    
    func hideConnectingWalkieTalkieView(){
        self.ttsOuterContentView.isHidden = false
        self.ttsOuterContentView.alpha = 0.0
        UIView.animate(withDuration: 0.7) {
            self.connectingWalkiTalkieView.alpha = 0.0
            self.lblConnectZygo.alpha = 0.0
            self.ttsOuterContentView.alpha = 1.0
        } completion: { isCompleted in
            self.connectingWalkiTalkieView.isHidden = true
            self.lblConnectZygo.isHidden = true
        }
    }
    
    //MARK: - UIButton Action
    @IBAction func tapToSpeakAction(_ sender: UIButton){
        if BluetoothManager.shared.isZygoDeviceConencted(){
            
            if self.audioController == nil{
                self.audioController = AudioController()
            }
            
            self.hapticFeedback()
            self.tapToSpeakView.isHidden = true
            self.activityIndicator.color = UIColor.white
            self.activityIndicator.startAnimating()
            self.activityIndicator.isHidden = false
            self.ttsOuterContentView.backgroundColor = UIColor.appBlueColor().withAlphaComponent(0.6)
            self.ttsOuterContentView.isUserInteractionEnabled = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){
                BluetoothManager.shared.setCommunicationQuick { isUpdate in
                    if !isUpdate{
                        DispatchQueue.main.async{
                            Helper.shared.alert(title: Constants.appName, message: "We couldn't connect.")
                            self.hideTapToEndView()
                        }
                    }else{
                        print("Set Communication Quick")
                        DispatchQueue.main.async{
                            self.activityIndicator.isHidden = true
                            self.showTapToEndView()
                            
                            let status = self.audioController?.startIOUnit()
                            if status != 0{
                                self.audioController?.stopIOUnit()
                                self.audioController = AudioController()
                                let status = self.audioController?.startIOUnit()
                                if status != 0{
                                    Helper.shared.alert(title: Constants.appName, message: "Failed to start audio, please try again later.")
                                    self.hapticFeedback()
                                    self.hideTapToEndView()
                                    self.audioController?.stopIOUnit()
                                }
                            }
                        }
                    }
                }
            }
        }else{
            //Show connecting to walkie talkie mode
            self.showConnectingWalkieTalkieView()
            self.setupScanningTimer()
            self.startDeviceSearching()
        }
    }
    
    @IBAction func tapToEndAction(_ sender: UIButton){
        if BluetoothManager.shared.isZygoDeviceConencted(){
            
            self.hapticFeedback()
            self.audioController?.stopIOUnit()
            
            self.tapToEndView.isHidden = true
            self.activityIndicator.color = UIColor.appBlueColor()
            self.activityIndicator.startAnimating()
            self.activityIndicator.isHidden = false
            self.ttsInnerContentView.backgroundColor = UIColor.appLightGrey()
            self.ttsInnerContentView.isUserInteractionEnabled = false

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){
                BluetoothManager.shared.setCommunicationNormal { isUpdate in
                    if !isUpdate{
                        DispatchQueue.main.async{
                            Helper.shared.alert(title: Constants.appName, message: "We couldn't connect.")
                            self.showConnectingWalkieTalkieView()
                        }
                    }else{
                        print("Set Communication Normal")
                        DispatchQueue.main.async{
                            self.hideTapToEndView()
                        }
                    }
                }
            }
        }else{
            //Show connecting to walkie talkie mode
            self.showConnectingWalkieTalkieView()
            self.setupScanningTimer()
            self.startDeviceSearching()
        }
    }
    
    @IBAction func backAction(_ sender: UIButton){
        self.removeObservers()
        self.stopScanning()
        self.audioController?.stopIOUnit()
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
            if BluetoothManager.shared.isBluetoothAudioConnected() && BluetoothManager.shared.isZygoDeviceConencted(){
                self?.stopTimer()
                self?.hideConnecZygoView()
                self?.hideConnectingWalkieTalkieView()
            }
        })
        
        RunLoop.current.add(self.scanningTimer!, forMode: .common)
    }
    
    private func stopTimer(){
        scanningTimer?.invalidate()
        scanningTimer = nil
    }
}
