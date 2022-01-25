//
//  AppDelegate.swift
//  Zygo
//
//  Created by Priya Gandhi on 23/01/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit
import CoreData
import IQKeyboardManagerSwift
import GoogleSignIn
import FBSDKCoreKit
import SideMenuSwift
import AVFoundation
import SwiftyStoreKit
import Firebase
import FirebaseMessaging
import Branch
import KlaviyoSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    //Publis Sound Player for temo trainer
    var tempoPlayer: AVAudioPlayer?
    let protector = ScreenRecordingProtoector()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        protector.startPreventing()
        
        Klaviyo.setupWithPublicAPIKey(apiKey: Constants.KLAVIYOPUBLICAPIKEY)
        if PreferenceManager.shared.isUserLogin{
            let user = PreferenceManager.shared.user
            Klaviyo.sharedInstance.setUpUserEmail(userEmail: user.email)
            Klaviyo.sharedInstance.setUpCustomerID(id: user.email)
            Klaviyo.sharedInstance.trackEvent(eventName: "User_Type", properties: ["user_id": "\(user.uId)", "user_email": user.email, "type": "iOS"])            
        }
        
        if let launch = launchOptions, let data = launch[UIApplication.LaunchOptionsKey.remoteNotification] as? [AnyHashable: Any] {
            Klaviyo.sharedInstance.handlePush(userInfo: data as NSDictionary)
        }
        
        Branch.setBranchKey(Constants.branchKey)
        // if you are using the TEST key
        Branch.setUseTestBranchKey(true)
        // listener for Branch Deep Link data
        Branch.getInstance().initSession(launchOptions: launchOptions) { (params, error) in
            // do stuff with deep link data (nav to page, display content, etc)
            let workoutDict = params as? [String: AnyObject] ?? [:]
            print("Workout Link: \(workoutDict)")
            //PreferenceManager.shared.branchLinkWorkoutId = workoutDict["workout_id"] as? Int
            if let wId = workoutDict["workout_id"] as? Int{
                Helper.shared.pushToWorkout(wId: wId)
            }
        }
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        //Setup True Time
        DateHelper.shared.initializeCurrentTime()
        
        IQKeyboardManager.shared.enable = true;
        IQKeyboardManager.shared.toolbarTintColor = UIColor.appBlueColor()
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        UITextField.appearance().tintColor = UIColor.appBlueColor()
        
        //GIDSignIn.sharedInstance()?.clientID = Constants.googleClientId
        //GIDSignIn.sharedInstance()?.serverClientID = Constants.googleServerId
        
        if #available(iOS 13.4, *){
            
        }else{
            self.checkUserLoginStatus()
        }
        
        self.configureSideMenu()
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            //UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        UNUserNotificationCenter.current().delegate = self
        
        application.registerForRemoteNotifications()
        
        //Clear Pending Notification banners
        UIApplication.shared.applicationIconBadgeNumber = 1
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        Messaging.messaging().delegate = self
        
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        
        //Clear all filters when app get launched
        PreferenceManager.shared.selectedFilters = []
        PreferenceManager.shared.isTakenByMe = false
        PreferenceManager.shared.isNotTakenByMe = false
        
        self.setupIAP()
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        Branch.getInstance().application(app, open: url, options: options)
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        DatabaseManager.shared.pauseAllDowloadingWorkouts()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        //Clear Pending Notification banners
        UIApplication.shared.applicationIconBadgeNumber = 1
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        Helper.shared.forceUpgrade()
        
    }
    
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        guard let topVC = UIApplication.topViewController() else{
            return .portrait
        }
        
        if let lastVC = ((topVC as? SideMenuController)?.contentViewController as? NavigationController)?.viewControllers.last as? InstructorViewController{
            if lastVC.viewModel.instructor.instructorVideo.isEmpty{
                return .portrait
            }else{
                return .all
            }
        }
        
        
        if let lastVC = ((topVC as? SideMenuController)?.contentViewController as? NavigationController)?.viewControllers.last as? WorkoutPlayerViewController{
            if lastVC.isVideo{
                return .all
            }
        }
        
        return .portrait
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Zygo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    
    //Private Methods
    func checkUserLoginStatus(){
        
        if PreferenceManager.shared.isUserLogin{
            //TODO: CHECK USER SUBSCRIPTION STATUS AS WELL
            
            let userItem = PreferenceManager.shared.user
            Klaviyo.sharedInstance.setUpUserEmail(userEmail: userItem.email)
            Klaviyo.sharedInstance.setUpCustomerID(id: userItem.email)
            
            if !SubscriptionManager.shared.isValidSubscription(){//It means user is not subscribe yet
                
                //Enable demo mode for user
                //if !Helper.shared.isDemoLimitComplete(){
                    Helper.shared.resetDemoModeTime()
                    PreferenceManager.shared.isDemoMode = true
                    
                    //CHECK IF USER PROFILE IS NOT UPDATED THEN MOVE TO PROFILE SCREEN
                    //let userItem = PreferenceManager.shared.user
                    if userItem.gender.isEmpty || userItem.email.isEmpty{//MEANS PROFILE ISN'T UPDATED
                        Helper.shared.setCreateProfileRoot()
                        
                    }else{
                        //MOVE TO DASHBOARD
                        Helper.shared.setDashboardRoot()
                    }
                    
                    return
                //}
                
                //Helper.shared.setSubscriptionRoot()
            }else{
                //CHECK IF USER PROFILE IS NOT UPDATED THEN MOVE TO PROFILE SCREEN
                //let userItem = PreferenceManager.shared.user
                if userItem.gender.isEmpty || userItem.email.isEmpty{//MEANS PROFILE ISN'T UPDATED
                    Helper.shared.setCreateProfileRoot()
                    
                }else{
                    //MOVE TO DASHBOARD
                    Helper.shared.setDashboardRoot()
                }
            }
            
        }else{
            Helper.shared.setLoginRoot()
        }
    }
    
    private func configureSideMenu() {
        SideMenuController.preferences.basic.enablePanGesture = false
        SideMenuController.preferences.basic.menuWidth = ScreenSize.SCREEN_WIDTH
        SideMenuController.preferences.basic.defaultCacheKey = "0"
    }
    
    static var app: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
}


