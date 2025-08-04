//
//  FirmwareUpdateVC.swift
//  Zygo
//
//  Created by Som Parkash on 12/12/22.
//  Copyright © 2022 Somparkash. All rights reserved.
//

import UIKit

//MARK: -
class FirmwareUpdateVC: UIViewController {

    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var btnGoBack: UIButton!
    
    @IBOutlet weak var txtStatus: UITextView!
    
    @IBOutlet weak var firmwareDownloadView: UIView!
    @IBOutlet weak var firmwareProcessView: UIView!
    @IBOutlet weak var lblFirmwareProcess: UILabel!
    
    @IBOutlet weak var headsetUpdateStatusIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var tblStatus: UITableView!
    
    private var statusValue: String = ""
    private var isFirmwarePricessAlreadyShow: Bool = false
    private var isFirmwareDone: Bool = false
    private let viewModel = FirmwareUpdateViewModel()
    var preFirmwareViewModel: PreFirmwareUpdateViewModel!
    private var isBackPressed: Bool = false
    
    var arrFirmwares: [FirmwareDTO] = []
    var currentFirmwareIndex: Int = 0
    
    //MARK: - UIViewcontroller LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerCustomCells()
        self.viewModel.createStatus(for: arrFirmwares[currentFirmwareIndex].targetDevice)
        self.tblStatus.reloadData()
        let firmware = arrFirmwares[currentFirmwareIndex]
        self.preFirmwareViewModel.arrFirmwares.removeAll(where: { $0.targetDevice == firmware.targetDevice })
        self.startProcess(firmware)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    //MARK: - Setups
    func registerCustomCells(){
        self.tblStatus.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        self.tblStatus.separatorStyle = .none
        self.tblStatus.register(UINib(nibName: FirmwareStatusTVC.identifier, bundle: nil), forCellReuseIdentifier: FirmwareStatusTVC.identifier)
    }
    
    func updateStatus(for type: DFUStatusType, status: FirmwareStatusType){
        
        if let index = self.viewModel.arrStatus.firstIndex(where: { $0.type == type }){
            self.viewModel.arrStatus[index].statusType = status
            self.tblStatus.scrollToRow(at: IndexPath(row: index, section: 0), at: .middle, animated: true)
        }
        
        self.tblStatus.reloadData()
    }
    
