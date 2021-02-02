//
//  Helper.swift
//  Zygo
//
//  Created by Priya Gandhi on 23/01/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit

final class Helper: NSObject {
    
    static let shared = Helper()
    
    private override init() {
    }
    
    func startLoading() {
        
        let activityData = ActivityData.init(size: Constants.loaderSize, type: NVActivityIndicatorType.lineScale)
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
    }
    
    func stopLoading() {
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
    }
    func setupViewLayer(sender: UIView, isSsubScriptionView: Bool) {
        sender.layer.borderWidth = 1.0;
        if isSsubScriptionView == false{
            sender.layer.borderColor = UIColor.appLightGrey().cgColor
        }else{
            sender.layer.borderColor = UIColor.appBlueColor().cgColor
            
        }
        sender.layer.masksToBounds = true
    }
    
    func alert(title: String, message: String){
        DispatchQueue.main.async {
            self.alertOneAction(title: title, message: message, actionTitle: "Close") {
                
            }
        }
    }
    
    func alert(title: String, message: String, completion: @escaping () -> Void){
        DispatchQueue.main.async {
            self.alertOneAction(title: title, message: message, actionTitle: "Close") {
                completion()
            }
        }
    }
    
    func alertYesNoActions(title: String?, message: String?, yesActionTitle: String, noActionTitle: String, completion: @escaping (Bool) -> Void){
        
        guard let topVC = UIApplication.topViewController() else {
            return
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let yesAction = UIAlertAction(title: yesActionTitle, style: .default) { (action) in
            completion(true)
        }
        
        let noAction = UIAlertAction(title: noActionTitle, style: .cancel) { (action) in
            completion(false)
        }
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        topVC.present(alert, animated: true, completion: nil)
        
    }
    func alertOneAction(title: String?, message: String?, actionTitle: String, completion: @escaping () -> Void){
        
        guard let topVC = UIApplication.topViewController() else {
            return
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: actionTitle, style: .cancel) { (action) in
            completion()
        }
        
        alert.addAction(okAction)
        topVC.present(alert, animated: true, completion: nil)
        
    }
    
    func setDashboardRoot(){
        
        DispatchQueue.main.async {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "HomeTabBar") as! UITabBarController
            if let mWindow = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first {
                mWindow.rootViewController = viewController
            }else{
                UIApplication.shared.windows.last?.rootViewController = viewController
            }
        }
    }
    
    func setCreateProfileRoot(){
        let storyBoard = UIStoryboard(name: "Registration", bundle: nil)
        let navigationController = storyBoard.instantiateViewController(withIdentifier: "CreateProfileViewController")
        
        if let mWindow = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first {
            mWindow.rootViewController = navigationController
        }else{
            UIApplication.shared.windows.last?.rootViewController = navigationController
        }
    }
    
    func setLoginRoot(){
        let storyBoard = UIStoryboard(name: "Registration", bundle: nil)
        let navigationController = storyBoard.instantiateViewController(withIdentifier: "LoginNavigation") as! UINavigationController
        
        if let mWindow = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first {
            mWindow.rootViewController = navigationController
        }else{
            UIApplication.shared.windows.last?.rootViewController = navigationController
        }
    }
    
    func logout(){
        
        let alert = UIAlertController(title: Constants.appName, message: "Do you want to logout?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            
            PreferenceManager.shared.clear()
            //Clear Pending Notification banners
            UIApplication.shared.applicationIconBadgeNumber = 1
            UIApplication.shared.applicationIconBadgeNumber = 0
            
            self.setLoginRoot()
        }
        
        alert.addAction(cancelAction)
        alert.addAction(yesAction)
        
        guard let topVC = UIApplication.topViewController() else {
            return
        }
        topVC.present(alert, animated: true, completion: nil)
        
    }
    
}
