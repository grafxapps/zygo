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
            "user_last_name": self.lName
        ]
    }
}

