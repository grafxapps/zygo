//
//  SignInViewModel.swift
//  Zygo
//
//  Created by Priya Gandhi on 23/01/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit

class SignInViewModel: NSObject {
    
    private let signupService = RegistrationServices()
    
    var userItem = SignUpUserDTO()
    var OTP: String = ""
    
    func isValidate() -> Bool{
        if userItem.email.isEmpty{
            Helper.shared.alert(title: Constants.appName, message: "Please enter your email address.")
            return false
        }else if !userItem.email.isEmailValid(){
            Helper.shared.alert(title: Constants.appName, message: "Please enter a valid email address.")
            return false
        }else if userItem.password.isEmpty{
            Helper.shared.alert(title: Constants.appName, message: NSLocalizedString("Please enter your password.", comment: ""))
            return false
        }/*else if !userItem.password.isValidPasswordLength(){
            Helper.shared.alert(title: Constants.appName, message: NSLocalizedString("Password must be at least 8 digits long", comment: ""))
            return false
        }*/
        
        return true
    }
    
    
    func signInUser(completion: @escaping (Bool) -> Void){
        
        Helper.shared.startLoading()
        self.signupService.signIn(email: self.userItem.email, password: self.userItem.password) { [weak self] (error, isVerified, jsonResponse) in
            if self == nil{
                return
            }
            
            DispatchQueue.main.async {
                Helper.shared.stopLoading()
                
                if error != nil{
                    Helper.shared.alert(title: Constants.appName, message: error!)
                    completion(false)
                    return
                }
                
                if !isVerified{
                    self?.resendVerificationAlert(email: self?.userItem.email ?? "")
                    completion(false)
                    return
                }
                
                let user = UserDTO(jsonResponse)
                let workoutInfo = WorkoutInfoDTO(jsonResponse)
                let notificationInfo = NotificationInfoDTO(jsonResponse)
                let friendsInfo = FriendsInfoDTO(jsonResponse)
                
                PreferenceManager.shared.completedWorkouts =  (jsonResponse["workouts_completed"] as? String ?? "").components(separatedBy: ",").map({ Int($0) ?? 0 })
                
                PreferenceManager.shared.loginType = jsonResponse["login_type"] as? String ?? ""
                
                if let subInfoDic = jsonResponse["user_subscriptions"] as? [String: Any]{
                    let subscriptionType = subInfoDic["subscription_type"] as? String ?? ""
                    if subscriptionType == SubscriptionType.Apple.rawValue{
                        let planId = subInfoDic["apple_plan_id"] as? String ?? ""
                        let subscriptionId = subInfoDic["apple_subscription_id"] as? String ?? ""
                        let strExpireDate = subInfoDic["expire_date"] as? String ?? ""
                        
                        
                        let subscriptionDict = [
                            "expiry_date": strExpireDate,
                            "transaction_id": subscriptionId,
                            "plan_id": planId,
                            "subscription_type": subscriptionType
                        ]
                        
                        PreferenceManager.shared.currentSubscribedProduct = PurchasedSubscription(subscriptionDict)
                    }else if subscriptionType == SubscriptionType.Stripe.rawValue{
                        let planId = subInfoDic["stripe_plan_id"] as? String ?? ""
                        let subscriptionId = subInfoDic["subscription_id"] as? String ?? ""
                        let strExpireDate = subInfoDic["expire_date"] as? String ?? ""
                        
                        let subscriptionDict = [
                            "expiry_date": strExpireDate,
                            "transaction_id": subscriptionId,
                            "plan_id": planId,
                            "subscription_type": subscriptionType
                        ]
                        
                        PreferenceManager.shared.currentSubscribedProduct = PurchasedSubscription(subscriptionDict)
                    }else{
                        let planId = subInfoDic["plan_id"] as? String ?? ""
                        let subscriptionId = subInfoDic["subscription_id"] as? String ?? ""
                        let strExpireDate = subInfoDic["expire_date"] as? String ?? ""
                        
                        let subscriptionDict = [
                            "expiry_date": strExpireDate,
                            "transaction_id": subscriptionId,
                            "plan_id": planId,
                            "subscription_type": subscriptionType
                        ]
                        
                        PreferenceManager.shared.currentSubscribedProduct = PurchasedSubscription(subscriptionDict)
                    }
                }else{
                    PreferenceManager.shared.currentSubscribedProduct = nil
                }
                
                //Save user obj in preference
                PreferenceManager.shared.userId = user.uId
                PreferenceManager.shared.user = user
                PreferenceManager.shared.workoutInfo = workoutInfo
                PreferenceManager.shared.notificationInfo = notificationInfo
                PreferenceManager.shared.friendsInfo = friendsInfo
                PreferenceManager.shared.isUserLogin = true
                completion(true)
            }
        }
    }
    
