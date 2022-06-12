//
//  UserServices.swift
//  Zygo
//
//  Created by Som on 29/01/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit

final class UserServices: NSObject {
    
    func createProfile(user: CreateProfileDTO, poolInfo: PoolUnitInfoDTO, completion: @escaping (String?, String) -> Void){
        let param = [
            "email": user.email,
            "user_first_name": user.fname,
            "user_last_name": user.lname,
            "user_display_name": user.name,
            "user_gender": user.gender,
            "user_birthday": user.birthday,
            "profile_location": user.location,
            "transmitter_serial_number": user.tSerialNumber,
            "handset_serial_number": user.hSerialNumber,
            "custom_pool_length_units": poolInfo.customPoolLengthUnits.rawValue,
            "unit_preference": poolInfo.unitPref.rawValue,
            "custom_pool_length_dist": "\(poolInfo.customPoolDistance)",
            "default_pool_length": poolInfo.defaultPoolLength.rawValue
        ] as [String : String]
        print(param)
        let imageData = user.image?.jpegData(compressionQuality: 0.2)
        let header = NetworkManager.shared.getHeader()
        let url = Constants.baseUrl + APIEndPoint.updateProfile.rawValue
        
        NetworkManager.shared.uploadImage(withUrl: url, method: .post, headers: header, params: param, imageData: imageData, imageName: "user_profile_pic") { (response) in
            
            switch response{
            case .success(let response):
                let uImage = response["user_profile_pic"] as? String ?? ""
                completion(nil,uImage)
            case .failure(_, let message):
                completion(message, "")
            case .notConnectedToInternet:
                completion(Constants.internetNotWorking, "")
            }
        }
    }
    
