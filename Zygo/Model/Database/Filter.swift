//
//  Filters.swift
//  Zygo
//
//  Created by Som on 05/02/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit
import RealmSwift

class Filter: Object {
    
    @objc dynamic var headerTitle: String = ""
    @objc dynamic var id: Int = 0
    @objc dynamic var title: String = ""
    @objc dynamic var status: String = FilterStatus.pending.rawValue
    @objc dynamic var icon: String = ""
    
    func updateFullInfo(_ dict: [String: Any], headerTitle: String, icon: String){
        self.headerTitle = headerTitle
        self.id = dict["id"] as? Int ?? 0
        let tTitle = dict["title"] as? Int ?? 0
        self.title = tTitle > 0 ? "\(tTitle)" : dict["title"] as? String ?? ""
        self.icon = icon
        self.status = FilterStatus.updated.rawValue
    }
    
    func update(_ dict: [String: Any], icon: String){
        let tTitle = dict["title"] as? Int ?? 0
        self.title = tTitle > 0 ? "\(tTitle)" : dict["title"] as? String ?? ""
        self.status = FilterStatus.updated.rawValue
        self.icon = icon
    }
}


enum FilterStatus: String {
    case pending = "Pending"
    case updated = "Updated"
}