    func resendVerificationAlert(email: String){
        Helper.shared.alertYesNoActions(title: Constants.appName, message: "Please confirm your email address to continue.", yesActionTitle: "Resend Verification Link", noActionTitle: "Continue") { (isYes) in
            
            if isYes{
                Helper.shared.startLoading()
                self.signupService.resendVerificationLink(for: email.lowercased()) { (error) in
                    
                    DispatchQueue.main.async {
                        Helper.shared.stopLoading()
                        if error != nil{
                            Helper.shared.alert(title: Constants.appName, message: error!)
                            return
                        }
                        
                        Helper.shared.alert(title: Constants.appName, message: "Please click the link in the verification email we have sent you.")
                        return
                    }
                }
            }
        }
    }
    
    func googleSignInUser(accessToken : String, completion: @escaping (Bool) -> Void){
        
        Helper.shared.startLoading()
        self.signupService.googleSignIn(accessToken: accessToken) { (error, isVerified, jsonResponse) in
            DispatchQueue.main.async {
                Helper.shared.stopLoading()
                
                if error != nil{
                    Helper.shared.alert(title: Constants.appName, message: error!)
                    completion(false)
                    return
                }
                
                if !isVerified{
                    self.resendVerificationAlert(email: self.userItem.email)
                    completion(false)
                    return
                }
                
                let user = UserDTO(jsonResponse)
                let workoutInfo = WorkoutInfoDTO(jsonResponse)
                let notificationInfo = NotificationInfoDTO(jsonResponse)
                let friendsInfo = FriendsInfoDTO(jsonResponse)
               
                PreferenceManager.shared.completedWorkouts =  (jsonResponse["workouts_completed"] as? String ?? "").components(separatedBy: ",").map({ Int($0) ?? 0 })
                
                PreferenceManager.shared.loginType = jsonResponse["login_type"] as? String ?? ""
                
                if let subInfoDic = jsonResponse["user_subscriptions"] as? [String: Any]{
                    let subscriptionType = subInfoDic["subscription_type"] as? String ?? ""
                    if subscriptionType == SubscriptionType.Apple.rawValue{
                        let planId = subInfoDic["apple_plan_id"] as? String ?? ""
                        let subscriptionId = subInfoDic["apple_subscription_id"] as? String ?? ""
                        let strExpireDate = subInfoDic["expire_date"] as? String ?? ""
                        
                        
                        let subscriptionDict = [
                            "expiry_date": strExpireDate,
                            "transaction_id": subscriptionId,
                            "plan_id": planId,
                            "subscription_type": subscriptionType
                        ]
                        
                        PreferenceManager.shared.currentSubscribedProduct = PurchasedSubscription(subscriptionDict)
                    }else if subscriptionType == SubscriptionType.Stripe.rawValue{
                        let planId = subInfoDic["stripe_plan_id"] as? String ?? ""
                        let subscriptionId = subInfoDic["subscription_id"] as? String ?? ""
                        let strExpireDate = subInfoDic["expire_date"] as? String ?? ""
                        
                        let subscriptionDict = [
                            "expiry_date": strExpireDate,
                            "transaction_id": subscriptionId,
                            "plan_id": planId,
                            "subscription_type": subscriptionType
                        ]
                        
                        PreferenceManager.shared.currentSubscribedProduct = PurchasedSubscription(subscriptionDict)
                    }else{
                        let planId = subInfoDic["plan_id"] as? String ?? ""
                        let subscriptionId = subInfoDic["subscription_id"] as? String ?? ""
                        let strExpireDate = subInfoDic["expire_date"] as? String ?? ""
                        
                        let subscriptionDict = [
                            "expiry_date": strExpireDate,
                            "transaction_id": subscriptionId,
                            "plan_id": planId,
                            "subscription_type": subscriptionType
                        ]
                        
                        PreferenceManager.shared.currentSubscribedProduct = PurchasedSubscription(subscriptionDict)
                    }
                }else{
                    PreferenceManager.shared.currentSubscribedProduct = nil
                }
                
                //Save user obj in preference
                PreferenceManager.shared.userId = user.uId
                PreferenceManager.shared.user = user
                PreferenceManager.shared.workoutInfo = workoutInfo
                PreferenceManager.shared.notificationInfo = notificationInfo
                PreferenceManager.shared.friendsInfo = friendsInfo
                PreferenceManager.shared.isUserLogin = true
                completion(true)
            }
        }
    }
    
