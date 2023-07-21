//
//  HeadsetRestartAlertPopupVC.swift
//  Zygo
//
//  Created by Som Parkash on 23/12/22.
//  Copyright © 2022 Somparkash. All rights reserved.
//

import UIKit

class HeadsetRestartAlertPopupVC: UIViewController {
    
    @IBOutlet weak var lblMessage: UILabel!
    
    var onPopupClose: ((Bool) -> Void)?
    
    var skipMessage: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if !self.skipMessage.isEmpty{
            self.lblMessage.text = self.skipMessage
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
