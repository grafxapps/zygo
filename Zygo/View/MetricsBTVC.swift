//
//  MetricsBTVC.swift
//  Zygo
//
//  Created by Som on 11/09/22.
//  Copyright © 2022 Somparkash. All rights reserved.
//

import UIKit
import MessageUI

class MetricsBTVC: UIViewController {
    
    @IBOutlet weak var headsetImageView: UIView!
    @IBOutlet weak var headsetV2ImageView: UIView!
    @IBOutlet weak var radioImageView: UIView!
    @IBOutlet weak var radioV2ImageView: UIView!
    
    @IBOutlet weak var lblHeadsetLastSync: UILabel!
    @IBOutlet weak var lblRadioLastSync: UILabel!
    
    @IBOutlet weak var lblConnectingMessage: UILabel!
    @IBOutlet weak var lblNotes: UILabel!
    
    @IBOutlet weak var lblLaps: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
    @IBOutlet weak var searchingView: UIView!
    
    @IBOutlet weak var lapInfoView: UIView!
    @IBOutlet weak var btnSave: UIButton!
    
    @IBOutlet weak var btnHeadsetScan: UIButton!
    @IBOutlet weak var btnRadioScan: UIButton!
    @IBOutlet weak var btnHeadsetV2Scan: UIButton!
    @IBOutlet weak var btnRadioV2Scan: UIButton!
    
    @IBOutlet weak var btnShareFeedback: UIButton!
    
    @IBOutlet weak var headsetRadioV1View: UIView!
    @IBOutlet weak var headsetRadioV2View: UIView!
    
    @IBOutlet weak var noLapCountView: UIView!
    
    private let viewModel = WorkoutPlayerViewModel()
    
    private let preFirmwareViewModel = PreFirmwareUpdateViewModel()
    
    //MARK: - UIViewcontroller LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addObservers()
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.fetchLastCompletedWorkout {
            
        }
        self.updateBLEInfo()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        BluetoothManager.shared.disableLapDataNotification()
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
    
    func showInfoView(){
        self.lapInfoView.isHidden = false
        self.btnSave.isHidden = false
        self.btnShareFeedback.isHidden = true
    }
    
    func hideInfoView(){
        self.lapInfoView.isHidden = true
        self.btnSave.isHidden = true
        self.btnShareFeedback.isHidden = true
    }
    
    func showNoLapCountView(){
        self.noLapCountView.isHidden = false
        self.btnSave.isHidden = true
        self.btnShareFeedback.isHidden = true
    }
    