    func facebookSignInUser(accessToken : String, completion: @escaping (Bool) -> Void){
        
        Helper.shared.startLoading()
        self.signupService.facebookSignIn(accessToken: accessToken) { [weak self] (error, isVerified, jsonResponse) in
            if self == nil{
                return
            }
            
            DispatchQueue.main.async {
                Helper.shared.stopLoading()
                
                if error != nil{
                    Helper.shared.alert(title: Constants.appName, message: error!)
                    completion(false)
                    return
                }
                
                if !isVerified{
                    self?.resendVerificationAlert(email: self?.userItem.email ?? "")
                    completion(false)
                    return
                }
                
                let user = UserDTO(jsonResponse)
                let workoutInfo = WorkoutInfoDTO(jsonResponse)
                let notificationInfo = NotificationInfoDTO(jsonResponse)
                let friendsInfo = FriendsInfoDTO(jsonResponse)
                
                PreferenceManager.shared.completedWorkouts =  (jsonResponse["workouts_completed"] as? String ?? "").components(separatedBy: ",").map({ Int($0) ?? 0 })
                
                PreferenceManager.shared.loginType = jsonResponse["login_type"] as? String ?? ""
                
                if let subInfoDic = jsonResponse["user_subscriptions"] as? [String: Any]{
                    let subscriptionType = subInfoDic["subscription_type"] as? String ?? ""
                    if subscriptionType == SubscriptionType.Apple.rawValue{
                        let planId = subInfoDic["apple_plan_id"] as? String ?? ""
                        let subscriptionId = subInfoDic["apple_subscription_id"] as? String ?? ""
                        let strExpireDate = subInfoDic["expire_date"] as? String ?? ""
                        
                        
                        let subscriptionDict = [
                            "expiry_date": strExpireDate,
                            "transaction_id": subscriptionId,
                            "plan_id": planId,
                            "subscription_type": subscriptionType
                        ]
                        
                        PreferenceManager.shared.currentSubscribedProduct = PurchasedSubscription(subscriptionDict)
                    }else if subscriptionType == SubscriptionType.Stripe.rawValue{
                        let planId = subInfoDic["stripe_plan_id"] as? String ?? ""
                        let subscriptionId = subInfoDic["subscription_id"] as? String ?? ""
                        let strExpireDate = subInfoDic["expire_date"] as? String ?? ""
                        
                        let subscriptionDict = [
                            "expiry_date": strExpireDate,
                            "transaction_id": subscriptionId,
                            "plan_id": planId,
                            "subscription_type": subscriptionType
                        ]
                        
                        PreferenceManager.shared.currentSubscribedProduct = PurchasedSubscription(subscriptionDict)
                    }else{
                        let planId = subInfoDic["plan_id"] as? String ?? ""
                        let subscriptionId = subInfoDic["subscription_id"] as? String ?? ""
                        let strExpireDate = subInfoDic["expire_date"] as? String ?? ""
                        
                        let subscriptionDict = [
                            "expiry_date": strExpireDate,
                            "transaction_id": subscriptionId,
                            "plan_id": planId,
                            "subscription_type": subscriptionType
                        ]
                        
                        PreferenceManager.shared.currentSubscribedProduct = PurchasedSubscription(subscriptionDict)
                    }
                }else{
                    PreferenceManager.shared.currentSubscribedProduct = nil
                }
                
                //Save user obj in preference
                PreferenceManager.shared.userId = user.uId
                PreferenceManager.shared.user = user
                PreferenceManager.shared.workoutInfo = workoutInfo
                PreferenceManager.shared.notificationInfo = notificationInfo
                PreferenceManager.shared.friendsInfo = friendsInfo
                PreferenceManager.shared.isUserLogin = true
                completion(true)
            }
        }
    }
    
