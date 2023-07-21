//
//  UserDTO.swift
//  Zygo
//
//  Created by Priya Gandhi on 23/01/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit

struct UserDTO {
    
    var uId: Int = -1
    var name: String = ""
    var fName: String = ""
    var lName: String = ""
    var email: String = ""
    var password: String = ""
    var created: String = ""
    var profilePic: String = ""
    var gender: String = ""
    var birthday: String = ""
    var location: String = ""
    var lastLocation: String = ""
    var isActive: Int = -1
    var timeInWater: Double = 0
    var totalDistance: Double = 0 //In Yards
    var workoutCount: Int = 0
    
    var hSerialNumber: String = ""
    var tSerialNumber: String = ""
    
    init(_ dict: [String:Any]) {
        
        self.created = dict["created_at"] as? String ?? ""
        
        self.name = dict["user_display_name"] as? String ?? ""
        self.fName = dict["user_first_name"] as? String ?? ""
        self.lName = dict["user_last_name"] as? String ?? ""
        
        self.email = dict["email"] as? String ?? ""
        self.uId = dict["id"] as? Int ?? -1
        self.isActive = dict["user_is_active"] as? Int ?? -1
        self.profilePic = dict["user_profile_pic"] as? String ?? ""
        self.gender = dict["user_gender"] as? String ?? ""
        
        self.birthday = dict["user_birthday"] as? String ?? ""
        
        self.location = dict["profile_location"] as? String ?? ""
        self.lastLocation = dict["last_location"] as? String ?? ""
        
        self.timeInWater = dict["time_in_water"] as? Double ?? 0
        self.totalDistance = dict["total_distance"] as? Double ?? Double(dict["total_distance"] as? String ?? "0") ?? 0
        self.workoutCount =  dict["workout_count"] as? Int ?? 0
        
        self.hSerialNumber = dict["handset_serial_number"] as? String ?? ""
        self.tSerialNumber = dict["transmitter_serial_number"] as? String ?? ""
        
    }
    
    func toDict() -> [String:Any]{
        return [
            "user_display_name": self.name,
            "email": self.email,
            "id" : self.uId,
            "created": self.created,
            "user_is_active" : self.isActive,
            "user_profile_pic": self.profilePic,
            "user_gender": self.gender,
            "user_birthday": self.birthday,
            "profile_location": self.location,
            "last_location": self.lastLocation,
            "user_first_name": self.fName,
            "user_last_name": self.lName,
            "workout_count": self.workoutCount,
            "time_in_water": self.timeInWater,
            "total_distance": self.totalDistance,
            "transmitter_serial_number": self.tSerialNumber,
            "handset_serial_number": self.hSerialNumber
        ]
    }
}


struct UserSubscriptionInfoDTO {
    
    var planId: String = ""
    var subscriptionId: String = ""
    var promoCodeId: String = ""
    var trailDays: String = ""
    var amount: String = ""
    var startDate: Date = DateHelper.shared.currentLocalDateTime
    var expireDate: Date = DateHelper.shared.currentLocalDateTime
    var subscriptionStatus: SubscriptionStatus = .inactive
    var subscriptionType: String = ""
    
    init(_ dict: [String: Any]) {
        
        self.planId = dict["plan_id"] as? String ?? ""
        self.subscriptionId = dict["subscription_id"] as? String ?? ""
        self.promoCodeId = dict["promo_code_id"] as? String ?? ""
        self.trailDays = dict["trail_days"] as? String ?? ""
        self.amount = dict["amount"] as? String ?? ""
        
        let strStartDate = dict["start_date"] as? String ?? ""
        if !strStartDate.isEmpty{
            self.startDate = strStartDate.convertToFormat("yyyy-MM-dd HH:mm:ss")
        }
        
        let strExpireDate = dict["expire_date"] as? String ?? ""
        if !strExpireDate.isEmpty{
            self.expireDate = strExpireDate.convertToFormat("yyyy-MM-dd HH:mm:ss")
        }
        
        self.subscriptionStatus = SubscriptionStatus(rawValue: dict["subscription_status"] as? String ?? "") ?? .inactive
        self.subscriptionType = dict["subscription_type"] as? String ?? ""
    }
    
    func toDict() -> [String: Any]{
        return [
            "plan_id": self.planId,
            "subscription_id": self.subscriptionId,
            "promo_code_id": self.promoCodeId,
            "trail_days": self.trailDays,
            "start_date": self.startDate.convertToFormat("yyyy-MM-dd HH:mm:ss"),
            "expire_date": self.expireDate.convertToFormat("yyyy-MM-dd HH:mm:ss"),
            "amount": self.amount,
            "subscription_status": self.subscriptionStatus.rawValue,
            "subscription_type": self.subscriptionType
        ]
    }
}

enum SubscriptionStatus: String {
    case active = "active"
    case inactive = "inactive"
}
