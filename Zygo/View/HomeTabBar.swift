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
