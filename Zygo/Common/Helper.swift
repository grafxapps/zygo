//
//  Helper.swift
//  Zygo
//
//  Created by Priya Gandhi on 23/01/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit
import StoreKit
import SideMenuSwift
import FirebaseAnalytics

final class Helper: NSObject {
    
    static let shared = Helper()
    
    private let userService = UserServices()
    private let maxDemoLimit: Int = 180//Seconds
    
    var demoStartDate: Date?{
        get{
            return PreferenceManager.shared.demoModeStartDate
        }set{
            PreferenceManager.shared.demoModeStartDate = newValue
        }
    }
    
    private override init() {
    }
    
    var isTestUser: Bool{
        return PreferenceManager.shared.isTestUser
    }
    
    var isDemoMode: Bool{
        return PreferenceManager.shared.isDemoMode
    }
    
    var demoTotalSeconds: Int{
        get{
            return PreferenceManager.shared.demoTotalSeconds
        }set{
            PreferenceManager.shared.demoTotalSeconds = newValue
        }
        
    }
    
    func requestToRate() {
        SKStoreReviewController.requestReview()
        userService.updateRatingPopupDate { (error) in
            DispatchQueue.main.async {
                if error != nil{
                    print(error!)
                    return
                }
                
                PreferenceManager.shared.lastRatingPopupDate = DateHelper.shared.currentUTCDateTime
            }
        }
    }
    
    func isDemoLimitComplete() -> Bool{
        
        if !Helper.shared.isDemoMode{
            return false
        }

        var finalSeconds: Int = self.demoTotalSeconds
        if let startDate = demoStartDate{
            
            let seconds = DateHelper.shared.currentLocalDateTime.timeIntervalSince1970 - startDate.timeIntervalSince1970
            
            finalSeconds += Int(seconds)
        }
        
        if finalSeconds >= self.maxDemoLimit{
            let previousSeconds = self.demoTotalSeconds
            self.demoTotalSeconds = previousSeconds + finalSeconds
            return true
        }
        
        return false
    }
    
    func isDemoStarted() -> Bool{
        return self.demoStartDate != nil
    }
    
    func startDemoTime(){
        self.demoStartDate = DateHelper.shared.currentLocalDateTime
    }
    
    func stopDemoTime(){
        if let startDate = demoStartDate{
            
            let seconds = DateHelper.shared.currentLocalDateTime.timeIntervalSince1970 - startDate.timeIntervalSince1970
            let previousSeconds = self.demoTotalSeconds
            self.demoTotalSeconds = previousSeconds + Int(seconds)
        }
        
        self.demoStartDate = nil
    }
    
    func resetDemoMode(){
        PreferenceManager.shared.isDemoMode = false
        PreferenceManager.shared.demoModeStartDate = nil
        PreferenceManager.shared.demoTotalSeconds = 0
    }
    
    func resetDemoModeTime(){
        PreferenceManager.shared.demoModeStartDate = nil
        PreferenceManager.shared.demoTotalSeconds = 0
    }
    
    func stopTempoTrainerOnController(){
        if AppDelegate.app.tempoPlayer == nil{
            return
        }
        
        if  let sideMenuController = (UIApplication.shared.windows.filter({ $0.isKeyWindow }).first?.rootViewController as? SideMenuController) {
            if let nav = sideMenuController.contentViewController as? UINavigationController{
                if let tabVC =  nav.viewControllers.first(where: { $0 is HomeTabBar }) as? UITabBarController{
                    
                    if let tempController = tabVC.viewControllers?[3] as? TempoTrainerViewController{
                        tempController.stopTempTrainer()
                    }
                }
            }
        }
    }
    
    func isTempoTrainerRunnig() -> Bool{
        
        if AppDelegate.app.tempoPlayer == nil{
            return false
        }
        
        return true
    }
    
    var appVersion: String{
        get{
            return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "None"
        }
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
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "SideMenu", bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "SideMenu") //as! UINavigationController
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
    
    func setSubscriptionRoot(){
        let storyBoard = UIStoryboard(name: "Registration", bundle: nil)
        let navigationController = storyBoard.instantiateViewController(withIdentifier: "SubscriptionViewController")
        
        if let mWindow = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first {
            mWindow.rootViewController = navigationController
        }else{
            UIApplication.shared.windows.last?.rootViewController = navigationController
        }
    }
    
