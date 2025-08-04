//
//  WorkoutsServices.swift
//  Zygo
//
//  Created by Som on 30/01/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit

final class WorkoutsServices: NSObject {
    
    func getDefaultWorkouts(completion: @escaping (String?, [WorkoutDTO]) -> Void){
        let header = NetworkManager.shared.getHeader()
        NetworkManager.shared.request(withEndPoint: .getWorkouts, method: .get, headers: header, params: [:]) { (response) in
            switch response{
            case .success(let response):
                guard let arrData = response["data"] as? [[String:Any]] else{
                    completion(nil, [])
                    return
                }
                
                var arrWorkouts: [WorkoutDTO] = []
                for workoutDict in arrData{
                    arrWorkouts.append(WorkoutDTO(workoutDict))
                }
                
                completion(nil, arrWorkouts)
            case .failure(_ , let message):
                completion(message, [])
            case .notConnectedToInternet:
                completion(Constants.internetNotWorking, [])
            }
        }
    }
    
    func getFilteredWorkouts(filters: [GroupedFilterDTO], completion: @escaping (String?, [WorkoutDTO]) -> Void){
        let header = NetworkManager.shared.getHeader()
        
        var params: [String: Any] = [:]
        for item in filters{
            
            if item.filters.count > 0{
                let key = item.title.replacingOccurrences(of: " ", with: "_").lowercased()
                let value = item.filters.map({ "\($0.fId)" }).joined(separator: ",")
                if key == "video"{
                    params["with_video"] = value
                }else{
                    params["\(key)_id"] = value
                }
                
            }
        }
        
        if PreferenceManager.shared.isTakenByMe{
            params["taken_by_me"] = 1
        }else if PreferenceManager.shared.isNotTakenByMe{
            params["not_taken_by_me"] = 1
        }
        
        NetworkManager.shared.request(withEndPoint: .getWorkouts, method: .get, headers: header, params: params) { (response) in
            switch response{
            case .success(let response):
                guard let arrData = response["data"] as? [[String:Any]] else{
                    completion(nil, [])
                    return
                }
                
                var arrWorkouts: [WorkoutDTO] = []
                for workoutDict in arrData{
                    arrWorkouts.append(WorkoutDTO(workoutDict))
                }
                
                completion(nil, arrWorkouts)
            case .failure(_ , let message):
                completion(message, [])
            case .notConnectedToInternet:
                completion(Constants.internetNotWorking, [])
            }
        }
    }
    
    
    func getWorkoutsSeries(completion: @escaping (String?, [SeriesDTO]) -> Void){
        let header = NetworkManager.shared.getHeader()
        NetworkManager.shared.request(withEndPoint: .getWorkoutsSeries, method: .get, headers: header, params: [:]) { (response) in
            switch response{
            case .success(let response):
                guard let arrData = response["data"] as? [[String:Any]] else{
                    completion(nil, [])
                    return
                }
                
                var arrWorkouts: [SeriesDTO] = []
                for workoutDict in arrData{
                    arrWorkouts.append(SeriesDTO(workoutDict))
                }
                
                completion(nil, arrWorkouts)
            case .failure(_ , let message):
                completion(message, [])
            case .notConnectedToInternet:
                completion(Constants.internetNotWorking, [])
            }
        }
    }
    
    func getWorkoutDetail(by wId: Int, completion: @escaping (String?, WorkoutDTO?) -> Void){
        let header = NetworkManager.shared.getHeader()
        let param = [
            "workout_id" : "\(wId)"
        ]
        
        NetworkManager.shared.request(withEndPoint: .getWorkoutById, method: .get, headers: header, params: param) { (response) in
            switch response{
            case .success(let response):
                guard let dataDict = response["data"] as? [String:Any] else{
                    completion(nil, nil)
                    return
                }
                
                print("Workout Detail: \(response)")
                let arrtempPlayList = response["playlist"] as? [[String: Any]] ?? []
                var arrPlaylist: [PlayListDTO] = []
                for playlistDict in arrtempPlayList{
                    let pItem = PlayListDTO(playlistDict)
                    arrPlaylist.append(pItem)
                }
                
                var item = WorkoutDTO(dataDict)
                item.playlist = arrPlaylist
                
                completion(nil, item)
            case .failure(_ , let message):
                completion(message, nil)
            case .notConnectedToInternet:
                completion(Constants.internetNotWorking, nil)
            }
        }
    }
    
    func getFilters(completion: @escaping (String?, [GroupedFilterDTO]) -> Void){
        NetworkManager.shared.request(withEndPoint: .getWorkoutFilters, method: .get, headers: [:], params: [:]) { (response) in
            switch response{
            case .success(let response):
                
                guard let filterDataDict = response["data"] as? [String:Any] else{
                    let arrFilters = DatabaseManager.shared.getGroupFilters()
                    completion(nil, arrFilters)
                    return
                }
                
                let filterIconsDict = response["icons"] as? [[String:Any]] ?? []
                
                DatabaseManager.shared.updateFilterWithServer(filterDataDict, filterIcons: filterIconsDict) {
                    let arrFilters = DatabaseManager.shared.getGroupFilters()
                    completion(nil, arrFilters)
                }
                
            case .failure(_ , let message):
                completion(message, [])
            case .notConnectedToInternet:
                completion(Constants.internetNotWorking, [])
            }
        }
    }
    
