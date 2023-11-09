//
//  HeadsetNotConnectedVC.swift
//  Zygo
//
//  Created by Som Parkash on 17/01/23.
//  Copyright © 2023 Somparkash. All rights reserved.
//

import UIKit

class HeadsetNotConnectedVC: UIViewController {
    @IBOutlet weak var btnDone: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func backAction(_ sender: UIButton){
        if self.navigationController?.viewControllers.contains(where: { $0 is FirmwareUpdatePopUpVC }) ?? false{
            self.dismiss(animated: true)
            return
        }
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func tryAgainAction(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }

}