    func hideNoLapCountView(){
        self.noLapCountView.isHidden = true
        self.btnSave.isHidden = true
        self.btnShareFeedback.isHidden = true
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
        
        self.hideInfoView()
        self.hideNoLapCountView()
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
        
        BluetoothManager.shared.readHardwareInfo { [weak self] deviceInfo in
            DispatchQueue.main.async {
                self?.preFirmwareViewModel.updateFirmwareVersionsInfo {
                    
                }
                
                self?.updateUIAfterHardwareData()
                
                PreferenceManager.shared.isBLEEnabledDevice = true
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
                    
                    self?.updateLapInfo()
                }
                
                /*BluetoothManager.shared.enableHardwareDataNotification { bleInfo in
                    self?.updateUIAfterHardwareData()
                }*/
                
                if let laterDate = PreferenceManager.shared.firmwareLaterDate{
                    let popupDay = Calendar.current.dateComponents([.day], from: laterDate, to: Date().toStartOfTheDayUTC().toSGlobalTime()).day ?? 0
                    if popupDay < 1{
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
    
    func updateLapInfo(){
        
        BluetoothManager.shared.readLapData { [weak self] lapInfo in
            DispatchQueue.main.async {
                
                self?.updateUIAfterHardwareData()
                self?.updateUIAfterReadLapInfo()
                BluetoothManager.shared.enableLapDataNotification(completion: { bleInfo in
                    self?.updateUIAfterReadLapInfo()
                    self?.updateUIAfterHardwareData()
                })
            }
        }
    }
    
    func updateUIAfterReadLapInfo(){
        
        let lapInfo = PreferenceManager.shared.lapInfo
        let totalLaps = lapInfo.numberOfLaps
        if totalLaps <= 0{
            //show time to get in pool view
            self.showNoLapCountView()
            self.hideInfoView()
            
        }else{
            self.hideNoLapCountView()
            self.showInfoView()
            let timeInSeconds = Double(lapInfo.totalTime)
            
            var lapText = "laps"
            if totalLaps == 1{
                lapText = "lap"
            }
            
            self.lblLaps.text = "\(totalLaps) \(lapText)"
            let minutes = floor(timeInSeconds/60.0)
            
            var strTime = ""
            if timeInSeconds <= 0{
                strTime = ""
            }else if minutes < 500{
                strTime = self.formatTime(seconds: timeInSeconds)
            }
            
            self.lblTime.text = "\(strTime)\naveraging \(self.averageLapTime(totalSeconds: timeInSeconds, laps: Int(totalLaps))) per lap"
            
            
            if let savedWorkout = self.viewModel.lastSavedWorkout{
                self.updateSaveButtonStatus(savedWorkout: savedWorkout)
            }else{
                Helper.shared.startLoading()
                self.viewModel.fetchLastCompletedWorkout {
                    Helper.shared.stopLoading()
                    if let savedWorkout = self.viewModel.lastSavedWorkout{
                        self.updateSaveButtonStatus(savedWorkout: savedWorkout)
                    }
                }
            }
            /*if lapInfo.oldNewStatus != 1{
                if totalLaps > 0{
                    self.lblTime.text = "\(strTime)\nduring your previous swim"
                }else{
                    self.lblTime.text = "\(strTime)"
                }
            }else{
                self.lblTime.text = strTime
            }*/
        }
        
    }
    
    func updateSaveButtonStatus(savedWorkout: LastSavedWorkout){
        let lapInfo = PreferenceManager.shared.lapInfo
        
        if lapInfo.numberOfLaps == savedWorkout.headsetLapsRaw && lapInfo.startStopStatus == savedWorkout.startStop && lapInfo.totalTime == savedWorkout.headsetElapsedTime {
            //Already saved
            self.btnSave.isUserInteractionEnabled = false
            self.btnSave.setTitle("ALREADY SAVED", for: .normal)
            self.btnSave.alpha = 0.6
        }else{
            //Not Saved
            self.btnSave.isUserInteractionEnabled = true
            self.btnSave.setTitle("SAVE", for: .normal)
            self.btnSave.alpha = 1.0
        }
        
        
    }
    
    func formatTime(seconds: Double) -> String {
        let totalSeconds = Int(seconds)
        
        if totalSeconds >= 60 {
            let minutes = totalSeconds / 60
            let remainingSeconds = totalSeconds % 60
            return "in \(minutes) min, \(remainingSeconds) sec"
        } else {
            return "in \(totalSeconds) sec"
        }
    }
    
    func averageLapTime(totalSeconds: Double, laps: Int) -> String {
        guard laps > 0 else { return "Invalid number of laps" }

        let average = totalSeconds / Double(laps)
        let roundedAverage = Int(average.rounded())

        if roundedAverage >= 60 {
            let minutes = roundedAverage / 60
            let seconds = roundedAverage % 60
            return "\(minutes):\(String(format: "%02d", seconds))"
        } else {
            return "\(roundedAverage) sec"
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
    
    @IBAction func saveAction(_ sender: UIButton){
        
        if Helper.shared.isDemoMode{
            Helper.shared.stopTempoTrainerOnController()
            let alert = CustomAlertWithCloseVC(nibName: "CustomAlertWithCloseVC", bundle: nil, title: Constants.appName, message: "Start your free trial to access all of our content.", buttonTitle: "Subscribe") { (isYes) in
                if isYes{
                    //Push To Subscribe screen
                    Helper.shared.pushToSubscriptionScreen(from: self)
                }else{
                }
            }
            
            alert.transitioningDelegate = self
            alert.modalPresentationStyle = .custom
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let lapInfo = PreferenceManager.shared.lapInfo
        let timeInSeconds = Double(lapInfo.totalTime)
        let duration = timeInSeconds
        self.viewModel.completeWorkout(-1, Int(duration), 0) { (isCompleted, workoutLogId) in
            TempoTrainerManager.shared.startTime = nil
            Helper.shared.log(event: .ENDWORKOUT, params: [:])
            if isCompleted{
                print("Workout completed successfully!!")
                let info = PreferenceManager.shared.trackingInfo
                if info.isDistanceTracking || info.isTempoTracking || self.viewModel.arrAchievements.count > 0{
                    let feedbackVC = FeedbackSheetViewController(nibName: "FeedbackSheetViewController", bundle: nil, workoutItem: WorkoutDTO(["id":-1]), achievements: self.viewModel.arrAchievements, workoutLogId: workoutLogId, timeElapsed: Int(timeInSeconds))
                    feedbackVC.isNoWorkoutMetric = true
                    feedbackVC.delegate = self
                    feedbackVC.modalPresentationStyle = .overFullScreen
                    self.present(feedbackVC, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func feedbackDiagnosticAction(_ sender: UIButton){
        
        BluetoothManager.shared.readDiagnosticData { diagnoseData in
            
            guard let feedback = diagnoseData else{
                return
            }
            
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setToRecipients(["frank@fdpdcsllc.com"])
                mail.setSubject("Zygo Diagnostic Data")
                mail.setMessageBody("Date: \(Date())\nHex Data: \(feedback)", isHTML: false)
                
                self.present(mail, animated: true)
                
                //}
            } else {
                Helper.shared.alert(title: Constants.appName, message: "Please configure email account on your device first.")
            }
            
        }
        
    }
}

//MARK: -
extension MetricsBTVC: MFMailComposeViewControllerDelegate{
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        
        if error != nil{
            Helper.shared.alert(title: Constants.appName, message: error!.localizedDescription)
        }
    }
}

extension MetricsBTVC: FeedbackSheetViewControllerDelegates{
    
    func feedbackDone() {
        Helper.shared.startLoading()
        self.viewModel.fetchLastCompletedWorkout {
            Helper.shared.stopLoading()
            if let savedWorkout = self.viewModel.lastSavedWorkout{
                self.updateSaveButtonStatus(savedWorkout: savedWorkout)
            }
        }
    }
}

extension MetricsBTVC: UIViewControllerTransitioningDelegate{
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentingAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissingAnimator()
    }
    
}
