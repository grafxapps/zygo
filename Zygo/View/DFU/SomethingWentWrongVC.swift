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