    func completeWorkout(wId: Int, timeInWater: Int, timeElapsed: Int, lat: Double, lng: Double, completion: @escaping (String?, [AchievementDTO], Int) -> Void){
        let header = NetworkManager.shared.getHeader()
        
        var param: [String: Any] = [
            "workout_id": wId,
            "date_of_workout": DateHelper.shared.workoutCompletedDate,
            "app_version": Helper.shared.appVersion,
            "time_elapsed": timeElapsed,
            "workout_location": "Remove It!",
            "lat": lat,
            "lng": lng
        ]
        
        if timeInWater > 0{
            param["time_in_water"] = timeInWater
        }
        print("Complete Workout Params: \(param)")
        NetworkManager.shared.request(withEndPoint: .completeWorkout, method: .post, headers: header, params: param) { (response) in
            switch response{
            case .success(let jsonresponse):
                print(jsonresponse)
                
                guard let arrTempAchievements = jsonresponse["completed_achievements"] as? [[String: Any]] else{
                    completion(nil, [], -1)
                    return
                }
                var arrAchievements: [AchievementDTO] = []
                for achievementDict in arrTempAchievements{
                    arrAchievements.append(AchievementDTO(achievementDict))
                }
                
                let workoutLogId = jsonresponse["workoutlog_id"] as? Int ?? -1
                
                completion(nil, arrAchievements, workoutLogId)
            case .failure(_ , let message):
                completion(message, [], -1)
            case .notConnectedToInternet:
                completion(Constants.internetNotWorking, [], -1)
            }
        }
    }
    
    
    func workoutFeedback(wId: Int, thumbStatus: ThumbStatus, dificultyLevel: Int, workoutLogId: Int, poolLength: Int, poolLengthUnits: String, poolType: String, laps: Int, distance: Double, strokeValue: Int, city: String, timeElapsed: Int, whyBreak: Bool = false, whyEndless: Bool = false, whyNoSync: Bool = false, whyDontKnow: Bool = false, lapData: BLELapInfoDTO?, batteryData: BLEDeviceInfoDTO?, completion: @escaping (String?) -> Void){
        let header = NetworkManager.shared.getHeader()
        
        var param: [String: Any] = [
            "workout_id": wId,
            "workoutlog_id": workoutLogId
        ]
        
        if thumbStatus != .none{
            param["is_thumbs"] = thumbStatus == .up ? "1" : "0"
        }
        
        if dificultyLevel > 0{
            param["rating"] = "\(dificultyLevel)"
        }
        
        if poolLength > 0{
            param["pool_length"] = poolLength
        }
        
        if !poolLengthUnits.isEmpty{
            param["pool_length_units"] = poolLengthUnits
        }
        
        if !poolType.isEmpty{
            param["pool_type"] = poolType
        }
        
        if laps > 0{
            param["laps"] = laps
        }
        
        if distance > 0{
            param["distance"] = distance
        }
        
        if strokeValue > 0{
            param["stroke_value"] = strokeValue
        }
        
        if let rawLaps = lapData?.numberOfLaps{
            param["laps_headset_raw"] = rawLaps
        }
        
        if let value = lapData?.startStopStatus{
            param["headset_start_stop"] = value
        }
        
        if let value = lapData?.numberOfLaps{
            param["laps_headset_calc"] = value
        }
        
        if let value = lapData?.totalTime{
            param["time_elapsed_headset"] = value
        }
        
        param["time_elapsed_workout"] = timeElapsed
        
        if let value = lapData?.serialNumber{
            let deviceInfo = PreferenceManager.shared.deviceInfo
            if deviceInfo.versionInfo.zygoDeviceVersion == .v2{
                let transmitter = PreferenceManager.shared.transmitterSerialNumber
                param["headset_sn"] = "\(value)/\(transmitter)"
            }else{
                param["headset_sn"] = value
            }
        }

        if let value = lapData?.lastReadTime{
            param["hseconds"] = value
        }

        
        if let value = batteryData?.radioBatteryLevel{
            param["battery_radio"] = value
        }
        
        if let value = batteryData?.headsetBatteryLevel{
            param["battery_headset"] = value
        }
            
        param["why_wrong_break"] = NSNumber(value: whyBreak)
        param["why_wrong_endless"] = NSNumber(value: whyEndless)
        param["why_wrong_no_sync"] = NSNumber(value: whyNoSync)
        param["why_wrong_dont_know"] = NSNumber(value: whyDontKnow)
        
        param["location_city"] = city
        
        print("feedback params: \(param)")
        
        NetworkManager.shared.request(withEndPoint: .workoutFeedback, method: .post, headers: header, params: param) { (response) in
            switch response{
            case .success( _):
                completion(nil)
            case .failure(_ , let message):
                completion(message)
            case .notConnectedToInternet:
                completion(Constants.internetNotWorking)
            }
        }
    }
    
