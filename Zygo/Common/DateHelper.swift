//
//  DateHelper.swift
//  Zygo
//
//  Created by Som on 16/02/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit
import TrueTime

class DateHelper: NSObject {
    
    static let shared = DateHelper()
    
    private override init() {
    }
    
    func initializeCurrentTime(){
        let client = TrueTimeClient.sharedInstance
        client.start()
        client.fetchIfNeeded(completion:  { result in
            switch result {
            case let .success(referenceTime):
                let now = referenceTime.now()
                print("current accurate time: \(now)")
            case let .failure(error):
                print("Error! \(error)")
            }
        })
    }
    
    var currentUTCDateTime: Date{
        return TrueTimeClient.sharedInstance.referenceTime?.now() ?? Date().toGlobalTime()
    }
    
    var currentLocalDateTime: Date{
        return TrueTimeClient.sharedInstance.referenceTime?.now().toLocalTime() ?? Date()
    }
    
    var workoutCompletedDate: String{
        get{
            return self.currentLocalDateTime.toFormat(format: "yyyy-dd-MM")
        }
    }
    
}

extension Date{
    
    func toGlobalTime() -> Date {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormat.timeZone = TimeZone(abbreviation: "UTC")
        let utcDateString = dateFormat.string(from: self)
        return dateFormat.date(from: utcDateString)!
        
    }
    
    func toLocalTime() -> Date {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormat.timeZone = TimeZone.current
        let utcDateString = dateFormat.string(from: self)
        return dateFormat.date(from: utcDateString)!
    }
}
