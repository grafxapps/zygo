//
//  NotificationInfoDTO.swift
//  Zygo
//
//  Created by Som on 29/01/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit

struct NotificationInfoDTO {
    
    var nudgeNotifications: Bool = false
    var eventNotifications: Bool = false
    var promoNotifications: Bool = false
    var nudgeReceived_two_week: Bool = false
    var nudgeReceived_one_month: Bool = false
    var friendsAchNotifications: Bool = false
    var teamAchNotifications: Bool = false
    var groupAchNotifications: Bool = false
    
    init(_ dict: [String: Any]) {
        self.nudgeNotifications = NSNumber(value: dict["nudge_notifications"] as? Int ?? 0).boolValue
        
        self.eventNotifications = NSNumber(value: dict["event_notifications"] as? Int ?? 0).boolValue
        self.promoNotifications = NSNumber(value: dict["promo_notifications"] as? Int ?? 0).boolValue
        self.nudgeReceived_two_week = NSNumber(value: dict["nudge_received_two_week"] as? Int ?? 0).boolValue
        self.nudgeReceived_one_month = NSNumber(value: dict["nudge_received_one_month"] as? Int ?? 0).boolValue
        self.friendsAchNotifications = NSNumber(value: dict["friends_ach_notifications"] as? Int ?? 0).boolValue
        self.teamAchNotifications = NSNumber(value: dict["team_ach_notifications"] as? Int ?? 0).boolValue
        self.groupAchNotifications = NSNumber(value: dict["group_ach_notifications"] as? Int ?? 0).boolValue
    }
    
    func toDict() -> [String: Any]{
        return [
            "nudge_notifications": NSNumber(value: self.nudgeNotifications).intValue,
            "event_notifications": NSNumber(value: self.eventNotifications).intValue,
            "promo_notifications": NSNumber(value: self.promoNotifications).intValue,
            "nudge_received_two_week": NSNumber(value: self.nudgeReceived_two_week).intValue,
            "nudge_received_one_month": NSNumber(value: self.nudgeReceived_one_month).intValue,
            "friends_ach_notifications": NSNumber(value: self.friendsAchNotifications).intValue,
            "team_ach_notifications": NSNumber(value: self.teamAchNotifications).intValue,
            "group_ach_notifications": NSNumber(value: self.groupAchNotifications).intValue
        ]
    }
}


