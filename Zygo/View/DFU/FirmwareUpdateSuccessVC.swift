//
//  FirmwareUpdateSuccessVC.swift
//  Zygo
//
//  Created by Som Parkash on 17/12/22.
//  Copyright © 2022 Somparkash. All rights reserved.
//

import UIKit

class FirmwareUpdateSuccessVC: UIViewController {

    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var lblMessage: UILabel!
    var updatedTargetDevice: TargetDeviceCode?
    var viewModel: PreFirmwareUpdateViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateUI()
    }
    
    func updateUI(){
        
        let defaultMessage = "The firmware on your Zygo has been updated. Please restart your transmitter and headset to activate it. Wait until both units are on and the LEDs have stopped blinking before continuing."
        guard let targetDevice = updatedTargetDevice else{
            self.lblMessage.text = defaultMessage
            return
        }
        
        if targetDevice == .SILABS_Z2_HEADSET{
            self.lblMessage.text = "The firmware on your Zygo has been updated."
        }else{
            self.lblMessage.text = defaultMessage
        }
        
        self.btnDone.setTitle("DONE", for: .normal)
        /*viewModel.getFirmwareDetail { [weak self] isUpdate in
            if isUpdate{
                
                //Check If device is connected or not
                if !BluetoothManager.shared.isZygoDeviceConencted(){
                    //Show loading for device searching and connecting
                    self?.viewModel.arrFirmwares.removeAll()
                    return
                }
                
                Helper.shared.startLoading()
                self?.updateDeviceVersionInfo()
            }
        }*/
    }
    
    func updateDeviceVersionInfo(){
        BluetoothManager.shared.readHardwareInfo { [weak self] deviceInfo in
            
            Helper.shared.stopLoading()
            self?.viewModel.setupFirmwareDataWithDeviceVersions(infoItem: deviceInfo.versionInfo)
            
        }
    }
    
    @IBAction func backAction(_ sender: UIButton){
        
        if self.viewModel.arrFirmwares.count == 0{
            //pop to root controller
            if self.navigationController?.viewControllers.contains(where: { $0 is FirmwareUpdatePopUpVC }) ?? false{
                self.dismiss(animated: true)
                return
            }
            
            self.navigationController?.popToRootViewController(animated: true)
        }else{
            //Pop to firmware update screen
            let arrViewControllers = self.navigationController?.viewControllers ?? []
            if let firstIndex = arrViewControllers.firstIndex(where: { $0 is PreFirmwareUpdateVC }){
                let popVC = arrViewControllers[firstIndex]
                self.navigationController?.popToViewController(popVC, animated: true)
            }else{
                if self.navigationController?.viewControllers.contains(where: { $0 is FirmwareUpdatePopUpVC }) ?? false{
                    self.dismiss(animated: true)
                    return
                }
                
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
        
        
    }

}
