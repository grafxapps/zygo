//
//  SomethingWentWrongVC.swift
//  Zygo
//
//  Created by Som Parkash on 05/01/23.
//  Copyright © 2023 Somparkash. All rights reserved.
//

import UIKit

class SomethingWentWrongVC: UIViewController {
    
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblError: UILabel!
    
    var onPopupClose: ((Bool) -> Void)?
    
    private var skipMessage: String = ""
    private var addOnErrorMessage: String = ""
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, additionalErrorMessage: String) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.addOnErrorMessage = additionalErrorMessage
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !self.skipMessage.isEmpty{
            self.lblMessage.text = self.skipMessage
        }
        
        self.lblError.text = "\(self.addOnErrorMessage)"
        BluetoothManager.shared.readDeviceStatus { errorMessage in
            DispatchQueue.main.async {
                self.lblError.text = "DFU Status: \(errorMessage) \(self.addOnErrorMessage)"
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
