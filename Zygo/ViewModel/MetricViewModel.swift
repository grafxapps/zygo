//
//  MetricViewModel.swift
//  Zygo
//
//  Created by Som on 26/03/22.
//  Copyright © 2022 Somparkash. All rights reserved.
//

import UIKit

final class MetricViewModel: NSObject {
    
    private let userService = UserServices()
    private let onDaySeconds: Int = 86400
    
    func getGraphData(withDate cDate: Date, completion: @escaping ([GraphMonthDTO]) -> Void){
        
        let month = Int(cDate.toFormat(format: "MM")) ?? 0
        let year = Int(cDate.toFormat(format: "yyyy")) ?? 0
        
        let dateForCal = "\(year)-\(month)-01".convertToFormat("yyyy-MM-dd")
        
        let days = Helper.shared.getNumberOfDays(from: month, and: year)
        self.userService.getGraphData(for: month, year: year, days: days) { (error, dataDict) in
            DispatchQueue.main.async {
             
                if error != nil{
                    Helper.shared.alert(title: Constants.appName, message: error!)
                    completion([])
                    return
                }
                
                let arrTempMonthly = dataDict["Monthly"] as? [[String: Any]] ?? []
                var arrMonthlyData: [GraphMonthDTO] = []
                for dayIndex in 0...(days-1){
                    
                    let monthDay = dateForCal.addingTimeInterval(Double(self.onDaySeconds * dayIndex))
                    let strDay = monthDay.toFormat(format: "yyyy-MM-dd")
                    
                    if let index = arrTempMonthly.firstIndex(where: { $0["day"] as? String ?? "" == strDay }){
                        let item = GraphMonthDTO(arrTempMonthly[index])
                        arrMonthlyData.append(item)
                    }else{
                        var item = GraphMonthDTO([:])
                        item.day = strDay
                        item.distance = 0
                        item.duration = 0
                        arrMonthlyData.append(item)
                    }
                }
                
                completion(arrMonthlyData)
            }
        }
    }
    
    func getYearlyGraphData(completion: @escaping ([GraphAllMonthDTO]) -> Void){
        
        self.userService.getYearlyGraphData() { (error, dataDict) in
            DispatchQueue.main.async {
             
                if error != nil{
                    Helper.shared.alert(title: Constants.appName, message: error!)
                    completion([])
                    return
                }
                
                let arrTempYears = dataDict.keys
                let arrYears = arrTempYears.sorted(by: { Int($0)! < Int($1)! })
                var arrYearlyData: [GraphAllMonthDTO] = []
                
                let currentYear = DateHelper.shared.currentLocalDateTime.convertToFormat("yyyy")
                let currentMonth = DateHelper.shared.currentLocalDateTime.convertToFormat("MMM")
                for year in arrYears{
                    
                    let yearDict = dataDict[year] as? [String: Any] ?? [:]
                    let arrMonthKeys = yearDict.keys
                    let yearTempDate =  "01-01-\(year)"
                    let yearDate = yearTempDate.convertToFormat("dd-MM-yyyy")
                    for monthIndex in 0..<12{
                        
                        if let nextMonth = Calendar.current.date(byAdding: .month, value: monthIndex, to: yearDate){
                            let strMonth = nextMonth.convertToFormat("MMM")
                            if let index = arrMonthKeys.firstIndex(of: strMonth){
                                let monthDict = yearDict[arrMonthKeys[index]] as? [String: Any] ?? [:]
                                
                                var monthItem = GraphAllMonthDTO(monthDict)
                                monthItem.month = (strMonth as NSString).substring(to: 1)
                                monthItem.year = (year as NSString).substring(from: 2)
                                if strMonth == "Jan"{
                                    monthItem.isShowYear = true
                                }
                                
                                if year == currentYear{
                                    if strMonth == currentMonth{
                                        arrYearlyData.append(monthItem)
                                        break
                                    }else{
                                        arrYearlyData.append(monthItem)
                                    }
                                }else{
                                    arrYearlyData.append(monthItem)
                                }
                            }else{
                                var monthItem = GraphAllMonthDTO([:])
                                monthItem.duration = 0
                                monthItem.distance = 0
                                monthItem.month = (strMonth as NSString).substring(to: 1)
                                monthItem.year = (year as NSString).substring(from: 2)
                                if strMonth == "Jan"{
                                    monthItem.isShowYear = true
                                }
                                
                                if year == currentYear{
                                    if strMonth == currentMonth{
                                        arrYearlyData.append(monthItem)
                                        break
                                    }else{
                                        arrYearlyData.append(monthItem)
                                    }
                                }else{
                                    arrYearlyData.append(monthItem)
                                }
                                
                            }
                        }
                    }
                }
                                
                completion(arrYearlyData)
            }
        }
    }
}

struct GraphMonthDTO {
    var day: String = ""//Date()
    var distance: Double = 0
    var duration: Double = 0
    
    init(_ dict: [String: Any]){
        //let strDay = dict["day"] as? String ?? ""
        self.day = dict["day"] as? String ?? ""//strDay.convertToFormat("yyyy-MM-dd")
        let tempDistance = dict["day_distance"] as? Double ?? Double(dict["day_distance"] as? String ?? "0") ?? 0
        self.distance = tempDistance
        self.duration = dict["day_duration"] as? Double ?? Double(dict["day_duration"] as? String ?? "0") ?? 0
    }
}

struct GraphAllMonthDTO {
    var month: String = ""
    var year: String = ""
    var isShowYear: Bool = false
    var distance: Double = 0
    var duration: Double = 0
    
    init(_ dict: [String: Any]){
        let tempDistance = dict["distance"] as? Double ?? Double(dict["distance"] as? String ?? "0") ?? 0
        self.distance = tempDistance//Helper.shared.convertYardToUserPreference(distance: tempDistance)
        self.duration = dict["duration"] as? Double ?? Double(dict["duration"] as? String ?? "0") ?? 0
    }
}
