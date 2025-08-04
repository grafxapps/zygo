//
//  SyncStatusPopupVC.swift
//  Zygo
//
//  Created by Som Parkash on 22/03/23.
//  Copyright © 2023 Somparkash. All rights reserved.
//

import UIKit

//MARK: - 
class SyncStatusPopupVC: UIViewController {
    
    @IBOutlet weak var headsetImageView: UIView!
    @IBOutlet weak var headsetV2ImageView: UIView!
    @IBOutlet weak var radioImageView: UIView!
    @IBOutlet weak var radioV2ImageView: UIView!
    
    @IBOutlet weak var lblHeadsetLastSync: UILabel!
    @IBOutlet weak var lblRadioLastSync: UILabel!
    
    @IBOutlet weak var lblConnectingMessage: UILabel!
    @IBOutlet weak var lblNotes: UILabel!
    @IBOutlet weak var lblNoDeviceMessage: UILabel!
    
    @IBOutlet weak var searchingView: UIView!
    
    @IBOutlet weak var btnHeadsetScan: UIButton!
    @IBOutlet weak var btnHeadsetV2Scan: UIButton!
    @IBOutlet weak var btnRadioScan: UIButton!
    @IBOutlet weak var btnRadioV2Scan: UIButton!
    
    @IBOutlet weak var lblNoDeviceTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchingViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var headsetRadioV1View: UIView!
    @IBOutlet weak var headsetRadioV2View: UIView!
    
    var onExit: (() -> Void)?
    