extension AppDelegate{
    
    func setupIAP() {
        
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    let downloads = purchase.transaction.downloads
                    if !downloads.isEmpty {
                        SwiftyStoreKit.start(downloads)
                    } else if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    print("\(purchase.transaction.transactionState.debugDescription): \(purchase.productId)")
                case .failed, .purchasing, .deferred:
                    break // do nothing
                @unknown default:
                    break // do nothing
                }
            }
        }
        
        SwiftyStoreKit.updatedDownloadsHandler = { downloads in
            
            // contentURL is not nil if downloadState == .finished
            let contentURLs = downloads.compactMap { $0.contentURL }
            if contentURLs.count == downloads.count {
                print("Saving: \(contentURLs)")
                SwiftyStoreKit.finishTransaction(downloads[0].transaction)
            }
        }
    }
}

extension AppDelegate: MessagingDelegate{
    func updateFirestorePushTokenIfNeeded() {
        if let token = Messaging.messaging().fcmToken {
            print("My FCM Token \(token)")
            PreferenceManager.shared.deviceToken = token
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        Klaviyo.sharedInstance.addPushDeviceToken(deviceToken: deviceToken)
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print(token)
        
        Messaging.messaging().token { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result ?? "NIL TOKEN")")
                
            }
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print(userInfo)
        
        if application.applicationState == UIApplication.State.inactive || application.applicationState ==  UIApplication.State.background {
                Klaviyo.sharedInstance.handlePush(userInfo: userInfo as NSDictionary)
            }
        
        // when new message comes
        if let dict:NSDictionary = userInfo as? NSDictionary  {
            if let payloadString = dict["google.c.sender.id"] as? String{
                do{
                    let data = payloadString.data(using: .utf8)!
                    let jsonObect = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    print(jsonObect)
                    let messageDict = jsonObect  as! NSDictionary
                }catch{
                }
            }
            // store aps data in apsDict
            let apsDict = dict.value(forKey: "aps") as! NSDictionary
            let alertdict = apsDict.value(forKey: "alert") as! NSDictionary
            
        }
    }
    
    
    //MARK: - Messaging Delegate
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        updateFirestorePushTokenIfNeeded()
    }
    
    
}
extension AppDelegate : UNUserNotificationCenterDelegate{
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.sound,.badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let notificationInfo = response.notification.request.content.userInfo
        guard let type = notificationInfo["notification_type"] as? String else{
            return
        }
        
        let nType = NotificationTypes(rawValue: type) ?? .none
        switch nType {
        case .workout:
            if let wId = notificationInfo["workout_id"] as? String{
                if let iWId = Int(wId){
                    Helper.shared.pushToWorkout(wId: iWId)
                }
            }
        case .none:
            print("")
        }
        print(notificationInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if application.applicationState == UIApplication.State.inactive || application.applicationState ==  UIApplication.State.background {
                Klaviyo.sharedInstance.handlePush(userInfo: userInfo as NSDictionary)
            }
        
        print(userInfo)
        // handler for Push Notifications
        Branch.getInstance().handlePushNotification(userInfo)
        completionHandler(.newData)
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        // handler for Universal Links
        Branch.getInstance().continue(userActivity)
        return true
    }
    
}


//TODO: Uncomment for production
func print(_ item: @autoclosure () -> Any, separator: String = " ", terminator: String = "\n") {

}
