//
//  VersionInfoPopupVC.swift
//  Zygo
//
//  Created by Som Parkash on 21/12/22.
//  Copyright © 2022 Somparkash. All rights reserved.
//

import UIKit

class VersionInfoPopupVC: UIViewController {

    @IBOutlet weak var stView: UIView!
    
    @IBOutlet weak var lblESP: UILabel!
    @IBOutlet weak var lblST: UILabel!
    @IBOutlet weak var lblSL: UILabel!
    @IBOutlet weak var lblHeadset: UILabel!
    
    var versionItem = BLEVersionInfoDTO([:])
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.updateInfo()
    }

    func updateInfo(){
        
        if versionItem.zygoDeviceVersion == .v2{
            stView.isHidden = true
        }
        
        self.lblESP.text = "ESP: \(versionItem.ESPVersion)"
        self.lblST.text = "Radio ST: \(versionItem.radioSTVersion)"
        self.lblSL.text = "Radio SL: \(versionItem.radioSLVersion)"
        self.lblHeadset.text = "Headset: \(versionItem.headsetVersion)"
    }
    
    @IBAction func backAction(_ sender: UIButton){
        self.dismiss(animated: true)
    }

}
