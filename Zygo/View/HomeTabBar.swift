//
//  HomeTabBar.swift
//  Zygo
//
//  Created by Som on 18/04/21.
//  Copyright © 2021 Somparkash. All rights reserved.
//

import UIKit

class HomeTabBar: UITabBarController, UITabBarControllerDelegate {
let service = RegistrationServices()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        let token = PreferenceManager.shared.deviceToken
        service.updateDeviceToken(deviceToken: token) { (msg, isErr) in
            
        }
    }
}

extension HomeTabBar{
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let index = item.tag
        if index == 0{//Classes
            NotificationCenter.default.post(name: .didSelectClassesTab, object: nil)
        }else if index == 1{//Series
            NotificationCenter.default.post(name: .didSelectSeriesTab, object: nil)
        }else if index == 2{//Downloads
            NotificationCenter.default.post(name: .didSelectDownloadsTab, object: nil)
        }else if index == 3{//Pacing
            NotificationCenter.default.post(name: .didSelectPacingTab, object: nil)
        }else if index == 4{//Profile
            NotificationCenter.default.post(name: .didSelectProfileTab, object: nil)
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if tabBarController.selectedIndex == 4{
        
            
            let profileVC = self.viewControllers![4] as! ProfileViewController
            
            if profileVC.isProfileChanged(){
                profileVC.showProfileChangePopUp()
                return false
            }else{
                return true
            }
        }
        return true
    }
}
