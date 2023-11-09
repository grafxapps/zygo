//
//  AlreadyUpdatedVC.swift
//  Zygo
//
//  Created by Som Parkash on 30/11/22.
//  Copyright © 2022 Somparkash. All rights reserved.
//

import UIKit

class AlreadyUpdatedVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func versionInfoAction(_ sender: UIButton){
        Helper.shared.startLoading()
        BluetoothManager.shared.readHardwareInfo { [weak self] deviceInfo in
            Helper.shared.stopLoading()
            
            let versionVC = VersionInfoPopupVC(nibName: "VersionInfoPopupVC", bundle: nil)
            versionVC.transitioningDelegate = self
            versionVC.modalPresentationStyle = .custom
            versionVC.versionItem = deviceInfo.versionInfo
            self?.present(versionVC, animated: true)
            
        }
    }

    @IBAction func backACtion(_ sender: UIButton){
        if self.navigationController?.viewControllers.contains(where: { $0 is FirmwareUpdatePopUpVC }) ?? false{
            self.dismiss(animated: true)
            return
        }
        self.navigationController?.popToRootViewController(animated: true)
    }
}

extension AlreadyUpdatedVC: UIViewControllerTransitioningDelegate{
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentingAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissingAnimator()
    }
    
}
