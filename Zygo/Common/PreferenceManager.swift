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
        let isBLEEnabledDevice = PreferenceManager.shared.isBLEEnabledDevice
        guard let domain = Bundle.main.bundleIdentifier else{
            completion()
            return
        }
        UserDefaults.standard.removePersistentDomain(forName: domain)
        PreferenceManager.shared.deviceToken = deviceToken
        PreferenceManager.shared.isBLEEnabledDevice = isBLEEnabledDevice
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
    
    var trackingInfo : TrackingInfoDTO {
        set{
            defaults.set(newValue.toDict(), forKey: PreferenceKey.TrackingInfo.rawValue)
            defaults.synchronize()
        }get{
            let userDict = defaults.value(forKey: PreferenceKey.TrackingInfo.rawValue) as? [String : Any] ?? [:]
            return TrackingInfoDTO(userDict)
        }
    }
    
    var poolUnitInfo : PoolUnitInfoDTO {
        set{
            defaults.set(newValue.toDict(), forKey: PreferenceKey.PoolUnitInfo.rawValue)
            defaults.synchronize()
        }get{
            let userDict = defaults.value(forKey: PreferenceKey.PoolUnitInfo.rawValue) as? [String : Any] ?? [:]
            return PoolUnitInfoDTO(userDict)
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
    
    var lastRatingPopupDate: Date? {
        set{
            defaults.set(newValue, forKey: PreferenceKey.lastRatingPopupDate.rawValue)
            defaults.synchronize()
        }get{
            return defaults.value(forKey: PreferenceKey.lastRatingPopupDate.rawValue) as? Date
        }
    }
    
    
    var isUserLogin : Bool {
        set{
            defaults.set(newValue, forKey: PreferenceKey.IsUserLogin.rawValue)
        }get{
            return defaults.value(forKey: PreferenceKey.IsUserLogin.rawValue) as? Bool ?? false
        }
    }
    
    var isTestUser : Bool {
        set{
            defaults.set(newValue, forKey: PreferenceKey.IsTestUser.rawValue)
        }get{
            return defaults.value(forKey: PreferenceKey.IsTestUser.rawValue) as? Bool ?? false
        }
    }
    
    var isDemoMode : Bool {
        set{
            defaults.set(newValue, forKey: PreferenceKey.IsDemoMode.rawValue)
        }get{
            return defaults.value(forKey: PreferenceKey.IsDemoMode.rawValue) as? Bool ?? false
        }
    }
    
    var demoModeStartDate : Date? {
        set{
            defaults.set(newValue, forKey: PreferenceKey.DemoModeStartDate.rawValue)
        }get{
            return defaults.value(forKey: PreferenceKey.DemoModeStartDate.rawValue) as? Date
        }
    }
    
    var demoTotalSeconds : Int {
        set{
            defaults.set(newValue, forKey: PreferenceKey.DemoTotalSeconds.rawValue)
        }get{
            return defaults.value(forKey: PreferenceKey.DemoTotalSeconds.rawValue) as? Int ?? 0
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
            return defaults.value(forKey: PreferenceKey.DeviceToken.rawValue) as? String ?? "ZYGOIOSDEVICETOKEN"
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
    
    var branchLinkWorkoutId: Int? {
        set{
            defaults.set(newValue, forKey: PreferenceKey.BranchLinkWorkoutId.rawValue)
        }get{
            return defaults.value(forKey: PreferenceKey.BranchLinkWorkoutId.rawValue) as? Int
        }
    }
    
    var isNotTakenByMe : Bool {
        set{
            defaults.set(newValue, forKey: PreferenceKey.IsNotTakenByMe.rawValue)
        }get{
            return defaults.value(forKey: PreferenceKey.IsNotTakenByMe.rawValue) as? Bool ?? false
        }
    }
    
    var isTakenByMe : Bool {
        set{
            defaults.set(newValue, forKey: PreferenceKey.IsTakenByMe.rawValue)
        }get{
            return defaults.value(forKey: PreferenceKey.IsTakenByMe.rawValue) as? Bool ?? false
        }
    }
    
    var deviceInfo: BLEDeviceInfoDTO{
        set{
            defaults.set(newValue.toDict(), forKey: PreferenceKey.BLEDeviceInfo.rawValue)
        }get{
            let infoDict = defaults.value(forKey: PreferenceKey.BLEDeviceInfo.rawValue) as? [String:Any] ?? [:]
            return BLEDeviceInfoDTO(infoDict)
        }
    }
    
    var lapInfo: BLELapInfoDTO{
        set{
            defaults.set(newValue.toDict(), forKey: PreferenceKey.BLELapInfo.rawValue)
        }get{
            let infoDict = defaults.value(forKey: PreferenceKey.BLELapInfo.rawValue) as? [String:Any] ?? [:]
            return BLELapInfoDTO(infoDict)
        }
    }
    
    var transmitterSerialNumber: String{
        set{
            defaults.set(newValue, forKey: PreferenceKey.TransmitterSerialNumber.rawValue)
        }get{
            return defaults.value(forKey: PreferenceKey.TransmitterSerialNumber.rawValue) as? String ?? ""
        }
    }
    
    var firmwareLaterDate: Date?{
        set{
            defaults.set(newValue, forKey: PreferenceKey.BLEFirmwareUpdateLater.rawValue)
        }get{
            return defaults.value(forKey: PreferenceKey.BLEFirmwareUpdateLater.rawValue) as? Date
        }
    }
    
    var isBLEEnabledDevice : Bool {
        set{
            defaults.set(newValue, forKey: PreferenceKey.Is_BLE_Enabled_Device.rawValue)
        }get{
            return defaults.value(forKey: PreferenceKey.Is_BLE_Enabled_Device.rawValue) as? Bool ?? false
        }
    }
    
    var selectedTabBarIndexFromProfile : Int {
        set{
            defaults.set(newValue, forKey: PreferenceKey.SelectedTabBarIndex.rawValue)
        }get{
            return defaults.value(forKey: PreferenceKey.SelectedTabBarIndex.rawValue) as? Int ?? 0
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
    case lastRatingPopupDate = "Z_Last_Rating_Popup_Date"
    
    case IsUserLogin = "S_User_Is_Login"
    case IsTestUser = "S_User_Is_Test_User"
    case IsDemoMode = "Z_User_Is_Demo_User"
    case DemoModeStartDate = "Z_User_Demo_Mode_Start_Date"
    case DemoTotalSeconds = "Z_User_Demo_Total_Seconds"
    
    case AuthToken = "S_User_Auth_Token"
    case DeviceToken = "S_User_Device_Token"
    case UserSubscriedPlan = "userSubscribedPlan"
    case CompletedWorkouts = "Completed_Workouts"
    case LoginType = "User_Login_Type"
    case UserSelectedFilter = "UserSelectedFilter"
    
    case TempoTrainer = "TempoTrainer"
    case AppCurrentVersion = "App_Current_Version"
    
    case BranchLinkWorkoutId = "Z_Branch_link_Workout_id"
    
    case IsTakenByMe = "Z_Is_Taken_By_Me"
    case IsNotTakenByMe = "Z_Is_Not_Take_me"
    
    case TrackingInfo = "Z_Tracking_Info"
    case PoolUnitInfo = "Z_Pool_Units_Info"
    
    case BLEDeviceInfo = "Z_BLE_Device_Info"
    case BLELapInfo = "Z_BLE_Lap_Info"
    case BLEFirmwareUpdateLater = "Z_BLE_Firmware_Update_Later"
    
    case Is_BLE_Enabled_Device = "Z_BLE_Enabled_Device"
    
    case TransmitterSerialNumber = "Z_BLE_Transmitter_Serial_Number"
    case SelectedTabBarIndex = "Z_Selected_Tab_Bar_Index"
    
}
