//
//  MetricsBTVC.swift
//  Zygo
//
//  Created by Som on 11/09/22.
//  Copyright © 2022 Somparkash. All rights reserved.
//

import UIKit

class MetricsBTVC: UIViewController {
    
    @IBOutlet weak var headsetImageView: UIView!
    @IBOutlet weak var radioImageView: UIView!
    
    @IBOutlet weak var lblHeadsetLastSync: UILabel!
    @IBOutlet weak var lblRadioLastSync: UILabel!
    
    @IBOutlet weak var lblConnectingMessage: UILabel!
    @IBOutlet weak var lblNotes: UILabel!
    
    @IBOutlet weak var searchingView: UIView!
    
    @IBOutlet weak var lapInfoView: UIView!
    @IBOutlet weak var btnSave: UIButton!
    
    @IBOutlet weak var btnHeadsetScan: UIButton!
    @IBOutlet weak var btnRadioScan: UIButton!
    
    
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
            self?.updateLapInfo()
        }
    }
    
    func updateDeviceBatteryInfo(){
        
        BluetoothManager.shared.readHardwareInfo { [weak self] deviceInfo in
            DispatchQueue.main.async {
                
                self?.hideSearchingView()
                
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
                
                let totalLaps = lapInfo?.getTotalNumberOfLaps() ?? 0
                print("TOTAL LAPS: \(totalLaps)")
                print("TIME: \(lapInfo?.totalTime ?? 0)")
                print("START STOP: \(lapInfo?.startStopStatus ?? 0)")
                print("LAST READ TIME: \(lapInfo?.lastReadTime ?? 0)")
                print("SERIAL NUMBER: \(lapInfo?.serialNumber ?? 0)")
                print("OLD NEW STATUS: \(lapInfo?.oldNewStatus ?? 0)")
                
                
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
    
    
    //MARK: -
}
