//
//  HelpVC.swift
//  Zygo
//
//  Created by Som on 21/10/21.
//  Copyright © 2021 Somparkash. All rights reserved.
//

import UIKit

//MARK: -
class HelpVC: UIViewController {

    //MARK: - UIViewcontroller LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - Setups
    
    //MARK: - UIButton Actions
    @IBAction func backAction(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func chargingAction(_ sender: UIButton){
        let vc = ChargingAnimationVC(nibName: "ChargingAnimationVC", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func updateFirmwareAction(){
        let preVC = self.storyboard?.instantiateViewController(withIdentifier: "PreFirmwareUpdateVC") as! PreFirmwareUpdateVC
        self.navigationController?.pushViewController(preVC, animated: true)
    }

}
