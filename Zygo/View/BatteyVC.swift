//
//  BatteyVC.swift
//  Zygo
//
//  Created by Som on 11/09/22.
//  Copyright © 2022 Somparkash. All rights reserved.
//

import UIKit

//MARK: -
class BatteyVC: UIViewController {
    
    
    @IBOutlet weak var headsetImageView: UIView!
    @IBOutlet weak var radioImageView: UIView!
    
    @IBOutlet weak var headsetInfoView: UIView!
    @IBOutlet weak var radioInfoView: UIView!
    
    @IBOutlet weak var headsetBatteryView: UIView!
    @IBOutlet weak var radioBatteryView: UIView!
    
    @IBOutlet weak var btnHeadsetInfo: UIButton!
    @IBOutlet weak var btnRadioInfo: UIButton!
    
    @IBOutlet weak var lblHeadsetBatLevel: UILabel!
    @IBOutlet weak var lblRadioBatLevel: UILabel!
    
    @IBOutlet weak var lblHeadsetLastSync: UILabel!
    @IBOutlet weak var lblRadioLastSync: UILabel!
    
    @IBOutlet weak var lblConnectingMessage: UILabel!
    @IBOutlet weak var lblNotes: UILabel!
    
    @IBOutlet weak var progressHeadsetBatLevel: UIProgressView!
    @IBOutlet weak var progressRadioBatLevel: UIProgressView!
    
    @IBOutlet weak var searchingView: UIView!
    @IBOutlet weak var contentBGView: UIView!
    
    @IBOutlet weak var btnHeadsetScan: UIButton!
    @IBOutlet weak var btnRadioScan: UIButton!
    
    private let preFirmwareViewModel = PreFirmwareUpdateViewModel()
    
