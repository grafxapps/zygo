//
//  UserServices.swift
//  Zygo
//
//  Created by Som on 29/01/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit

final class UserServices: NSObject {
    
    func createProfile(user: CreateProfileDTO, completion: @escaping (String?, String) -> Void){
        let param = [
            "email": user.email,
            "user_first_name": user.fname,
            "user_last_name": user.lname,
            "user_display_name": user.name,
            "user_gender": user.gender,
            "user_birthday": user.birthday,
            "profile_location": user.location,
        ] as [String : String]
        
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
                    
                    let jsonResponse = jsonresponse[AppKeys.data.rawValue] as? [String:Any] ?? [:]
                    
                    let user = UserDTO(jsonResponse)
                    let workoutInfo = WorkoutInfoDTO(jsonResponse)
                    let notificationInfo = NotificationInfoDTO(jsonResponse)
                    let friendsInfo = FriendsInfoDTO(jsonResponse)
                    
                    PreferenceManager.shared.completedWorkouts =  (jsonResponse["workouts_completed"] as? String ?? "").components(separatedBy: ",").map({ Int($0) ?? 0 })
                    
                    //completedWorkouts
                    
                    if let subInfoDic = jsonResponse["user_subscriptions"] as? [String: Any]{
                        
                        let planId = subInfoDic["plan_id"] as? String ?? ""
                        let subscriptionId = subInfoDic["subscription_id"] as? String ?? ""
                        let strExpireDate = subInfoDic["expire_date"] as? String ?? ""
                        let subscriptionType = subInfoDic["subscription_type"] as? String ?? ""
                        
                        let subscriptionDict = [
                            "expiry_date": strExpireDate,
                            "transaction_id": subscriptionId,
                            "plan_id": planId,
                            "subscription_type": subscriptionType
                        ]
                        
                        PreferenceManager.shared.currentSubscribedProduct = PurchasedSubscription(subscriptionDict)
                    }else{
                        PreferenceManager.shared.currentSubscribedProduct = nil
                    }
                    
                    //Save user obj in preference
                    PreferenceManager.shared.userId = user.uId
                    PreferenceManager.shared.user = user
                    PreferenceManager.shared.workoutInfo = workoutInfo
                    PreferenceManager.shared.notificationInfo = notificationInfo
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
}