    func BLEPairingData(userId: Int, lapData: BLELapInfoDTO?, batteryData: BLEDeviceInfoDTO?, completion: @escaping (String?) -> Void){
        let header = NetworkManager.shared.getHeader()
        
        var param: [String: Any] = [
            "user_id": userId
        ]
        
        if let rawLaps = lapData?.numberOfLaps{
            param["laps_from_headset"] = rawLaps
        }
        
        if let value = lapData?.startStopStatus{
            param["headset_start_stop"] = value
        }
        
        if let value = lapData?.totalTime{
            param["time_elapsed_headset"] = value
        }
                
        if let value = lapData?.serialNumber{
            let deviceInfo = PreferenceManager.shared.deviceInfo
            if deviceInfo.versionInfo.zygoDeviceVersion == .v2{
                let transmitter = PreferenceManager.shared.transmitterSerialNumber
                param["headset_sn"] = "\(value)/\(transmitter)"
            }else{
                param["headset_sn"] = value
            }
        }

        if let value = lapData?.lastReadTime{
            param["hseconds"] = value
        }

        if let value = batteryData?.radioBatteryLevel{
            param["battery_radio"] = value
        }
        
        if let value = batteryData?.headsetBatteryLevel{
            param["battery_headset"] = value
        }
            
        if let value = lapData?.lastReadTime{
            param["timestamp"] = "\(Date().addingTimeInterval(-(Double(value))).timeIntervalSince1970)"
        }
        
        print("feedback params: \(param)")
        
        NetworkManager.shared.request(withEndPoint: .blePairingData, method: .post, headers: header, params: param) { (response) in
            switch response{
            case .success( _):
                completion(nil)
            case .failure(_ , let message):
                completion(message)
            case .notConnectedToInternet:
                completion(Constants.internetNotWorking)
            }
        }
    }
    
    func getInstructorsList(completion: @escaping (String?, [WorkoutInstructorDTO]) -> Void){
        let header = NetworkManager.shared.getHeader()
        
        NetworkManager.shared.request(withEndPoint: .getInstructorsList, method: .get, headers: header, params: [:]) { (response) in
            switch response{
            case .success(let response):
                print(response)
                let arrTempInstructors = response["instructor"] as? [[String: Any]] ?? []
                
                var arrInstructors: [WorkoutInstructorDTO] = []
                for instructorDict in arrTempInstructors{
                    let item = WorkoutInstructorDTO(instructorDict)
                    arrInstructors.append(item)
                }
                completion(nil, arrInstructors)
            case .failure(_ , let message):
                completion(message, [])
            case .notConnectedToInternet:
                completion(Constants.internetNotWorking, [])
            }
        }
    }
    
    func getInstructor(instructorId: Int, completion: @escaping (String?, WorkoutInstructorDTO, [WorkoutDTO]) -> Void){
        let header = NetworkManager.shared.getHeader()
        let params : [String : Any] = [
            "id": instructorId,
        ]
        
        NetworkManager.shared.request(withEndPoint: .getinstructor, method: .get, headers: header, params: params) { (response) in
            switch response{
            case .success(let response):
                
                let instructorDict = response["instructor"] as? [String: Any] ?? [:]
                let arrTempWorkouts = response["workouts"] as? [[String: Any]] ?? []
                
                var arrWorkouts: [WorkoutDTO] = []
                for workoutDict in arrTempWorkouts{
                    arrWorkouts.append(WorkoutDTO(workoutDict))
                }
                
                let item = WorkoutInstructorDTO(instructorDict)
                completion(nil, item, arrWorkouts)
            case .failure(_ , let message):
                completion(message, WorkoutInstructorDTO([:]), [])
            case .notConnectedToInternet:
                completion(Constants.internetNotWorking, WorkoutInstructorDTO([:]), [])
            }
        }
    }
    
    func fetchLastCompletedWorkout(completion: @escaping (String?, LastSavedWorkout?) -> Void){
        let header = NetworkManager.shared.getHeader()
        NetworkManager.shared.request(withEndPoint: .lastCompletedWorkout, method: .get, headers: header) { (response) in
            switch response{
            case .success(let jsonresponse):
                print(jsonresponse)
                let dataDict = jsonresponse["data"] as? [String:Any] ?? [:]
                let workoutLogDict = dataDict["workout_log"] as? [String:Any] ?? [:]
                let startStop = workoutLogDict["headset_start_stop"] as? Int ?? 0
                let headsetLapsRaw = workoutLogDict["laps_headset_raw"] as? Int ?? 0
                let headsetElapsedTime = workoutLogDict["time_elapsed_headset"] as? Int ?? 0
                let savedWorkout = LastSavedWorkout(startStop: startStop, headsetLapsRaw: headsetLapsRaw, headsetElapsedTime: headsetElapsedTime)
                completion(nil, savedWorkout)
            case .failure(_ , let message):
                completion(message, nil)
            case .notConnectedToInternet:
                completion(Constants.internetNotWorking, nil)
            }
        }
    }
}
