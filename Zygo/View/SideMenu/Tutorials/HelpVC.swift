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
    
    @IBOutlet weak var lapCoutingView: UIView!
    @IBOutlet weak var lapCoutingViewHeightConstraint: NSLayoutConstraint!
    
    //MARK: - UIViewcontroller LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    //MARK: - Setups
    private func setupUI(){
        if environment == .production{
            self.lapCoutingView.isHidden = true
            self.lapCoutingViewHeightConstraint.constant = 0.0
        }else{
            self.lapCoutingView.isHidden = false
            self.lapCoutingViewHeightConstraint.constant = 59.0
        }
    }
    
    //MARK: - UIButton Actions
    @IBAction func backAction(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func getStartedAction(_ sender: UIButton){
        
        let deviceInfo = PreferenceManager.shared.deviceInfo
        if deviceInfo.versionInfo.zygoDeviceVersion == .v1{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "GetStartedVC") as! GetStartedVC
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            let vc = StoryboardScene.TutorialsZ2VC.tutorialsZ2VC.instantiate()
            vc.type = .getStarted
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        
    }
    
    @IBAction func PairingAction(_ sender: UIButton){
        let deviceInfo = PreferenceManager.shared.deviceInfo
        if deviceInfo.versionInfo.zygoDeviceVersion == .v1{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PairingVC") as! PairingVC
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            let vc = StoryboardScene.TutorialsZ2VC.tutorialsZ2VC.instantiate()
            vc.type = .pairing
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func chargingAction(_ sender: UIButton){
        let deviceInfo = PreferenceManager.shared.deviceInfo
        if deviceInfo.versionInfo.zygoDeviceVersion == .v1{
            let vc = ChargingAnimationVC(nibName: "ChargingAnimationVC", bundle: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            let vc = StoryboardScene.TutorialsZ2VC.tutorialsZ2VC.instantiate()
            vc.type = .charging
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func updateFirmwareAction(){
        let preVC = self.storyboard?.instantiateViewController(withIdentifier: "PreFirmwareUpdateVC") as! PreFirmwareUpdateVC
        self.navigationController?.pushViewController(preVC, animated: true)
    }
    
    @IBAction func countingLapAction(_ sender: UIButton){
        let deviceInfo = PreferenceManager.shared.deviceInfo
        if deviceInfo.versionInfo.zygoDeviceVersion == .v1{
            let preVC = self.storyboard?.instantiateViewController(withIdentifier: "CountingLapsAnimationVC") as! CountingLapsAnimationVC
            self.navigationController?.pushViewController(preVC, animated: true)
        }else{
            let vc = StoryboardScene.CountingLapsAnimaitionZ2VC.countingLapsAnimationZ2VC.instantiate()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func syncHeadsetAction(){
        let deviceInfo = PreferenceManager.shared.deviceInfo
        if deviceInfo.versionInfo.zygoDeviceVersion == .v1{
            let preVC = self.storyboard?.instantiateViewController(withIdentifier: "HeadsetSyncAnimationVC") as! HeadsetSyncAnimationVC
            self.navigationController?.pushViewController(preVC, animated: true)
        }else{
            let vc = StoryboardScene.TutorialsZ2VC.tutorialsZ2VC.instantiate()
            vc.type = .syncingWithHeadset
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
