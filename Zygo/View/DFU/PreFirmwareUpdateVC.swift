//
//  PreFirmwareUpdateVC.swift
//  Zygo
//
//  Created by Som Parkash on 12/12/22.
//  Copyright © 2022 Somparkash. All rights reserved.
//

import UIKit

//MARK: -
class PreFirmwareUpdateVC: UIViewController {

    @IBOutlet weak var tblFirmwares: UITableView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var searchingView: UIView!
    
    private let viewModel = PreFirmwareUpdateViewModel()
    
    @IBOutlet weak var lblNotes: UILabel!
    
    //MARK: - UIViewController LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notesAttStrin = NSAttributedString(string: "This feature is only available on units with a headset serial number that begins with “ZY4”.", attributes: [.font: UIFont.appMediumItalic(with: 14.0)])
        self.lblNotes.attributedText = notesAttStrin
        
        self.registerCustomCells()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addObservers()
        self.updateUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeObservers()
        NSObject.cancelPreviousPerformRequests(withTarget: self)
    }
    
    //MARK: - Setups
    func addObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.removeObservers), name: .removeObservers, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateUI), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc func removeObservers(){
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func updateUI(){
        
        //viewModel.getFirmwareDetail { [weak self] isUpdate in
            //if isUpdate{
                //self?.tblFirmwares.reloadData()
                
                //Check If device is connected or not
                if !BluetoothManager.shared.isZygoDeviceConencted(){
                    //Show loading for device searching and connecting
                    self.showBGView()
                    self.showSearchingView()
                    self.startDeviceSearching()
                    return
                }
                
                Helper.shared.startLoading()
                self.updateDeviceVersionInfo()
            //}
        //}
    }
    
    
    func hideBGView(){
        UIView.animate(withDuration: 0.7) {
            self.bgView.alpha = 0.0
        } completion: { isCompleted in
            self.bgView.isHidden = true
        }
    }
    
    func showBGView(){
        if !self.bgView.isHidden{
            return
        }
        
        self.bgView.isHidden = false
        self.bgView.alpha = 0.0
        UIView.animate(withDuration: 0.7) {
            self.bgView.alpha = 1.0
        } completion: { isCompleted in
        }
    }
    
    func hideSearchingView(){
        UIView.animate(withDuration: 0.7) {
            self.searchingView.alpha = 0.0
            self.lblNotes.alpha = 0.0
        } completion: { isCompleted in
            self.searchingView.isHidden = true
            self.lblNotes.isHidden = true
        }
    }
    
    func showSearchingView(){
        if !self.searchingView.isHidden{
            return
        }
        
        self.lblNotes.isHidden = false
        self.lblNotes.alpha = 0.0
        self.searchingView.isHidden = false
        self.searchingView.alpha = 0.0
        UIView.animate(withDuration: 0.7) {
            self.searchingView.alpha = 1.0
            self.lblNotes.alpha = 1.0
        } completion: { isCompleted in
            
        }
    }
    
    func registerCustomCells(){
        self.tblFirmwares.separatorStyle = .none
        self.tblFirmwares.register(UINib(nibName: PreFirmwareTVC.identifier, bundle: nil), forCellReuseIdentifier: PreFirmwareTVC.identifier)
    }
    
    
    func startDeviceSearching(_ isForVersionInfo: Bool = false){
        BLEConnectionManager.shared.stopScanning()
        BLEConnectionManager.shared.startAutoConnectScanning { [weak self] in
            if isForVersionInfo{
                self?.versionInfoAction(UIButton())
            }else{
                self?.updateDeviceVersionInfo()
            }
            
        }
    }
    
    @objc func updateDeviceVersionInfo(){
        BluetoothManager.shared.readHardwareInfo { [weak self] deviceInfo in
            
            guard let strongSelf = self else{
                Helper.shared.stopLoading()
                return
            }
            strongSelf.viewModel.bleDeviceInfor = deviceInfo
            if deviceInfo.versionInfo.isVersionZero(){
                
                Helper.shared.stopLoading()
                self?.showBGView()
                self?.showSearchingView()
                
                
                //Again read version info after 5 seconds
                NSObject.cancelPreviousPerformRequests(withTarget: strongSelf)
                self?.perform(#selector(self?.updateDeviceVersionInfo), with: nil, afterDelay: 5.0)
                return
            }
            
            if deviceInfo.versionInfo.headsetVersion == "0"{
                //It means headset not connected yet then push to not connected vc
                Helper.shared.stopLoading()
                if let notConnectedVC = self?.storyboard?.instantiateViewController(withIdentifier: "HeadsetNotConnectedVC"){
                    self?.navigationController?.pushViewController(notConnectedVC, animated: true)
                }
                return
            }
            
            self?.viewModel.getFirmwareDetail { [weak self] isUpdate in
                Helper.shared.stopLoading()
                
                if isUpdate{
                    self?.tblFirmwares.reloadData()
                    
                    self?.hideBGView()
                    self?.viewModel.setupFirmwareDataWithDeviceVersions(infoItem: deviceInfo.versionInfo)
                    self?.tblFirmwares.reloadData()
                    
                    if self?.viewModel.arrFirmwares.count ?? 0 == 0{
                        //Push to already updated screen
                        
                        if let alreadyVC = self?.storyboard?.instantiateViewController(withIdentifier: "AlreadyUpdatedVC"){
                            self?.navigationController?.pushViewController(alreadyVC, animated: true)
                        }
                    }
                }
            }
        }
    }
    
    
    
    //MARK: - UIButton Actions
    @IBAction func backAction(_ sender: UIButton){
        if self.navigationController?.viewControllers.contains(where: { $0 is FirmwareUpdatePopUpVC }) ?? false{
            self.dismiss(animated: true)
            return
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func versionInfoAction(_ sender: UIButton){
        
        if !BluetoothManager.shared.isZygoDeviceConencted(){
            //Show loading for device searching and connecting
            self.showBGView()
            self.showSearchingView()
            self.startDeviceSearching(true)
            return
        }
        Helper.shared.stopLoading()
        self.hideBGView()
        
        Helper.shared.startLoading()
        BluetoothManager.shared.readHardwareInfo { [weak self] deviceInfo in
            Helper.shared.stopLoading()
            
            let versionVC = VersionInfoPopupVC(nibName: "VersionInfoPopupVC", bundle: nil)
            versionVC.transitioningDelegate = self
            versionVC.modalPresentationStyle = .custom
            versionVC.versionItem = deviceInfo.versionInfo
            self?.present(versionVC, animated: true)
            
        }
    }
    
    @objc func updateAction(_ sender: UIButton){
        let index = sender.tag
        if index >= self.viewModel.arrFirmwares.count{
            return
        }
        
        let item = self.viewModel.arrFirmwares[index]
        
        if item.targetDevice == .SILABS_HEADSET{//Check Headset Battery Level
            if let bleInfo = self.viewModel.bleDeviceInfor{
                if bleInfo.headsetBatteryLevel < 50 && bleInfo.radioBatteryLevel < 50{
                    Helper.shared.alert(title: Constants.appName, message: "Please charge your Zygo transmitter and headset before performing a firmware update.")
                    return
                }else if bleInfo.headsetBatteryLevel < 50{
                    Helper.shared.alert(title: Constants.appName, message: "Please charge your Zygo headset before performing a firmware update.")
                   return
                }else if bleInfo.radioBatteryLevel < 50{
                    Helper.shared.alert(title: Constants.appName, message: "Please charge your Zygo transmitter before performing a firmware update.")
                   return
                }
            }
        }else{//Check Radio Battery Level
            if let bleInfo = self.viewModel.bleDeviceInfor{
                if bleInfo.radioBatteryLevel < 50{
                    Helper.shared.alert(title: Constants.appName, message: "Please charge your Zygo transmitter before performing a firmware update.")
                   return
                }
            }
        }
        
        if item.targetDevice == .SILABS_HEADSET{
            let alertVC = HeadsetRestartAlertPopupVC(nibName: "HeadsetRestartAlertPopupVC", bundle: nil)
            alertVC.transitioningDelegate = self
            alertVC.modalPresentationStyle = .custom
            alertVC.onPopupClose = { isYes in
                let updateVC = self.storyboard?.instantiateViewController(withIdentifier: "FirmwareUpdateVC") as! FirmwareUpdateVC
                updateVC.arrFirmwares = [item]
                updateVC.preFirmwareViewModel = self.viewModel
                self.navigationController?.pushViewController(updateVC, animated: true)
                
            }
            self.present(alertVC, animated: true)
            
            return
        }
        
        let updateVC = self.storyboard?.instantiateViewController(withIdentifier: "FirmwareUpdateVC") as! FirmwareUpdateVC
        updateVC.arrFirmwares = [item]
        updateVC.preFirmwareViewModel = self.viewModel
        self.navigationController?.pushViewController(updateVC, animated: true)
        
    }
    
    @IBAction func skipAction(_ sender: UIButton){
        
        let skipVC = SkipDFUPopupVC(nibName: "SkipDFUPopupVC", bundle: nil)
        skipVC.transitioningDelegate = self
        skipVC.modalPresentationStyle = .custom
        let message = self.viewModel.arrFirmwares.map({ $0.skipText + "\n" }).joined()
        skipVC.skipMessage = message
        skipVC.onPopupClose = { [weak self] isYes in
            if isYes{
                if self?.navigationController?.viewControllers.contains(where: { $0 is FirmwareUpdatePopUpVC }) ?? false{
                    self?.dismiss(animated: true)
                    return
                }
                
                self?.navigationController?.popViewController(animated: true)
            }
        }
        
        self.present(skipVC, animated: true, completion: nil)
    }
    
    //MARK: -

}

//MARK: - UITableView DataSources and Delegates
extension PreFirmwareUpdateVC: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.arrFirmwares.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PreFirmwareTVC.identifier) as! PreFirmwareTVC
        cell.selectionStyle = .none

        let item = self.viewModel.arrFirmwares[indexPath.row]
        let minimumTargetCode = self.viewModel.arrFirmwares.map({ $0.targetDevice.rawValue }).min() ?? UInt8(100)
        
        if item.targetDevice.rawValue <= minimumTargetCode{
            cell.btnUpdate.alpha = 1.0
            cell.btnUpdate.isUserInteractionEnabled = true
        }else{
            cell.btnUpdate.alpha = 0.4
            cell.btnUpdate.isUserInteractionEnabled = false
        }
       
        
        cell.lblMessage.text = item.newText
        
        cell.btnUpdate.tag = indexPath.row
        cell.btnUpdate.addTarget(self, action: #selector(self.updateAction(_:)), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension PreFirmwareUpdateVC: UIViewControllerTransitioningDelegate{
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentingAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissingAnimator()
    }
    
}