    //MARK: - UIViewcontroller LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addObservers()
        self.updateBLEInfo()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeObservers()
        BluetoothManager.shared.disableLapDataNotification()
        self.stopWaitOverTImer()
    }
    
    deinit {
        self.removeObservers()
    }
    
    //MARK: - Setups
    func addObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.removeObservers), name: .removeObservers, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateBLEInfo), name: .didHideMenu, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc func removeObservers(){
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func appDidBecomeActive(){
        self.updateBLEInfo()
        
    }
    
    func disableHeadset(){
        self.headsetImageView.alpha = 0.2
        self.btnHeadsetScan.isUserInteractionEnabled = true
    }
    
    func enableHeadset(){
        self.headsetImageView.alpha = 1.0
        self.btnHeadsetScan.isUserInteractionEnabled = false
    }
    
    func disableRadio(){
        self.radioImageView.alpha = 0.2
        self.btnRadioScan.isUserInteractionEnabled = true
    }
    
    func enableRadio(){
        self.radioImageView.alpha = 1.0
        self.btnRadioScan.isUserInteractionEnabled = false
    }
    
    @objc func updateBLEInfo(){
        self.updateLastSyncStatus()
        let deviceInfo = PreferenceManager.shared.deviceInfo
        self.updateDeviceVersionGraphics(deviceInfo)
        
        //Check If device is connected or not
        if !BluetoothManager.shared.isZygoDeviceConencted(){
            //Show loading for device searching and connecting
            self.showSearchingView()
            self.startDeviceSearching()
            
            self.disableHeadset()
            
            self.disableRadio()
            return
        }
        
        self.updateDeviceBatteryInfo()
        self.updateLapInfo()
    }
    
    func setupUI(){
        
        
        let connectingAttStrin = NSAttributedString(string: "Connecting to your transmitter in data transfer mode.", attributes: [.font: UIFont.appMediumItalic(with: 16.0)])
        self.lblConnectingMessage.attributedText = connectingAttStrin
        
        let notesAttStrin = NSAttributedString(string: "Only available for Z2 and V1 headsets with a model number that starts with ZY4.", attributes: [.font: UIFont.appMediumItalic(with: 14.0)])
        self.lblNotes.attributedText = notesAttStrin
        
        self.navigationController?.isNavigationBarHidden = true
        
    }
    
    func updateLastSyncStatus(){
        
        let deviceInfo = PreferenceManager.shared.deviceInfo
        
        if deviceInfo.versionInfo.isVersionZero(){
            //Disable Both Headset and Radio
            self.disableHeadset()
            self.disableRadio()
            
            return
        }
        
        if deviceInfo.headsetBatteryLevel <= 9 || deviceInfo.versionInfo.headsetVersion == "0"{
            self.disableHeadset()
        }else{
            self.enableHeadset()
        }
        
        self.enableRadio()
        
        var radioLastSync: String = ""
        var headsetLastSync: String = ""
        
        if let updateDate = deviceInfo.radioUpdateAt{
            
            let difference = (Date().timeIntervalSince1970 - updateDate.timeIntervalSince1970)/60
            if difference >= 3{
                self.disableRadio()
            }
            
            if difference < 1{
                radioLastSync = "Just Now"
            }else{
                radioLastSync = updateDate.dateDiff(to: Date())
            }
        }else{
            radioLastSync = "Never"
            
        }
        
        let lapInfo = PreferenceManager.shared.lapInfo
        if var updateDate = deviceInfo.headsetUpdateAt{
            
            updateDate = updateDate.addingTimeInterval(-Double(lapInfo.lastReadTime))
            let difference = (Date().timeIntervalSince1970 - updateDate.timeIntervalSince1970)/60
            if difference >= 3{
                self.disableHeadset()
            }
            
            if difference < 1{
                headsetLastSync = "Just Now"
            }else{
                headsetLastSync = updateDate.dateDiff(to: Date())
            }
        }else{
            headsetLastSync = "Never"
            
            self.disableHeadset()
        }
        
        self.updateLastSyncText(radio: radioLastSync, headset: headsetLastSync)
    }
    
    func updateLastSyncText(radio: String, headset: String){
        
        if self.lblRadioLastSync.text != radio{
            
            UIView.transition(with: self.lblRadioLastSync,
                              duration: 1.0,
                           options: .transitionCrossDissolve,
                        animations: { [weak self] in
                self?.lblRadioLastSync.text = radio
            }, completion: nil)
            
        }
        
        if self.lblHeadsetLastSync.text != headset{
            
            UIView.transition(with: self.lblHeadsetLastSync,
                              duration: 1.0,
                           options: .transitionCrossDissolve,
                        animations: { [weak self] in
                self?.lblHeadsetLastSync.text = headset
            }, completion: nil)
                        
        }
    }
    
    func showSearchingView(){
        self.searchingView.isHidden = false
        self.searchingView.alpha = 0.0
        UIView.animate(withDuration: 0.7) {
            self.searchingView.alpha = 1.0
        } completion: { isCompleted in
            
        }
    }
    
    func hideSearchingView(){
        UIView.animate(withDuration: 0.7) {
            self.searchingView.alpha = 0.0
            self.lblNoDeviceTopConstraint.priority = UILayoutPriority(999.9)
            self.searchingViewTopConstraint.priority = UILayoutPriority(250.0)
            self.view.layoutIfNeeded()
        } completion: { isCompleted in
            self.searchingView.isHidden = true
        }
    }
    
    func startDeviceSearching(){
        self.startWaitOverTimer()
        BLEConnectionManager.shared.stopScanning()
        BLEConnectionManager.shared.startAutoConnectScanning { [weak self] in
            self?.updateDeviceBatteryInfo()
            self?.updateLapInfo()
        }
    }
    
    
    private var waitTimer: Timer?
    func startWaitOverTimer(){
        self.stopWaitOverTImer()
        self.waitTimer = Timer(timeInterval: 30, repeats: false, block: { timerObj in
            DispatchQueue.main.async {
                BLEConnectionManager.shared.stopScanning()
                self.disableHeadset()
                self.disableRadio()
                self.hideSearchingView()
                self.lblNoDeviceMessage.text = "No Zygo devices were found. Make sure your device is on and in range and use Phone Settings to connect your device."
                
            }
            timerObj.invalidate()
        })
        
        RunLoop.main.add(self.waitTimer!, forMode: .common)
    }
    
    func stopWaitOverTImer(){
        self.waitTimer?.invalidate()
        self.waitTimer = nil
    }
    
    func updateDeviceVersionGraphics(_ deviceInfo: BLEDeviceInfoDTO){
        
        switch deviceInfo.versionInfo.zygoDeviceVersion {
        case .v1:
            if headsetRadioV1View.isHidden == false{
                return
            }
            
            headsetRadioV1View.isHidden = false
            headsetRadioV1View.alpha = 0.0
            UIView.animate(withDuration: 0.3) {
                self.headsetRadioV1View.alpha = 1.0
                self.headsetRadioV2View.alpha = 0.0
            } completion: { completed in
                self.headsetRadioV2View.isHidden = true
            }
        case .v2:
            if headsetRadioV2View.isHidden == false{
                return
            }
            
            headsetRadioV2View.isHidden = false
            headsetRadioV2View.alpha = 0.0
            UIView.animate(withDuration: 0.3) {
                self.headsetRadioV2View.alpha = 1.0
                self.headsetRadioV1View.alpha = 0.0
            } completion: { completed in
                self.headsetRadioV1View.isHidden = true
            }
        }
    }
    
    func updateDeviceBatteryInfo(){
        
        BluetoothManager.shared.readHardwareInfo { [weak self] deviceInfo in
            DispatchQueue.main.async {
                
                self?.hideSearchingView()
                
                self?.updateDeviceVersionGraphics(deviceInfo)
                if deviceInfo.versionInfo.isVersionZero(){
                    //Disable Both Headset and Radio
                    
                    self?.disableHeadset()
                    self?.disableRadio()
                    
                    return
                }
                
                if deviceInfo.headsetBatteryLevel <= 9{
                    self?.disableHeadset()
                }else{
                    self?.enableHeadset()
                }
                
                
                self?.enableRadio()
                
                
                self?.updateLastSyncStatus()
            }
        }
        
    }
    
    func updateLapInfo(){
        
        BluetoothManager.shared.readLapData { [weak self] lapInfo in
            DispatchQueue.main.async {
                
                BluetoothManager.shared.enableLapDataNotification { tempLapInfo in
                    DispatchQueue.main.async {
                        self?.updateLastSyncStatus()
                    }
                }
            }
        }
        
    }
    
    
    //MARK: - UIButton Actions
    @IBAction func scanAgain(_ sender: UIButton){
        self.updateLastSyncStatus()
        
        //Show loading for device searching and connecting
        self.showSearchingView()
        
        //Check If device is connected or not
        if !BluetoothManager.shared.isZygoDeviceConencted(){
            
            self.startDeviceSearching()
            
            self.disableHeadset()
            self.disableRadio()
            return
        }
        
        self.updateDeviceBatteryInfo()
    }
    
    @IBAction func exitAction(_ sender: UIButton){
        self.dismiss(animated: true) {
            self.onExit?()
        }
    }
}