    //MARK: - UIViewcontroller LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addObservers()
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateBLEInfo()
        
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
        self.lblHeadsetBatLevel.alpha = 0.2
        self.headsetBatteryView.alpha = 0.2
        self.btnHeadsetScan.isUserInteractionEnabled = true
    }
    
    func enableHeadset(){
        self.headsetImageView.alpha = 1.0
        self.lblHeadsetBatLevel.alpha = 1.0
        self.headsetBatteryView.alpha = 1.0
        self.btnHeadsetScan.isUserInteractionEnabled = false
    }
    
    func disableRadio(){
        self.radioImageView.alpha = 0.2
        self.lblRadioBatLevel.alpha = 0.2
        self.radioBatteryView.alpha = 0.2
        self.btnRadioScan.isUserInteractionEnabled = true
    }
    
    func enableRadio(){
        self.radioImageView.alpha = 1.0
        self.lblRadioBatLevel.alpha = 1.0
        self.radioBatteryView.alpha = 1.0
        self.btnRadioScan.isUserInteractionEnabled = false
    }
    
    @objc func updateBLEInfo(){
        self.updateLastSyncStatus()
        
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
    }
    
    func setupUI(){
        
        
        let connectingAttStrin = NSAttributedString(string: "Connecting to your transmitter in data transfer mode.", attributes: [.font: UIFont.appMediumItalic(with: 16.0)])
        self.lblConnectingMessage.attributedText = connectingAttStrin
        
        let notesAttStrin = NSAttributedString(string: "This feature is only available on units with a headset serial number that begins with “ZY4”.", attributes: [.font: UIFont.appMediumItalic(with: 14.0)])
        self.lblNotes.attributedText = notesAttStrin
        
        self.navigationController?.isNavigationBarHidden = true
        
        btnHeadsetInfo.setTitle("", for: .normal)
        btnRadioInfo.setTitle("", for: .normal)
        
    }
    
    func updateLastSyncStatus(){
        
        let deviceInfo = PreferenceManager.shared.deviceInfo
        
        self.lblRadioBatLevel.text = "\(deviceInfo.radioBatteryLevel) %"
        self.progressRadioBatLevel.progress = Float(deviceInfo.radioBatteryLevel)/100
        
        self.lblHeadsetBatLevel.text = "\(deviceInfo.headsetBatteryLevel) %"
        self.progressHeadsetBatLevel.progress = Float(deviceInfo.headsetBatteryLevel)/100
        
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
        
        
        if let updateDate = deviceInfo.radioUpdateAt{
            
            let difference = (Date().timeIntervalSince1970 - updateDate.timeIntervalSince1970)/60
            if difference >= 3{
                self.disableRadio()
            }
            
            self.lblRadioLastSync.text = updateDate.dateDiff(to: Date())
        }else{
            self.lblRadioLastSync.text = "Never"
            
        }
        
        if let updateDate = deviceInfo.headsetUpdateAt{
            let difference = (Date().timeIntervalSince1970 - updateDate.timeIntervalSince1970)/60
            if difference >= 3{
                self.disableHeadset()
            }
            self.lblHeadsetLastSync.text = updateDate.dateDiff(to: Date())
        }else{
            self.lblHeadsetLastSync.text = "Never"
            
            self.disableHeadset()
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
        } completion: { isCompleted in
            self.searchingView.isHidden = true
        }
    }
    
    func startDeviceSearching(){
        BLEConnectionManager.shared.stopScanning()
        BLEConnectionManager.shared.startAutoConnectScanning { [weak self] in
            self?.updateDeviceBatteryInfo()
        }
    }
    
    func updateDeviceBatteryInfo(){
        
        UIView.animate(withDuration: 0.7) {
            self.contentBGView.alpha = 0.0
        } completion: { isCompleted in
            self.contentBGView.isHidden = true
        }
        
        BluetoothManager.shared.readHardwareInfo { [weak self] deviceInfo in
            DispatchQueue.main.async {
                
                self?.hideSearchingView()
                
                self?.lblRadioBatLevel.text = "\(deviceInfo.radioBatteryLevel) %"
                self?.progressRadioBatLevel.progress = Float(deviceInfo.radioBatteryLevel)/100
                
                self?.lblHeadsetBatLevel.text = "\(deviceInfo.headsetBatteryLevel) %"
                self?.progressHeadsetBatLevel.progress = Float(deviceInfo.headsetBatteryLevel)/100
                
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
                
                
                //TODO: Comment this return if want to show firmware update popup
                return
                if let laterDate = PreferenceManager.shared.firmwareLaterDate{
                    let popupDay = Calendar.current.dateComponents([.day], from: laterDate, to: Date().toStartOfTheDayUTC().toSGlobalTime()).day ?? 0
                    if popupDay < 1{
                        return
                    }
                }
                
                self?.preFirmwareViewModel.getFirmwareDetail(isErrorMessage: false) { isComplete in
                    
                    self?.preFirmwareViewModel.setupFirmwareDataWithDeviceVersions(infoItem: deviceInfo.versionInfo)
                    
                    if self?.preFirmwareViewModel.arrFirmwares.count ?? 0 > 0{
                        //Show Firmware update popup
                        let vc = FirmwareUpdatePopUpVC(nibName: "FirmwareUpdatePopUpVC", bundle: nil)
                        vc.modalPresentationStyle = .overFullScreen
                        vc.onGo = {
                            //self?.pushToFirmwareUpdate()
                        }
                        
                        vc.onLater = {
                            PreferenceManager.shared.firmwareLaterDate = Date().toStartOfTheDayUTC().toSGlobalTime()
                        }
                        
                        let navController = UINavigationController(rootViewController: vc)
                        navController.modalPresentationStyle = .overFullScreen
                        navController.isNavigationBarHidden = true
                        self?.present(navController, animated: true, completion: nil)
                    }
                }
            }
        }
        
    }
    
    func pushToFirmwareUpdate(){
        let preVC = UIStoryboard(name: "SideMenu", bundle: nil).instantiateViewController(withIdentifier: "PreFirmwareUpdateVC") as! PreFirmwareUpdateVC
        preVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(preVC, animated: true)
    }
    
    //MARK: - UIButton Actions
    @IBAction func headsetInfoAction(_ sender: UIButton){
        
    }
    
    @IBAction func radioInfoAction(_ sender: UIButton){
        
    }
    
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
    
    
    //MARK: -
}
