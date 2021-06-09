//
//  AchievementDTO.swift
//  Zygo
//
//  Created by Som on 16/02/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit

struct AchievementDTO {
    
    var name: String = ""
    var caregory: String = ""
    var type: String = ""
    var message: String = ""
    var descriptions: String = ""
    var icon: String = ""
    
    init(_ dict: [String: Any]) {
        
        self.name = dict["achievement_name"] as? String ?? ""
        self.caregory = dict["achievement_category"] as? String ?? ""
        self.type = dict["achievement_type"] as? String ?? ""
        self.message = dict["achievement_message"] as? String ?? ""
        self.descriptions = dict["achievement_description"] as? String ?? ""
        self.icon = dict["achievement_icon"] as? String ?? ""
    }
}
