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
    
    func completeWorkout(wId: Int, timeInWater: Int, timeElapsed: Int, lat: Double, lng: Double, completion: @escaping (String?, [AchievementDTO]) -> Void){
        let header = NetworkManager.shared.getHeader()
        
        //TODO: Remove Workout_Location
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
        
        NetworkManager.shared.request(withEndPoint: .completeWorkout, method: .post, headers: header, params: param) { (response) in
            switch response{
            case .success(let jsonresponse):
                print(jsonresponse)
                
                guard let arrTempAchievements = jsonresponse["completed_achievements"] as? [[String: Any]] else{
                    completion(nil, [])
                    return
                }
                var arrAchievements: [AchievementDTO] = []
                for achievementDict in arrTempAchievements{
                    arrAchievements.append(AchievementDTO(achievementDict))
                }
                
                completion(nil, arrAchievements)
            case .failure(_ , let message):
                completion(message, [])
            case .notConnectedToInternet:
                completion(Constants.internetNotWorking, [])
            }
        }
    }
    
    
    func workoutFeedback(wId: Int, thumbStatus: ThumbStatus, dificultyLevel: Int, completion: @escaping (String?) -> Void){
        let header = NetworkManager.shared.getHeader()
        
        var param: [String: Any] = [
            "workout_id": wId,
        ]
        
        if thumbStatus != .none{
            param["is_thumbs"] = thumbStatus == .up ? "1" : "0"
        }
        
        if dificultyLevel > 0{
            param["rating"] = "\(dificultyLevel)"
        }
        
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
    
}
