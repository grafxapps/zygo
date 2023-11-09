//
//  ScreenRecordingProtoector.swift
//  Zygo
//
//  Created by Som on 07/07/21.
//  Copyright © 2021 Somparkash. All rights reserved.
//

import UIKit
import SideMenuSwift

class ScreenRecordingProtoector: NSObject {
    private var window: UIWindow? {
        //if #available(iOS 13.0, *) {
        return (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window
        //}
        //return (UIApplication.shared.delegate as? AppDelegate)?.window
    }
    
    func startPreventing() {
        //TODO: Enable for screen recording
        if !Helper.shared.isTestUser{
            NotificationCenter.default.removeObserver(self)
            NotificationCenter.default.addObserver(self, selector: #selector(preventScreenShoot), name: UIScreen.capturedDidChangeNotification, object: nil)
        }
    }
    
    @objc func preventScreenShoot() {
        //TODO: Enable for screen recording
        if !Helper.shared.isTestUser{
            if #available(iOS 13.0, *) {
                if UIScreen.main.isCaptured {
                    
                    guard let topVC = UIApplication.topViewController() else{
                        self.window?.isHidden = true
                        return
                    }
                    
                    if let lastVC = ((topVC as? SideMenuController)?.contentViewController as? NavigationController)?.viewControllers.last as? WorkoutPlayerViewController{
                        lastVC.pausePlayer()
                        
                        Helper.shared.alert(title: Constants.appName, message: "Screen recording has been disabled in Zygo to protect our music licensing rights.", isAutoDismiss: true) {
                            if UIScreen.main.isCaptured {
                                self.window?.isHidden = true
                            }
                        }
                    }
                } else {
                    window?.isHidden = false
                }
            }
        }
    }
    
    // MARK: - Deinit
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
