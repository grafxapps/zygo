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
    let userService = UserServices()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        Helper.shared.logUserIdentity()
        
        let token = PreferenceManager.shared.deviceToken
        service.updateDeviceToken(deviceToken: token) { (msg, isErr) in
            
        }
        
        userService.updateHomeCountry { (msg) in
            print("HOME COUNTRY RESPONSE: \(msg ?? "NULL")")
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
        
        //Stop navigate to profile screen in case of demo mode
        if viewController is ProfileViewController{
            if Helper.shared.isDemoMode{
                let alert = CustomAlertWithCloseVC(nibName: "CustomAlertWithCloseVC", bundle: nil, title: Constants.appName, message: "Start your free trial to access all of our content.", buttonTitle: "Subscribe") { (isYes) in
                    if isYes{
                        //Push To Subscribe screen
                        Helper.shared.pushToSubscriptionScreen(from: self)
                    }
                }
                
                alert.transitioningDelegate = self
                alert.modalPresentationStyle = .custom
                self.present(alert, animated: true, completion: nil)
                return false
            }
        }
        
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

extension HomeTabBar: UIViewControllerTransitioningDelegate{
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentingAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissingAnimator()
    }
    
}