    func startProcess(_ firmware: FirmwareDTO){
        
        //First Check if device is connect or not and then upgrade te firmaware
        if !BluetoothManager.shared.isZygoDeviceConencted(){
            self.viewModel.arrStatus.insert(FirmwareStatusDTO(title: "Entering data transfer mode", type: .Connecting, statusType: .inprogress), at: 0)
            self.tblStatus.reloadData()
            self.statusValue += "Entering data transfer mode\n"
            self.txtStatus.text = self.statusValue
            BLEConnectionManager.shared.startAutoConnectScanning {
                self.startProcess(firmware)
            }
            return
        }
        
        self.updateStatus(for: .Connecting, status: .completed)
        self.updateStatus(for: .Connected, status: .completed)
        self.updateStatus(for: .SubscribeDevice, status: .inprogress)
        self.statusValue += "Connection established\n"
        self.txtStatus.text = self.statusValue
        self.btnDone.isUserInteractionEnabled = false
        
        //Download File from URL
        self.firmwareDownloadView.isHidden = false
        self.firmwareDownloadView.alpha = 0.0
        UIView.animate(withDuration: 0.4) {
            self.firmwareDownloadView.alpha = 1.0
        } completion: { isCompleted in
            
        }
        
        ZygoWorkoutDownloadManager.shared.download(firmware: firmware) { identifier, progress in
            
        } onDownloadComplete: { isDownloaded in
            if !isDownloaded{
                print("Download failed")
                if !self.isBackPressed{
                    Helper.shared.alert(title: Constants.appName, message: "Firmware downloading failed. Please check your network connection and try again."){
                        self.backActionProcess()
                    }
                }
                return
            }
            
            UIView.animate(withDuration: 0.4) {
                self.firmwareDownloadView.alpha = 0.0
            } completion: { isCompleted in
                self.firmwareDownloadView.isHidden = true
            }
            
            let firmwareIdentifier = "\(firmware.targetDevice.rawValue)\(firmware.version)"
            let filePath = ZygoWorkoutDownloadManager.shared.getFirmwarePath(firmwareIdentifier: "\(firmwareIdentifier)")
            let url = URL(fileURLWithPath: filePath)//URL(string: filePath)!
            
            
            
            
            BluetoothManager.shared.startDFUProcess(firmwareURL: url, target: firmware.targetDevice){ value in
                DispatchQueue.main.async {
                    self.progressView.setProgress(value, animated: true)
                }
            } statusUpdate: { status in
                DispatchQueue.main.async {
                    
                    switch status {
                    case.SubscribeDevice:
                        self.updateStatus(for: .SubscribeDevice, status: .completed)
                        self.updateStatus(for: .SetTargetDevice, status: .inprogress)
                        self.statusValue += "Setting up transfer\n"
                    case .SetTargetDevice:
                        self.updateStatus(for: .SetTargetDevice, status: .completed)
                        self.updateStatus(for: .TransferRequestStart, status: .inprogress)
                        self.statusValue += "Set target device\n"
                    case .TransferRequestStart:
                        self.updateStatus(for: .TransferRequestStart, status: .completed)
                        self.updateStatus(for: .TransferFile, status: .inprogress)
                        self.statusValue += "Start transfer\n"
                    case .TransferFile:
                        self.updateStatus(for: .TransferFile, status: .inprogress)
                        self.statusValue += "Transferring files\n"
                    case .TransferProccess(let progress):
                        
                        if !self.isFirmwarePricessAlreadyShow{
                            self.isFirmwarePricessAlreadyShow = true
                            
                            self.firmwareProcessView.isHidden = false
                            self.firmwareProcessView.alpha = 0.0
                            
                            UIView.animate(withDuration: 0.4) {
                                self.firmwareProcessView.alpha = 1.0
                            }
                        }
                        self.lblFirmwareProcess.text = "\(progress)%"
                        
                    case .TransferFileFailed:
                        self.statusValue += "Transfer failed\n"
                        
                        let skipVC = SomethingWentWrongVC(nibName: "SomethingWentWrongVC", bundle: nil, additionalErrorMessage: "File Transfer Failed")
                        skipVC.transitioningDelegate = self
                        skipVC.modalPresentationStyle = .custom
                        skipVC.onPopupClose = { [weak self] isYes in
                            if isYes{
                                self?.backActionProcess()
                            }
                        }
                        self.present(skipVC, animated: true)
                        
                    /*Helper.shared.alert(title: Constants.appName, message: "Transfer failed. Try again after restarting your Zygo."){
                            self.backActionProcess()
                        }*/
                    case .TransferRequestStop:
                        self.updateStatus(for: .TransferFile, status: .completed)
                        self.updateStatus(for: .TransferRequestStop, status: .completed)
                        self.statusValue += "Confirming update\n"
                    case .FirmwareUpgraded:
                        self.updateStatus(for: .FirmwareUpgraded, status: .completed)
                        self.firmwareProcessView.isHidden = true
                        self.isFirmwarePricessAlreadyShow = false
                        if firmware.targetDevice == .ESP{
                            self.statusValue += "Files successfully transferred to the radio\n"
                        }else{
                            self.statusValue += "Update completed successfully\n"
                        }
                        
                    case .FirmwareUpgradedFailed:
                        self.stopHeadsetStatusTimer()
                        self.firmwareProcessView.isHidden = true
                        self.isFirmwarePricessAlreadyShow = false
                        self.statusValue += "Update failed. Please try again.\n"
                        if !self.isBackPressed{
                            /*Helper.shared.alert(title: Constants.appName, message: "Update failed. Please try again after restarting the device."){
                                self.backActionProcess()
                            }*/
                            
                            let skipVC = SomethingWentWrongVC(nibName: "SomethingWentWrongVC", bundle: nil, additionalErrorMessage: "Firmware Upgraded Failed")
                            skipVC.transitioningDelegate = self
                            skipVC.modalPresentationStyle = .custom
                            skipVC.onPopupClose = { [weak self] isYes in
                                if isYes{
                                    self?.backActionProcess()
                                }
                            }
                            self.present(skipVC, animated: true)
                        }
                    case .TimeOutError:
                        self.stopHeadsetStatusTimer()
                        let skipVC = SomethingWentWrongVC(nibName: "SomethingWentWrongVC", bundle: nil, additionalErrorMessage: "NOR")
                        skipVC.transitioningDelegate = self
                        skipVC.modalPresentationStyle = .custom
                        skipVC.onPopupClose = { [weak self] isYes in
                            if isYes{
                                self?.backActionProcess()
                            }
                        }
                        self.present(skipVC, animated: true)
                        
                        /*Helper.shared.alert(title: Constants.appName, message: "Something went wrong during the update. Please restart your device and try again."){
                            self.backActionProcess()
                        }*/
                    case .HeadsetProgressStatus:
                        DispatchQueue.main.async {
                            if !self.isFirmwarePricessAlreadyShow{
                                self.isFirmwarePricessAlreadyShow = true
                                
                                self.headsetUpdateStatusIndicator.isHidden = false
                                
                                self.firmwareProcessView.isHidden = false
                                self.firmwareProcessView.alpha = 0.0
                                
                                UIView.animate(withDuration: 0.4) {
                                    self.firmwareProcessView.alpha = 1.0
                                }
                                
                            }
                            
                            self.startHeadsetStatusTimer()
                            self.lblFirmwareProcess.text = " "
                        }
                        //self.perform(#selector(self.getStatus), with: nil, afterDelay: 2.0)
                    case .DeviceDisconnected:
                        self.stopHeadsetStatusTimer()
                        //Wait for max 1 minutes and 30 seconds for device to get reconnect after DFU if still not able to connect with device then show disconnect popup
                        self.isWaitingForDeviceReconnect = true
                        self.startDeviceReconnectTimer()
                        BLEConnectionManager.shared.startAutoConnectScanning {
                            DispatchQueue.main.async {
                                self.isWaitingForDeviceReconnect = false
                                self.stopDeviceReconnectTimer()
                                
                                if self.isHeadsetProgress{
                                    BluetoothManager.shared.startReadLastSyncTimer()
                                }

                            }
                        }
                        
                    case .FailedToSubscribedRequest:
                        let skipVC = SomethingWentWrongVC(nibName: "SomethingWentWrongVC", bundle: nil, additionalErrorMessage: "Failed To Subscribed Request")
                        skipVC.transitioningDelegate = self
                        skipVC.modalPresentationStyle = .custom
                        skipVC.onPopupClose = { [weak self] isYes in
                            if isYes{
                                self?.backActionProcess()
                            }
                        }
                        self.present(skipVC, animated: true)
                        
                    case .FailedToSetDeviceId:
                        let skipVC = SomethingWentWrongVC(nibName: "SomethingWentWrongVC", bundle: nil, additionalErrorMessage: "Failed To Set Device Id")
                        skipVC.transitioningDelegate = self
                        skipVC.modalPresentationStyle = .custom
                        skipVC.onPopupClose = { [weak self] isYes in
                            if isYes{
                                self?.backActionProcess()
                            }
                        }
                        self.present(skipVC, animated: true)
                        
                    case .FailedToStartTransferRequest:
                        let skipVC = SomethingWentWrongVC(nibName: "SomethingWentWrongVC", bundle: nil, additionalErrorMessage: "Failed To Start Transfer Request")
                        skipVC.transitioningDelegate = self
                        skipVC.modalPresentationStyle = .custom
                        skipVC.onPopupClose = { [weak self] isYes in
                            if isYes{
                                self?.backActionProcess()
                            }
                        }
                        self.present(skipVC, animated: true)
                        
                    case .FailedToSendData:
                        let skipVC = SomethingWentWrongVC(nibName: "SomethingWentWrongVC", bundle: nil, additionalErrorMessage: "NAK")
                        skipVC.transitioningDelegate = self
                        skipVC.modalPresentationStyle = .custom
                        skipVC.onPopupClose = { [weak self] isYes in
                            if isYes{
                                self?.backActionProcess()
                            }
                        }
                        self.present(skipVC, animated: true)
                        
                    case .FailedToTransferDone:
                        let skipVC = SomethingWentWrongVC(nibName: "SomethingWentWrongVC", bundle: nil, additionalErrorMessage: "Failed To Transfer Done")
                        skipVC.transitioningDelegate = self
                        skipVC.modalPresentationStyle = .custom
                        skipVC.onPopupClose = { [weak self] isYes in
                            if isYes{
                                self?.backActionProcess()
                            }
                        }
                        self.present(skipVC, animated: true)
                        
                    }
                    
                    self.txtStatus.text = self.statusValue
                }
                
                
            } completion: { isCompleted in
                DispatchQueue.main.async {
                    self.stopHeadsetStatusTimer()
                    self.isHeadsetProgress = false
                    if isCompleted{
                        print("File Upgraded Successfully.")
                        self.btnDone.isUserInteractionEnabled = true
                        
                        let currentIndex = self.currentFirmwareIndex
                        self.currentFirmwareIndex += 1
                        if self.currentFirmwareIndex < self.arrFirmwares.count{
                            self.startProcess(self.arrFirmwares[self.currentFirmwareIndex])
                        }else{
                            let targetDevice = firmware.targetDevice
                            
                            self.currentFirmwareIndex = 0
                            //Push To Restart Device Screen.
                            if !self.isFirmwareDone{
                                self.isFirmwareDone = true
                                BluetoothManager.shared.resetDFUProcess()
                                
                                
                                //Here read HS Rev for z2 only if not matched with updated one then show error message
                                if PreferenceManager.shared.deviceInfo.versionInfo.zygoDeviceVersion == .v2{
                                    
                                    if targetDevice == .SILABS_Z2_HEADSET{
                                        
                                        if BluetoothManager.shared.isZygoDeviceConencted(){
                                            BluetoothManager.shared.disconnectCurrentDevice()
                                        }
                                        Helper.shared.startLoading()
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0){
                                            Helper.shared.stopLoading()
                                            let vc  = StoryboardScene.HeadsetDFUUpdateVerifyVC.headsetDFUUpdateVerifyVC.instantiate()
                                            vc.firwmareVersion = self.arrFirmwares[currentIndex].version
                                            vc.onDFUUpdateFailed = {
                                                //Show error message
                                                let skipVC = SomethingWentWrongVC(nibName: "SomethingWentWrongVC", bundle: nil, additionalErrorMessage: "Failed To Write on Headset.")
                                                skipVC.transitioningDelegate = self
                                                skipVC.modalPresentationStyle = .custom
                                                skipVC.onPopupClose = { [weak self] isYes in
                                                    if isYes{
                                                        self?.backActionProcess()
                                                    }
                                                }
                                                self.present(skipVC, animated: true)
                                            }
                                            
                                            vc.onDFUUpdateSucess = {
                                                let successVC = self.storyboard?.instantiateViewController(withIdentifier: "FirmwareUpdateSuccessVC") as! FirmwareUpdateSuccessVC
                                                successVC.updatedTargetDevice = .SILABS_Z2_HEADSET
                                                successVC.viewModel = self.preFirmwareViewModel
                                                self.navigationController?.pushViewController(successVC, animated: true)
                                            }
                                            vc.transitioningDelegate = self
                                            vc.modalPresentationStyle = .custom
                                            self.present(vc, animated: true)
                                        }
                                    }else{
                                        let successVC = self.storyboard?.instantiateViewController(withIdentifier: "FirmwareUpdateSuccessVC") as! FirmwareUpdateSuccessVC
                                        successVC.viewModel = self.preFirmwareViewModel
                                        self.navigationController?.pushViewController(successVC, animated: true)
                                    }
                                }else{
                                    let successVC = self.storyboard?.instantiateViewController(withIdentifier: "FirmwareUpdateSuccessVC") as! FirmwareUpdateSuccessVC
                                    successVC.viewModel = self.preFirmwareViewModel
                                    self.navigationController?.pushViewController(successVC, animated: true)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    var statusTimer: Timer?
    var isHeadsetProgress: Bool = false
    func startHeadsetStatusTimer(){
        self.stopHeadsetStatusTimer()
        self.isHeadsetProgress = true
        self.statusTimer = Timer(timeInterval: 5.0, repeats: false, block: { timerObj in
            DispatchQueue.main.async {
                self.getStatus()
            }
        })
        
        RunLoop.main.add(self.statusTimer!, forMode: .common)
    }
    
    func stopHeadsetStatusTimer(){
        self.statusTimer?.invalidate()
        self.statusTimer = nil
    }
    
    
    var deviceReconnectTimer: Timer?
    var isWaitingForDeviceReconnect: Bool = false
    func startDeviceReconnectTimer(){
        self.stopDeviceReconnectTimer()
        self.deviceReconnectTimer = Timer(timeInterval: 90.0, repeats: false, block: { timerObj in
            DispatchQueue.main.async {
                BLEConnectionManager.shared.stopScanning()
                //Check if device is connected or not
                if self.isWaitingForDeviceReconnect{
                    //Show not connected popup
                    let skipVC = DeviceDisconnectOnDFUVC(nibName: "DeviceDisconnectOnDFUVC", bundle: nil)
                    skipVC.transitioningDelegate = self
                    skipVC.modalPresentationStyle = .custom
                    skipVC.onPopupClose = { [weak self] isYes in
                        if isYes{
                            self?.backActionProcess()
                        }
                    }
                    self.present(skipVC, animated: true)
                }
            }
        })
        
        RunLoop.main.add(self.deviceReconnectTimer!, forMode: .common)
    }
    
    func stopDeviceReconnectTimer(){
        self.deviceReconnectTimer?.invalidate()
        self.deviceReconnectTimer = nil
    }
    
    
    @objc func getStatus(){
        BluetoothManager.shared.getHeadsetProgressStatus()
        /*BluetoothManager.shared.checkHeadsetProgess { dfuStaus, progressStatus in
            DispatchQueue.main.async {
                print("DFU Status: \(dfuStaus)")
                print("progressStatus Status: \(progressStatus)")
                if progressStatus != 1{//In Progress
                    BluetoothManager.shared.getHeadsetProgressStatus()
                }
            }
        }*/
    }
    
    //MARK: - UIButton Actions
    @IBAction func doneAction(_ sender: UIButton){
        if self.navigationController?.viewControllers.contains(where: { $0 is FirmwareUpdatePopUpVC }) ?? false{
            self.dismiss(animated: true)
            return
        }
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func backAction(_ sender: UIButton){
        
        let skipVC = DFUStopPopupVC(nibName: "DFUStopPopupVC", bundle: nil)
        skipVC.transitioningDelegate = self
        skipVC.modalPresentationStyle = .custom
        skipVC.onPopupClose = { [weak self] isYes in
            if isYes{
                self?.isBackPressed = true
                self?.backActionProcess()
            }
        }
        self.present(skipVC, animated: true)
    }
    
    func backActionProcess(){
        BluetoothManager.shared.disconnectCurrentDevice()
        let firmware = self.arrFirmwares[currentFirmwareIndex]
        ZygoWorkoutDownloadManager.shared.cancelFirmwareDownloads(firmware: firmware)
        BluetoothManager.shared.terminateTransferFile()
        
        let arrViewControllers = self.navigationController?.viewControllers ?? []
        if let firstIndex = arrViewControllers.firstIndex(where: { $0 is PreFirmwareUpdateVC }){
            let popVC = arrViewControllers[firstIndex]
            self.navigationController?.popToViewController(popVC, animated: true)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
}

extension FirmwareUpdateVC: UIViewControllerTransitioningDelegate{
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentingAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissingAnimator()
    }
    
}

//MARK: - UITableView DataSoruces and Delegates
extension FirmwareUpdateVC: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.arrStatus.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FirmwareStatusTVC") as! FirmwareStatusTVC
        let item = self.viewModel.arrStatus[indexPath.row]
        cell.selectionStyle = .none
        cell.lblTitle.text = item.title
        cell.lblTitle.alpha = 1.0
        
        cell.progress.isHidden = true
        cell.stausImageView.isHidden = true
        
        switch item.statusType{
        case .pending:
            
            cell.lblTitle.alpha = 0.5
            
            cell.progress.isHidden = true
            cell.stausImageView.isHidden = true
            
        case .completed:
            cell.lblTitle.alpha = 1.0
            
            cell.progress.isHidden = true
            cell.stausImageView.isHidden = false
            
            cell.stausImageView.image = UIImage(named: "icon_check_circle")
            
        case .inprogress:
            cell.lblTitle.alpha = 1.0
            
            cell.progress.isHidden = false
            cell.progress.startAnimating()
            cell.stausImageView.isHidden = true
            
        case .failed:
            cell.lblTitle.alpha = 1.0
            
            cell.progress.isHidden = true
            cell.stausImageView.isHidden = true
            
            cell.stausImageView.image = UIImage(named: "icon_check_circle")
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