    func getUserProfile(completion: @escaping (String?) -> Void){
        
        let header = NetworkManager.shared.getHeader()
        NetworkManager.shared.request(withEndPoint: .getProfile, method: .get, headers: header, params: [:]) { (response) in
            switch response{
            case .success(let jsonresponse):
                print(jsonresponse)
                let jsonResponse = jsonresponse[AppKeys.data.rawValue] as? [String:Any] ?? [:]
                
                let user = UserDTO(jsonResponse)
                let workoutInfo = WorkoutInfoDTO(jsonResponse)
                let notificationInfo = NotificationInfoDTO(jsonResponse)
                let trackingInfo = TrackingInfoDTO(jsonResponse)
                let poolUnitInfo = PoolUnitInfoDTO(jsonResponse)
                let friendsInfo = FriendsInfoDTO(jsonResponse)
                
                PreferenceManager.shared.isTestUser = NSNumber(value: (Int(jsonResponse["test_user"] as? String ?? "0") ?? 0)).boolValue
                
                let strRatingDate = jsonResponse["rating_popup_date"] as? String ?? ""
                if !strRatingDate.isEmpty{
                    PreferenceManager.shared.lastRatingPopupDate = strRatingDate.convertToFormat("yyyy-MM-dd")
                }
                
                
                PreferenceManager.shared.completedWorkouts =  (jsonResponse["workouts_completed"] as? String ?? "").components(separatedBy: ",").map({ Int($0) ?? 0 })
                
                //completedWorkouts
                
                if let subInfoDic = jsonResponse["user_subscriptions"] as? [String: Any]{
                    
                    let subscriptionType = subInfoDic["subscription_type"] as? String ?? ""
                    if subscriptionType == SubscriptionType.Apple.rawValue{
                        let planId = subInfoDic["apple_plan_id"] as? String ?? ""
                        let subscriptionId = subInfoDic["apple_subscription_id"] as? String ?? ""
                        let strExpireDate = subInfoDic["expire_date"] as? String ?? ""
                        let originalTransactionId = subInfoDic["apple_unique_id"] as? String ?? ""
                        
                        let subscriptionDict = [
                            "expiry_date": strExpireDate,
                            "transaction_id": subscriptionId,
                            "plan_id": planId,
                            "subscription_type": subscriptionType,
                            "original_transaction_id": originalTransactionId
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
                PreferenceManager.shared.trackingInfo = trackingInfo
                PreferenceManager.shared.poolUnitInfo = poolUnitInfo
                PreferenceManager.shared.friendsInfo = friendsInfo
                completion(nil)
            case .failure(_ , let message):
                completion(message)
            case .notConnectedToInternet:
                completion(Constants.internetNotWorking)
            }
        }
    }
    
    func getUserHistory(completion: @escaping (String?, [WorkoutLogDTO], [AchievementDTO]) -> Void){
        let header = NetworkManager.shared.getHeader()
        NetworkManager.shared.request(withEndPoint: .userHistory, method: .get, headers: header, params: [:]) { (response) in
            switch response{
            case .success(let jsonresponse):
                
                let userDict = jsonresponse["user_data"] as? [String: Any] ?? [:]
                let userItem = UserDTO(userDict)
                var myUser = PreferenceManager.shared.user
                myUser.timeInWater = userItem.timeInWater
                myUser.workoutCount = userItem.workoutCount
                PreferenceManager.shared.user = myUser
                
                let workoutLogs = jsonresponse["work_data"] as? [[String: Any]] ?? []
                var arrLogs: [WorkoutLogDTO] = []
                for logDict in workoutLogs{
                    arrLogs.append(WorkoutLogDTO(logDict))
                }
                
                
                let arrTempAchievements = jsonresponse["user_achievements"] as? [[String: Any]] ?? []
                
                var arrAchievements: [AchievementDTO] = []
                for achievementDict in arrTempAchievements{
                    arrAchievements.append(AchievementDTO(achievementDict))
                }
                
                completion(nil, arrLogs, arrAchievements)
            case .failure(_ , let message):
                completion(message, [], [])
            case .notConnectedToInternet:
                completion(Constants.internetNotWorking, [], [])
            }
        }
    }
    
    func updateNotificationSettings(type: String, status: Int, completion: @escaping (String?) -> Void){
        let param = [
            "type": type,
            "status": status
        ] as [String : AnyObject]
        let header = NetworkManager.shared.getHeader()
        
        NetworkManager.shared.request(withEndPoint: .notificationSetting, method: .post, headers: header, params: param) { (response) in
            
            switch response{
            case .success(_ ):
                completion(nil)
            case .failure(_, let message):
                completion(message)
            case .notConnectedToInternet:
                completion(Constants.internetNotWorking)
            }
        }
    }
    
    func updateTrackingSettings(type: String, status: Int, completion: @escaping (String?) -> Void){
        let param = [
            "type": type,
            "status": status
        ] as [String : AnyObject]
        let header = NetworkManager.shared.getHeader()
        
        NetworkManager.shared.request(withEndPoint: .trackingSettings, method: .post, headers: header, params: param) { (response) in
            
            switch response{
            case .success(_ ):
                completion(nil)
            case .failure(_, let message):
                completion(message)
            case .notConnectedToInternet:
                completion(Constants.internetNotWorking)
            }
        }
    }
    
    func getGraphData(for month: Int , year: Int, days: Int ,completion: @escaping (String?, [String:Any]) -> Void){
        let param = [
            "month": month,
            "year": year
        ] as [String : AnyObject]
        let header = NetworkManager.shared.getHeader()
        
        NetworkManager.shared.request(withEndPoint: .graph, method: .get, headers: header, params: param) { (response) in
            
            switch response{
            case .success(let jsonResponse):
                print(jsonResponse)
                let dataDict = jsonResponse["data"] as? [String: Any] ?? [:]
                completion(nil, dataDict)
            case .failure(_, let message):
                completion(message, [:])
            case .notConnectedToInternet:
                completion(Constants.internetNotWorking, [:])
            }
        }
    }
    
    func getYearlyGraphData(completion: @escaping (String?, [String:Any]) -> Void){
        let header = NetworkManager.shared.getHeader()
        
        NetworkManager.shared.request(withEndPoint: .graphYearly, method: .get, headers: header, params: [:]) { (response) in
            
            switch response{
            case .success(let jsonResponse):
                print(jsonResponse)
                let dataDict = jsonResponse["data"] as? [String: Any] ?? [:]
                completion(nil, dataDict)
            case .failure(_, let message):
                completion(message, [:])
            case .notConnectedToInternet:
                completion(Constants.internetNotWorking, [:])
            }
        }
    }
    
    func forceUpgrade(completion: @escaping (String?) -> Void){
        
        // let header = NetworkManager.shared.getHeader()
        NetworkManager.shared.request(withEndPoint: .forceUpgrade, method: .get, headers: [:], params: [:]) { (response) in
            
            switch response{
            case .success(let jsonResponse):
                guard let dataDict = jsonResponse["data"] as? [String: Any] else {
                    completion(nil)
                    return
                }
                PreferenceManager.shared.appCurrentVersion = dataDict["ios_app_version"] as? String ?? ""
                completion(nil)
            case .failure(_, let message):
                completion(message)
            case .notConnectedToInternet:
                completion(Constants.internetNotWorking)
            }
        }
    }
    
    func updateRatingPopupDate(completion: @escaping (String?) -> Void){
        
        let param = [
            "rating_popup_date": DateHelper.shared.currentUTCDateTime.convertToFormat("yyyy-MM-dd", isUTC: true)]
        
         let header = NetworkManager.shared.getHeader()
        NetworkManager.shared.request(withEndPoint: .ratingPopupDate, method: .post, headers: header, params: param) { (response) in
            
            switch response{
            case .success(let jsonResponse):
                print(jsonResponse)
                completion(nil)
            case .failure(_, let message):
                completion(message)
            case .notConnectedToInternet:
                completion(Constants.internetNotWorking)
            }
        }
    }
    
    func updateHomeCountry(completion: @escaping (String?) -> Void){
        let code = NSLocale.current.regionCode ?? ""
        print("Country: \(code)")
        let param = [
            "home_country": code
        ]
        
        let header = NetworkManager.shared.getHeader()
        NetworkManager.shared.request(withEndPoint: .homeCountry, method: .post, headers: header, params: param) { (response) in
            
            switch response{
            case .success(let jsonResponse):
                print(jsonResponse)
                completion(nil)
            case .failure(_, let message):
                completion(message)
            case .notConnectedToInternet:
                completion(Constants.internetNotWorking)
            }
        }
    }
}
