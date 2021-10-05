//
//  SceneDelegate.swift
//  Zygo
//
//  Created by Priya Gandhi on 23/01/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import AVFoundation
import Branch

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        
        guard let url = URLContexts.first?.url else {
            return
        }
        
        Branch.getInstance().application(UIApplication.shared, open: url, sourceApplication: nil, annotation: [UIApplication.OpenURLOptionsKey.annotation])
        
        ApplicationDelegate.shared.application(
            UIApplication.shared,
            open: url,
            sourceApplication: nil,
            annotation: [UIApplication.OpenURLOptionsKey.annotation]
        )
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        if let windowScene = scene as? UIWindowScene {
            
            let window = UIWindow(windowScene: windowScene)
            
            if PreferenceManager.shared.isUserLogin{
                
                //CHECK IF USER PROFILE IS NOT UPDATED THEN MOVE TO PROFILE SCREEN
                let userItem = PreferenceManager.shared.user
                if userItem.gender.isEmpty || userItem.email.isEmpty{//MEANS PROFILE ISN'T UPDATED
                    if !SubscriptionManager.shared.isValidSubscription(){//It means user is not subscribe yet
                        let storyBoard = UIStoryboard(name: "Registration", bundle: nil)
                        let navigationController = storyBoard.instantiateViewController(withIdentifier: "SubscriptionViewController")
                        window.rootViewController = navigationController
                    }else{
                        
                        let storyBoard = UIStoryboard(name: "Registration", bundle: nil)
                        let navigationController = storyBoard.instantiateViewController(withIdentifier: "CreateProfileViewController")
                        window.rootViewController = navigationController
                    }
                }else{
                    //MOVE TO DASHBOARD
                    let mainStoryboard: UIStoryboard = UIStoryboard(name: "SideMenu", bundle: nil)
                    let viewController = mainStoryboard.instantiateViewController(withIdentifier: "SideMenu")// as! SideMenu
                    window.rootViewController = viewController
                }
                //}
                
            }else{
                let storyBoard = UIStoryboard(name: "Registration", bundle: nil)
                let navigationController = storyBoard.instantiateViewController(withIdentifier: "LoginNavigation") as! UINavigationController
                window.rootViewController = navigationController
            }
            
            
            self.window = window
            window.makeKeyAndVisible()
        }
        
        
        if let userActivity = connectionOptions.userActivities.first{
            self.scene(scene, continue: userActivity)
        }
        
        //Disable dark mode
        window?.overrideUserInterfaceStyle = .light
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        
        //Clear Pending Notification banners
        UIApplication.shared.applicationIconBadgeNumber = 1
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        do{
            try AVAudioSession.sharedInstance().setCategory(.playback, options: .defaultToSpeaker)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        }catch{
            print("Faild to set Audio Session")
        }
        
        Helper.shared.forceUpgrade()
        
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
    
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        Branch.getInstance().continue(userActivity)
    }
}

