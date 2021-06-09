//
//  GroupedFilterDTO.swift
//  Zygo
//
//  Created by Som on 03/02/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit

struct GroupedFilterDTO {
    
    var title: String = ""
    var icon: String = ""
    var filters: [FilterDTO] = []
    
    init(_ dict: [String: Any]) {
        self.title = dict["title"] as? String ?? ""
        
        let arrTempFilters = dict["filters"] as? [[String: Any]] ?? []
        self.filters.removeAll()
        for fDict in arrTempFilters{
            filters.append(FilterDTO(fDict))
        }
        
        if filters.count > 0{
            if Int(filters.first!.fTitle) != nil{
                filters.sort(by: { Int($0.fTitle) ?? 0 < Int($1.fTitle) ?? 0 })
            }else if self.title == "Difficulty Level"{
                filters.sort(by: { $0.fId < $1.fId })
            }else{
                filters.sort(by: { $0.fTitle.localizedCaseInsensitiveCompare($1.fTitle) == .orderedAscending })
            }
        }
        
    }
    
    init(_ fItems: [Filter], title: String, icon: String) {
        if fItems.count > 0{
            
            self.title = title
            self.icon = icon
            
            var tempFilters: [FilterDTO] = []
            for fItem in fItems {
                tempFilters.append(FilterDTO(fItem))
            }
            self.filters = tempFilters
            
            if filters.count > 0{
                if Int(filters.first!.fTitle) != nil{
                    filters.sort(by: { Int($0.fTitle) ?? 0 < Int($1.fTitle) ?? 0 })
                }else if self.title == "Difficulty Level"{
                    filters.sort(by: { $0.fId < $1.fId })
                }else{
                    filters.sort(by: { $0.fTitle.localizedCaseInsensitiveCompare($1.fTitle) == .orderedAscending })
                }
            }
        }
        
    }
    
    init(_ fItems: [FilterDTO], title: String, icon: String) {
        if fItems.count > 0{
            self.icon = icon
            self.title = title
            self.filters = fItems
            
            if filters.count > 0{
                if Int(filters.first!.fTitle) != nil{
                    filters.sort(by: { Int($0.fTitle) ?? 0 < Int($1.fTitle) ?? 0 })
                }else if self.title == "Difficulty Level"{
                    filters.sort(by: { $0.fId < $1.fId })
                }else{
                    filters.sort(by: { $0.fTitle.localizedCaseInsensitiveCompare($1.fTitle) == .orderedAscending })
                }
            }
        }
        
    }
    
    func toDict() -> [String: Any]{
        return [
            "icon": self.icon,
            "title": self.title,
            "filters": self.filters.map({ $0.toDict() })
        ]
        
        
    }
    
}

struct FilterDTO {
    
    var fId: Int = -1
    var fTitle: String = ""
    
    init(_ dict: [String: Any]) {
        self.fTitle = dict["title"] as? String ?? ""
        self.fId = dict["id"] as? Int ?? -1
        
    }
    
    init(_ fItem: Filter) {
        self.fId = fItem.id
        self.fTitle = fItem.title
    }
    
    func toDict() -> [String: Any]{
        return [
            "id": self.fId,
            "title": self.fTitle
        ]
    }
    
}

