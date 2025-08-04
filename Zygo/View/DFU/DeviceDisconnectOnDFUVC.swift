//
//  DeviceDisconnectOnDFUVC.swift
//  Zygo
//
//  Created by Som Parkash on 23/05/23.
//  Copyright © 2023 Somparkash. All rights reserved.
//

import UIKit

class DeviceDisconnectOnDFUVC: UIViewController {
    
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblError: UILabel!
    
    var onPopupClose: ((Bool) -> Void)?
    
    private var skipMessage: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !self.skipMessage.isEmpty{
            self.lblMessage.text = self.skipMessage
        }
        
        self.lblError.text = "NOB"
        BluetoothManager.shared.readDeviceStatus { errorMessage in
            DispatchQueue.main.async {
                self.lblError.text = "DFU Status: \(errorMessage) NOB"
            }
        }
    }
    
    @IBAction func yesAction(_ sender: UIButton){
        self.dismiss(animated: true) {
            self.onPopupClose?(true)
        }
    }
    
    @IBAction func noAction(_ sender: UIButton){
        self.dismiss(animated: true) {
            self.onPopupClose?(false)
        }
    }
    
}
