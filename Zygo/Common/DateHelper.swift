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
            return self.currentLocalDateTime.toFormat(format: "yyyy-MM-dd")
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

extension Date{
    func convertToFormat(_ format: String, isLocal: Bool = false, isGMT: Bool = false) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = format
        if isLocal{
            formatter.timeZone = TimeZone.current
        }
        
        if isGMT{
            formatter.locale = Locale.init(identifier: "GMT")
        }
        
        formatter.locale = Locale.init(identifier: "en_US_POSIX")
        //formatter.locale = Locale.init(identifier: PreferenceManager.shared.language)
        return formatter.string(from: self)
    }
    
    func toTZUTC() -> String{
        let strDate = self.convertToFormat("yyyy-MM-dd'T'HH:mm:ss")
        return "\(strDate).000Z"
    }
    
    func toStartOfTheDayUTC() -> Date{
        
        let dateString = "\(self.convertToFormat("yyyy-MM-dd"))"// 00:00:00 +0000"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let dateFromString = dateFormatter.date(from: dateString.components(separatedBy: " ").first ?? "")
        return dateFromString!
    }
}


extension Date {
    
    // Convert local time to UTC (or GMT)
    func toSGlobalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = -TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
    
    // Convert UTC (or GMT) to local time
    func toSLocalTime() -> Date {
        
        // 1) Get the current TimeZone's seconds from GMT. Since I am in Chicago this will be: 60*60*5 (18000)
        let timezoneOffset = TimeZone.current.secondsFromGMT()
        
        // 2) Get the current date (GMT) in seconds since 1970. Epoch datetime.
        let epochDate = self.timeIntervalSince1970
        
        // 3) Perform a calculation with timezoneOffset + epochDate to get the total seconds for the
        //    local date since 1970.
        //    This may look a bit strange, but since timezoneOffset is given as -18000.0, adding epochDate and timezoneOffset
        //    calculates correctly.
        let timezoneEpochOffset = (epochDate + Double(timezoneOffset))
        
        
        // 4) Finally, create a date using the seconds offset since 1970 for the local date.
        return Date(timeIntervalSince1970: timezoneEpochOffset)
    }
    
}
