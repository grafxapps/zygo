//
//  HallOfFameModel.swift
//  Zygo
//
//  Created by Som Parkash on 26/11/23.
//  Copyright © 2023 Somparkash. All rights reserved.
//

import UIKit

struct HallOfFameModel {
    
    var userId: Int = 0
    var userName: String = ""
    var createdDate: Date?
    var firstName: String = ""
    var lastName: String = ""
    var profilePic: String = ""
    var location: String = ""
    var totalClasses: Int = 0
    var totalDistance: Double = 0
    
    init(_ dict: [String: Any]) {
        self.userId = dict["user_id"] as? Int ?? 0
        self.userName = dict["username"] as? String ?? ""
        if let strCreatedDate = dict["createdDate"] as? String{
            self.createdDate = strCreatedDate.convertToFormat("yyyy-MM-dd")
        }
        self.firstName = dict["firstname"] as? String ?? ""
        self.lastName = dict["lastname"] as? String ?? ""
        self.profilePic = dict["profilepic"] as? String ?? ""
        self.location = dict["location"] as? String ?? ""
        self.totalClasses = dict["total_classes"] as? Int ?? 0
        self.totalDistance = dict["total_distance"] as? Double ?? 0
    }
    
    enum FameType: String{
        case classes = "class"
        case distance = "distance"
    }
    
    enum FameTime: String{
        case all = "all"
        case month = "month"
    }
}
