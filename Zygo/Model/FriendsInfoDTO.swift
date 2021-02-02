//
//  FriendsInfoDTO.swift
//  Zygo
//
//  Created by Som on 29/01/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit

struct FriendsInfoDTO {
    
    var memberOfTeams: String = ""
    var memberOfGroups: String = ""
    var friends: String = ""
    var blockedId: String = ""
    
    init(_ dict: [String: Any]) {
        self.memberOfTeams = dict["member_of_teams"] as? String ?? ""
        
        self.memberOfGroups = dict["member_of_groups"] as? String ?? ""
        self.friends = dict["friends"] as? String ?? ""
        self.blockedId = dict["blocked_id"] as? String ?? ""
    }
    
    func toDict() -> [String: Any]{
        return [
            "member_of_teams": self.memberOfTeams,
            "member_of_groups": self.memberOfGroups,
            "friends": self.friends,
            "blocked_id": self.blockedId
        ]
    }
}

