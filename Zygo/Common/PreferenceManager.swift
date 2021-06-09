//
//  PreferenceManager.swift
//  Zygo
//
//  Created by Som on 29/01/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit

final class PreferenceManager: NSObject {
    
    static let shared = PreferenceManager()
    
    private lazy var defaults: UserDefaults = {
        UserDefaults.standard
    }()
    
    private override init() {
    }
    
    func clear(completion: @escaping () -> Void){
        
        let deviceToken = PreferenceManager.shared.deviceToken
        guard let domain = Bundle.main.bundleIdentifier else{
            completion()
            return
        }
        UserDefaults.standard.removePersistentDomain(forName: domain)
        PreferenceManager.shared.deviceToken = deviceToken
        completion()
    }
    
    var user : UserDTO {
        set{
            defaults.set(newValue.toDict(), forKey: PreferenceKey.User.rawValue)
            defaults.synchronize()
        }get{
            let userDict = defaults.value(forKey: PreferenceKey.User.rawValue) as? [String : Any] ?? [:]
            return UserDTO(userDict)
        }
    }
    
    var workoutInfo : WorkoutInfoDTO {
        set{
            defaults.set(newValue.toDict(), forKey: PreferenceKey.Workout.rawValue)
            defaults.synchronize()
        }get{
            let userDict = defaults.value(forKey: PreferenceKey.Workout.rawValue) as? [String : Any] ?? [:]
            return WorkoutInfoDTO(userDict)
        }
    }
    
    var notificationInfo : NotificationInfoDTO {
        set{
            defaults.set(newValue.toDict(), forKey: PreferenceKey.Notification.rawValue)
            defaults.synchronize()
        }get{
            let userDict = defaults.value(forKey: PreferenceKey.Notification.rawValue) as? [String : Any] ?? [:]
            return NotificationInfoDTO(userDict)
        }
    }
    
    var friendsInfo : FriendsInfoDTO {
        set{
            defaults.set(newValue.toDict(), forKey: PreferenceKey.Friends.rawValue)
            defaults.synchronize()
        }get{
            let userDict = defaults.value(forKey: PreferenceKey.Friends.rawValue) as? [String : Any] ?? [:]
            return FriendsInfoDTO(userDict)
        }
    }
    
    var userId : Int {
        set{
            defaults.set(newValue, forKey: PreferenceKey.UserId.rawValue)
            defaults.synchronize()
        }get{
            return defaults.value(forKey: PreferenceKey.UserId.rawValue) as? Int ?? -1
        }
    }
    
    var isUserLogin : Bool {
        set{
            defaults.set(newValue, forKey: PreferenceKey.IsUserLogin.rawValue)
        }get{
            return defaults.value(forKey: PreferenceKey.IsUserLogin.rawValue) as? Bool ?? false
        }
    }
    
    var authToken : String {
        set{
            defaults.set(newValue, forKey: PreferenceKey.AuthToken.rawValue)
        }get{
            return defaults.value(forKey: PreferenceKey.AuthToken.rawValue) as? String ?? ""
        }
    }
    
    var deviceToken : String {
        set{
            defaults.set(newValue, forKey: PreferenceKey.DeviceToken.rawValue)
        }get{
            return defaults.value(forKey: PreferenceKey.DeviceToken.rawValue) as? String ?? ""
        }
    }
    
    var currentSubscribedProduct : PurchasedSubscription? {
        set{
            defaults.setValue(newValue?.toDict(), forKey: PreferenceKey.UserSubscriedPlan.rawValue)
            defaults.synchronize()
        }get{
            if let dict = defaults.value(forKey: PreferenceKey.UserSubscriedPlan.rawValue) as? [String: Any]{
                return PurchasedSubscription(dict)
            }
            
            return nil
        }
    }
    
    var completedWorkouts: [Int] {
        set{
            defaults.setValue(newValue, forKey: PreferenceKey.CompletedWorkouts.rawValue)
            defaults.synchronize()
            NotificationCenter.default.post(name: .UpdateCompletedWorkouts, object: nil)
        }get{
            return defaults.value(forKey: PreferenceKey.CompletedWorkouts.rawValue) as? [Int] ?? []
        }
    }
    
    var selectedFilters : [GroupedFilterDTO] {
        set{
            let arrSelectedFilters = newValue.map({ $0.toDict() })
            defaults.setValue( arrSelectedFilters , forKey: PreferenceKey.UserSelectedFilter.rawValue)
            defaults.synchronize()
        }get{
            if let arrTempFilters = defaults.value(forKey: PreferenceKey.UserSelectedFilter.rawValue) as? [[String: Any]]{
                var arrFilters: [GroupedFilterDTO] = []
                for dict in arrTempFilters{
                    arrFilters.append(GroupedFilterDTO(dict))
                }
                return arrFilters
            }
            
            return []
        }
    }
    
    var loginType : String {
        set{
            defaults.set(newValue, forKey: PreferenceKey.LoginType.rawValue)
        }get{
            return defaults.value(forKey: PreferenceKey.LoginType.rawValue) as? String ?? ""
        }
    }
    
    var tempoTrainer : TempoTrainerManager.TemoTrainer? {
        set{
            defaults.set(newValue?.toDict(), forKey: PreferenceKey.TempoTrainer.rawValue)
        }get{
            
            if let trainerDict = defaults.value(forKey: PreferenceKey.TempoTrainer.rawValue) as? [String: Any]{
                return TempoTrainerManager.TemoTrainer(trainerDict)
            }
            
            return nil
        }
    }
    
    var appCurrentVersion: String {
        set{
            defaults.set(newValue, forKey: PreferenceKey.AppCurrentVersion.rawValue)
        }get{
            return defaults.value(forKey: PreferenceKey.AppCurrentVersion.rawValue) as? String ?? ""
        }
    }
}


enum PreferenceKey : String{
    case User = "S_User_Data"
    case Workout = "S_User_Workout"
    case Notification = "S_User_Notification"
    case Friends = "S_User_Friends"
    case Subscription = "S_User_Subscription"
    
    case UserId = "S_User_Id"
    
    case IsUserLogin = "S_User_Is_Login"
    
    case AuthToken = "S_User_Auth_Token"
    case DeviceToken = "S_User_Device_Token"
    case UserSubscriedPlan = "userSubscribedPlan"
    case CompletedWorkouts = "Completed_Workouts"
    case LoginType = "User_Login_Type"
    case UserSelectedFilter = "UserSelectedFilter"
    
    case TempoTrainer = "TempoTrainer"
    case AppCurrentVersion = "App_Current_Version"
    
}