    func appleSignInUser(appleID : String,uName: String, uEmail: String, completion: @escaping (Bool) -> Void){
        
        Helper.shared.startLoading()
        self.signupService.appleSignIn(appleID: appleID, uName: uName, uEmail: uEmail) { [weak self] (error, isVerified, jsonResponse) in
            if self == nil{
                return
            }
            
            DispatchQueue.main.async {
                Helper.shared.stopLoading()
                
                if error != nil{
                    Helper.shared.alert(title: Constants.appName, message: error!)
                    completion(false)
                    return
                }
                
                if !isVerified{
                    self?.resendVerificationAlert(email: self?.userItem.email ?? "")
                    completion(false)
                    return
                }
                
                let user = UserDTO(jsonResponse)
                let workoutInfo = WorkoutInfoDTO(jsonResponse)
                let notificationInfo = NotificationInfoDTO(jsonResponse)
                let friendsInfo = FriendsInfoDTO(jsonResponse)
                
                PreferenceManager.shared.completedWorkouts =  (jsonResponse["workouts_completed"] as? String ?? "").components(separatedBy: ",").map({ Int($0) ?? 0 })
                
                PreferenceManager.shared.loginType = jsonResponse["login_type"] as? String ?? ""
                
                if let subInfoDic = jsonResponse["user_subscriptions"] as? [String: Any]{
                    let subscriptionType = subInfoDic["subscription_type"] as? String ?? ""
                    if subscriptionType == SubscriptionType.Apple.rawValue{
                        let planId = subInfoDic["apple_plan_id"] as? String ?? ""
                        let subscriptionId = subInfoDic["apple_subscription_id"] as? String ?? ""
                        let strExpireDate = subInfoDic["expire_date"] as? String ?? ""
                        
                        
                        let subscriptionDict = [
                            "expiry_date": strExpireDate,
                            "transaction_id": subscriptionId,
                            "plan_id": planId,
                            "subscription_type": subscriptionType
                        ]
                        
                        PreferenceManager.shared.currentSubscribedProduct = PurchasedSubscription(subscriptionDict)
                    }else if subscriptionType == SubscriptionType.Stripe.rawValue{
                        let planId = subInfoDic["stripe_plan_id"] as? String ?? ""
                        let subscriptionId = subInfoDic["subscription_id"] as? String ?? ""
                        let strExpireDate = subInfoDic["expire_date"] as? String ?? ""
                        
                        let subscriptionDict = [
                            "expiry_date": strExpireDate,
                            "transaction_id": subscriptionId,
                            "plan_id": planId,
                            "subscription_type": subscriptionType
                        ]
                        
                        PreferenceManager.shared.currentSubscribedProduct = PurchasedSubscription(subscriptionDict)
                    }else{
                        let planId = subInfoDic["plan_id"] as? String ?? ""
                        let subscriptionId = subInfoDic["subscription_id"] as? String ?? ""
                        let strExpireDate = subInfoDic["expire_date"] as? String ?? ""
                        
                        let subscriptionDict = [
                            "expiry_date": strExpireDate,
                            "transaction_id": subscriptionId,
                            "plan_id": planId,
                            "subscription_type": subscriptionType
                        ]
                        
                        PreferenceManager.shared.currentSubscribedProduct = PurchasedSubscription(subscriptionDict)
                    }
                }else{
                    PreferenceManager.shared.currentSubscribedProduct = nil
                }
                
                //Save user obj in preference
                PreferenceManager.shared.userId = user.uId
                PreferenceManager.shared.user = user
                PreferenceManager.shared.workoutInfo = workoutInfo
                PreferenceManager.shared.notificationInfo = notificationInfo
                PreferenceManager.shared.friendsInfo = friendsInfo
                PreferenceManager.shared.isUserLogin = true
                completion(true)
            }
        }
    }
}
