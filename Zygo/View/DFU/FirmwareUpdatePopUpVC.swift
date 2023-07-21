//
//  FirmwareUpdatePopUpVC.swift
//  Zygo
//
//  Created by Som Parkash on 05/01/23.
//  Copyright © 2023 Somparkash. All rights reserved.
//

import UIKit

class FirmwareUpdatePopUpVC: UIViewController {
    
    @IBOutlet weak var bgImageView: UIImageView!
    
    @IBOutlet weak var remindLaterView: UIView!
    
    var onGo: (() -> Void)? = nil
    var onLater: (() -> Void)? = nil
    
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.showBGImage()
    }
    
    //MARK: - Setups
    func showBGImage(){
        self.bgImageView.alpha = 0.0
        UIView.animate(withDuration: 1.0) {
            self.bgImageView.alpha = 0.4
        }
    }
    
    func hideBGImage(){
        self.bgImageView.alpha = 0.0
    }
    
    func pushToFirmwareUpdate(){
        let preVC = UIStoryboard(name: "SideMenu", bundle: nil).instantiateViewController(withIdentifier: "PreFirmwareUpdateVC") as! PreFirmwareUpdateVC
        preVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(preVC, animated: true)
    }
    
    //MARK: - UIButton Actions
    @IBAction func backAction(_ sender: UIButton){
        self.hideBGImage()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func goAction(_ sender: UIButton){
        self.hideBGImage()
        self.pushToFirmwareUpdate()
        /*self.dismiss(animated: true) {
            self.onGo?()
        }*/
    }
    
    @IBAction func laterAction(_ sender: UIButton){
        
        self.remindLaterView.isHidden = false
        self.remindLaterView.alpha = 0.0
        
        UIView.animate(withDuration: 0.4) {
            self.remindLaterView.alpha = 1.0
        } completion: { isComplete in
            
        }
    }
    
    @IBAction func updateNowAction(_ sender: UIButton){
        self.hideBGImage()
        self.pushToFirmwareUpdate()
        /*self.dismiss(animated: true) {
            self.onGo?()
        }*/
    }
    
    @IBAction func remindMeLaterAction(_ sender: UIButton){
        self.hideBGImage()
        self.dismiss(animated: true) {
            self.onLater?()
        }
    }
    
    //MARK: -
}