    func pushToSubscriptionScreen(from vc: UIViewController){
        let storyBoard = UIStoryboard(name: "Registration", bundle: nil)
        let navigationController = storyBoard.instantiateViewController(withIdentifier: "SubscriptionViewController") as! SubscriptionViewController
        navigationController.isFromDemoMode = true
        vc.navigationController?.pushViewController(navigationController, animated: true)
        
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
            
            PreferenceManager.shared.clear {
                NotificationCenter.default.post(name: .removeObservers, object: nil)
                TempoTrainerManager.shared.stopTrainer()
                GoogleLoginManager.shared.logout()
                FacebookManager.shared.logout()
                //Clear Pending Notification banners
                UIApplication.shared.applicationIconBadgeNumber = 1
                UIApplication.shared.applicationIconBadgeNumber = 0
                
                self.setLoginRoot()
                Helper.shared.resetUserIdentity()
            }
        }
        
        alert.addAction(cancelAction)
        alert.addAction(yesAction)
        
        guard let topVC = UIApplication.topViewController() else {
            return
        }
        topVC.present(alert, animated: true, completion: nil)
        
    }
    
    func getWorkoutCellHeight() -> CGFloat{
        let topHeader: CGFloat = 0.0
        let bottomHeight: CGFloat = 40.0
        let imageHeight = (ScreenSize.SCREEN_WIDTH - 42.0)/2.4
        let totalCellHeight = topHeader + bottomHeight + imageHeight
        return totalCellHeight
    }
    
    func openUrl(url: URL?){
        if let ur = url{
            if UIApplication.shared.canOpenURL(ur){
                UIApplication.shared.open(ur, options: [:], completionHandler: nil)
            }
        }
    }
    
    func moveToTab(index: Int){
        
        guard let sideMenuController = (UIApplication.shared.windows.filter({ $0.isKeyWindow }).first?.rootViewController as? SideMenuController) else {
            return
        }
        
        if let nav = sideMenuController.contentViewController as? UINavigationController{
            if let tabVC =  nav.viewControllers.last as? UITabBarController{
                tabVC.selectedIndex = index
            }
        }
        
    }
    
    func isSocialLogin() -> Bool{
        let lType = PreferenceManager.shared.loginType
        if lType == LoginType.google.rawValue || lType == LoginType.facebook.rawValue || lType == LoginType.apple.rawValue{
            return true
        }else{
            return false
        }
    }
    
    var deviceId : String {
        get{
            
            if let device = Keychain.shared["Zygo_Device_id"]{
                return device
            }
            
            let newDevice = UIDevice.current.identifierForVendor!.uuidString
            Keychain.shared["Zygo_Device_id"] = newDevice
            return newDevice
        }
    }
    
    func forceUpgrade(){
        self.userService.forceUpgrade { (error) in
            if error == nil{
                DispatchQueue.main.async {
                    Helper.shared.checkAppUpdate()
                }
            }
        }
    }
    
    func checkAppUpdate(){
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            let latestVersion = PreferenceManager.shared.appCurrentVersion
            
            let arrLatestVersion = latestVersion.split(separator: ".")
            let appVersion = version.split(separator: ".")
            
            var isShowUpdatePopUp : Bool = false
            var versionIndex = 0
            let appVersionCount = appVersion.count
            for lversion in arrLatestVersion{
                if versionIndex < appVersionCount{
                    if Int(lversion)! > Int(appVersion[versionIndex])!{
                        isShowUpdatePopUp = true
                        break
                    }else if Int(lversion)! == Int(appVersion[versionIndex])!{
                        
                    }else{
                        break;
                    }
                }else{
                    isShowUpdatePopUp = true
                    break;
                }
                
                versionIndex += 1
            }
            
            //Show Update PopUp
            if isShowUpdatePopUp{
                guard let topVC = UIApplication.topViewController() else {
                    return
                }
                
                let alert = UIAlertController(title: "Update Available", message: "There is an update available for \(Constants.appName). Please update now to access all of \(Constants.appName)'s functions.", preferredStyle: .alert)
                let updateAction = UIAlertAction(title: "Update", style: .default) { (action) in
                    let appURL = URL(string: Constants.appLink)
                    self.openUrl(url: appURL)
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                    
                }
                
                alert.addAction(updateAction)
                alert.addAction(cancelAction)
                if topVC is UIAlertController{
                    return
                }
                topVC.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func shareWorkout(url: URL){
        let objectsToShare:URL = url
        let sharedObjects:[AnyObject] = [objectsToShare as AnyObject]
        let activityViewController = UIActivityViewController(activityItems : sharedObjects, applicationActivities: nil)
        //activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.excludedActivityTypes = []
        
        UIApplication.topViewController()?.present(activityViewController, animated: true, completion: nil)
    }
    
    func pushToWorkout(wId: Int){
        
        var workoutItem = WorkoutDTO([:])
        workoutItem.workoutId = wId
        let playerVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WorkoutDetailViewController") as! WorkoutDetailViewController
        playerVC.workoutItem = workoutItem
        playerVC.isFromBranch = true
        playerVC.hidesBottomBarWhenPushed = true
        
        let navController = UINavigationController(rootViewController: playerVC)
        navController.isNavigationBarHidden = true
        navController.modalPresentationStyle = .overFullScreen
        UIApplication.topViewController()?.present(navController, animated: true, completion: nil)
        
    }
    
    func log(event name: EventName, params: [String: Any]){
        Analytics.logEvent(name.rawValue, parameters: params)
    }
    
    func logUserIdentity(){
        let user = PreferenceManager.shared.user
        Analytics.setUserID("\(user.uId)")
        
        let tempUB = user.birthday
        if let dob = tempUB.fromServerBirthday(){
            Analytics.setUserProperty(dob.toAge(), forName: "AGE")
        }
        Analytics.setUserProperty(user.gender.lowercased(), forName: "GENDER")

    }
    
    func resetUserIdentity(){
        Analytics.setUserID(nil)
        Analytics.setUserProperty(nil, forName: "AGE")
        Analytics.setUserProperty(nil, forName: "GENDER")
    }
    
}


class Keychain {
    
    open var loggingEnabled = true
    
    private init() {}
    public static let shared = Keychain()
    
    open subscript(key: String) -> String? {
        get {
            return load(withKey: key)
        } set {
            DispatchQueue.global().sync(flags: .barrier) {
                self.save(newValue, forKey: key)
            }
        }
    }
    
    private func save(_ string: String?, forKey key: String) {
        let query = keychainQuery(withKey: key)
        let objectData: Data? = string?.data(using: .utf8, allowLossyConversion: false)
        
        if SecItemCopyMatching(query, nil) == noErr {
            if let dictData = objectData {
                let status = SecItemUpdate(query, NSDictionary(dictionary: [kSecValueData: dictData]))
                logPrint("Update status: ", status)
            } else {
                let status = SecItemDelete(query)
                logPrint("Delete status: ", status)
            }
        } else {
            if let dictData = objectData {
                query.setValue(dictData, forKey: kSecValueData as String)
                let status = SecItemAdd(query, nil)
                logPrint("Update status: ", status)
            }
        }
    }
    
    private func load(withKey key: String) -> String? {
        let query = keychainQuery(withKey: key)
        query.setValue(kCFBooleanTrue, forKey: kSecReturnData as String)
        query.setValue(kCFBooleanTrue, forKey: kSecReturnAttributes as String)
        
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query, &result)
        
        guard
            let resultsDict = result as? NSDictionary,
            let resultsData = resultsDict.value(forKey: kSecValueData as String) as? Data,
            status == noErr
        else {
            logPrint("Load status: ", status)
            return nil
        }
        return String(data: resultsData, encoding: .utf8)
    }
    
    private func keychainQuery(withKey key: String) -> NSMutableDictionary {
        let result = NSMutableDictionary()
        result.setValue(kSecClassGenericPassword, forKey: kSecClass as String)
        result.setValue(key, forKey: kSecAttrService as String)
        //kSecAttrAccessibleAlwaysThisDeviceOnly
        result.setValue(kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly, forKey: kSecAttrAccessible as String)
        return result
    }
    
    private func logPrint(_ items: Any...) {
        if loggingEnabled {
            print(items)
        }
    }
}
