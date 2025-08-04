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
    @IBOutlet weak var headsetV2ImageView: UIView!
    @IBOutlet weak var radioImageView: UIView!
    @IBOutlet weak var radioV2ImageView: UIView!
    
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
    @IBOutlet weak var btnHeadsetV2Scan: UIButton!
    @IBOutlet weak var btnRadioScan: UIButton!
    @IBOutlet weak var btnRadioV2Scan: UIButton!
    
    private let preFirmwareViewModel = PreFirmwareUpdateViewModel()
    
    @IBOutlet weak var headsetRadioV1View: UIView!
    @IBOutlet weak var headsetRadioV2View: UIView!
    
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        BluetoothManager.shared.disableLapDataNotification()
        BluetoothManager.shared.disableHardwareDataNotification()
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
    
    func updateInfo(){
        //Check if BLE Permission is enable or not
        if BluetoothManager.shared.isBluetoothTurnOn{
            let connectingAttStrin = NSAttributedString(string: "Connecting to your transmitter in data transfer mode.", attributes: [.font: UIFont.appMediumItalic(with: 16.0)])
            self.lblConnectingMessage.attributedText = connectingAttStrin
        }else{
            let connectingAttStrin = NSAttributedString(string: "Pease give Zygo permission to access Bluetooth in Settings›Zygo.", attributes: [.font: UIFont.appMediumItalic(with: 16.0)])
            self.lblConnectingMessage.attributedText = connectingAttStrin
        }
    }
    
    func disableHeadset(){
        self.headsetImageView.alpha = 0.2
        self.headsetV2ImageView.alpha = 0.2
        self.btnHeadsetScan.isUserInteractionEnabled = true
        self.btnHeadsetV2Scan.isUserInteractionEnabled = true
    }
    
    func enableHeadset(){
        self.headsetImageView.alpha = 1.0
        self.headsetV2ImageView.alpha = 1.0
        self.btnHeadsetScan.isUserInteractionEnabled = false
        self.btnHeadsetV2Scan.isUserInteractionEnabled = false
    }
    
    func disableRadio(){
        self.radioImageView.alpha = 0.2
        self.radioV2ImageView.alpha = 0.2
        self.btnRadioScan.isUserInteractionEnabled = true
        self.btnRadioV2Scan.isUserInteractionEnabled = true
    }
    
    func enableRadio(){
        self.radioImageView.alpha = 1.0
        self.radioV2ImageView.alpha = 1.0
        self.btnRadioScan.isUserInteractionEnabled = false
        self.btnRadioV2Scan.isUserInteractionEnabled = false
    }
    
    @objc func updateBLEInfo(){
        self.updateInfo()
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
    }
    
    func setupUI(){
        
        
        let connectingAttStrin = NSAttributedString(string: "Connecting to your transmitter in data transfer mode.", attributes: [.font: UIFont.appMediumItalic(with: 16.0)])
        self.lblConnectingMessage.attributedText = connectingAttStrin
        
        self.updateInfo()
        
        let notesAttStrin = NSAttributedString(string: "Only available for Z2 and V1 headsets with a model number that starts with ZY4.", attributes: [.font: UIFont.appMediumItalic(with: 14.0)])
        self.lblNotes.attributedText = notesAttStrin
        
        self.navigationController?.isNavigationBarHidden = true
        
        btnHeadsetInfo.setTitle("", for: .normal)
        btnRadioInfo.setTitle("", for: .normal)
        
    }
    
    func updateLastSyncStatus(){
        
        let deviceInfo = PreferenceManager.shared.deviceInfo
        let lapInfo = PreferenceManager.shared.lapInfo
        
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
    
    func updateHeadserLastSyncStatus(){
        
        let deviceInfo = PreferenceManager.shared.deviceInfo
        let lapInfo = PreferenceManager.shared.lapInfo
        
        if deviceInfo.headsetBatteryLevel <= 9 || deviceInfo.versionInfo.headsetVersion == "0"{
            self.disableHeadset()
        }else{
            self.enableHeadset()
        }
                
        
        var headsetLastSync: String = ""
        
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
        
        self.updateLastSyncText(radio: self.lblRadioLastSync.text ?? "", headset: headsetLastSync)
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
        
        UIView.animate(withDuration: 0.7) {
            self.contentBGView.alpha = 0.0
        } completion: { isCompleted in
            self.contentBGView.isHidden = true
        }
        
        BluetoothManager.shared.readHardwareInfo { [weak self] deviceInfo in
            DispatchQueue.main.async {
                
                self?.preFirmwareViewModel.updateFirmwareVersionsInfo {
                    
                }
                
                self?.updateDeviceVersionGraphics(deviceInfo)
                
                BluetoothManager.shared.readAllCharactersticsData { allCharData, headsetSerialNumber in
                    
                    if deviceInfo.versionInfo.zygoDeviceVersion == .v2{
                        BluetoothManager.shared.readZygo2TranmistterSerialNumber { transmitterSerialNumber in
                            print("Zygo2 Transmitter Serial Number: \(transmitterSerialNumber)")
                            self?.preFirmwareViewModel.updateHeadsetSerialNumber(transmitterSerialNumber: transmitterSerialNumber, headsetSerialNumber: headsetSerialNumber, bleAllCharData: allCharData, completion: {
                                
                            })
                        }
                    }else{
                        self?.preFirmwareViewModel.updateHeadsetSerialNumber(transmitterSerialNumber: "", headsetSerialNumber: headsetSerialNumber, bleAllCharData: allCharData, completion: {
                            
                        })
                    }
                   
                    BluetoothManager.shared.readLapData { lapInfo in
                        DispatchQueue.main.async {
                            
                            self?.updateUIAfterHardwareData()
                            /*BluetoothManager.shared.enableHardwareDataNotification { bleInfo in
                                self?.updateUIAfterHardwareData()
                            }*/
                            
                            BluetoothManager.shared.enableLapDataNotification(completion: { bleInfo in
                                self?.updateUIAfterHardwareData()
                            })
                        }
                    }
                    
                    PreferenceManager.shared.isBLEEnabledDevice = true
                                    
                    self?.updateLastSyncStatus()
                }

                if let laterDate = PreferenceManager.shared.firmwareLaterDate{
                    let popupDay = Calendar.current.dateComponents([.day], from: laterDate, to: Date().toStartOfTheDayUTC().toSGlobalTime()).day ?? 0
                    if popupDay < 1{
                        return
                    }
                }
                if let topVC = UIApplication.topViewController(){
                    if topVC is PreFirmwareUpdateVC || topVC is FirmwareUpdateVC{
                        return
                    }
                }
                
                self?.preFirmwareViewModel.getFirmwareDetail(zygoVersion: deviceInfo.versionInfo.zygoDeviceVersion, isErrorMessage: false) { isComplete in
                    
                    self?.preFirmwareViewModel.setupFirmwareDataWithDeviceVersions(infoItem: deviceInfo.versionInfo)
                    
                    if self?.preFirmwareViewModel.arrFirmwares.count ?? 0 > 0{
                        
                        print("Device Info: \(deviceInfo.versionInfo.toDict())")
                        
                        let topViewController = UIApplication.topViewController()
                        if (topViewController is FirmwareUpdateVC) || (topViewController is PreFirmwareUpdateVC) || (topViewController is FirmwareUpdateSuccessVC){
                            print("No need to show firmware update popup")
                        }else{
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
        
    }
    
    func updateUIAfterHardwareData(){
        self.hideSearchingView()
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
        
        if deviceInfo.headsetBatteryLevel <= 9{
            self.disableHeadset()
        }else{
            self.enableHeadset()
        }
        
        
        self.enableRadio()
        
        
        self.updateLastSyncStatus()
        
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
