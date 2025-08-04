//
//  HeadsetDFUUpdateVerifyVC.swift
//  Zygo
//
//  Created by Som Parkash on 14/12/24.
//  Copyright © 2024 Somparkash. All rights reserved.
//

import UIKit

//MARK: -
class HeadsetDFUUpdateVerifyVC: UIViewController {

    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var onDFUUpdateSucess: (() -> Void)? = nil
    var onDFUUpdateFailed: (() -> Void)? = nil
    var firwmareVersion: String = ""
    //MARK: - UIViewcontroller LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicatorView.isHidden = true
        self.activityIndicatorView.stopAnimating()
    }
    
    //MARK: - Setups
    private func startConnecting(){
        self.activityIndicatorView.isHidden = false
        self.activityIndicatorView.startAnimating()
        self.continueButton.setTitle("CONNECTING", for: .normal)
        self.continueButton.isUserInteractionEnabled = false
        
        BLEConnectionManager.shared.stopScanning()
        BLEConnectionManager.shared.startAutoConnectScanning { [weak self] in
            self?.readBLEVersionInfo()
        }
    }
    
    private func readBLEVersionInfo(){
        BluetoothManager.shared.readHardwareInfo { [weak self] deviceInfo in
            DispatchQueue.main.async {
                if deviceInfo.versionInfo.headsetVersion == self?.firwmareVersion ?? ""{
                    self?.dismiss(animated: true, completion: {
                        self?.onDFUUpdateSucess?()
                    })
                }else{
                    self?.dismiss(animated: true, completion: {
                        self?.onDFUUpdateFailed?()
                    })
                }
            }
        }
    }
    
    //MARK: - UIButton Actions
    @IBAction private func continueButtonPressed(_ sender: UIButton){
        startConnecting()
    }
    
    
    //MARK: -

}
