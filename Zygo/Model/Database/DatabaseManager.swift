//
//  DatabaseManager.swift
//  Zygo
//
//  Created by Som on 05/02/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit
import RealmSwift

final class DatabaseManager: NSObject {
    
    static let shared = DatabaseManager()
    private override init() {
    }
}

//MARK: Filters
extension DatabaseManager{
    
    func getAllFilters() -> [Filter]{
        let realm = try! Realm()
        let arrFilters = realm.objects(Filter.self)
        return Array(arrFilters)
    }
    
    func setAllFiltersStatus(status: FilterStatus){
        let existingFilters = self.getAllFilters()
        let realm = try! Realm()
        realm.beginWrite()
        existingFilters.forEach({ $0.status = status.rawValue })
        try! realm.commitWrite()
        
    }
    
    func getGroupFilters() -> [GroupedFilterDTO] {
        
        let allFilters = self.getAllFilters()
        let allHeaders = NSSet(array: allFilters.map({ $0.headerTitle })).allObjects as? [String] ?? []
        var arrGFilters: [GroupedFilterDTO] = []
        for header in allHeaders{
            let subFilters = allFilters.filter({ $0.headerTitle == header })
            let icon = subFilters.first?.icon ?? ""
            arrGFilters.append(GroupedFilterDTO(subFilters, title: header, icon: icon))
        }
        
        return arrGFilters
    }
    
    func updateFilterWithServer(_ filterDict: [String: Any], filterIcons: [[String: Any]], completion: @escaping () -> Void){
        
        self.setAllFiltersStatus(status: .pending)
        let existingFilters = self.getAllFilters()
        
        let realm = try! Realm()
        try! realm.write { [weak self] in
            
            if self == nil{
                completion()
                return
            }
            
            let arrFilterTitles = filterDict.keys
            for mtitle in arrFilterTitles{
                
                let iconDict = filterIcons.filter({ ($0["type"] as? String ?? "") == mtitle }).first ?? [:]
                let icon = iconDict["image"] as? String  ?? ""
                let arrFilter = filterDict[mtitle] as? [[String: Any]] ?? []
                if arrFilter.count > 0{
                    
                    //Altered Main Title
                    let updateTitle = ((mtitle as String).replacingOccurrences(of: "_", with: " ")).capitalized
                    
                    let arrExisting = existingFilters.filter({ $0.headerTitle == updateTitle })
                    for filterDict in arrFilter{
                        
                        let fId: Int = filterDict["id"] as? Int ?? 0
                        if let existingItem = arrExisting.filter({ $0.id == fId }).first{
                            //If already exist then update name and status
                            existingItem.update(filterDict, icon: icon)
                        }else{
                            //Add New Filter in DB
                            let fItem = Filter()
                            fItem.updateFullInfo(filterDict, headerTitle: updateTitle, icon: icon)
                            realm.add(fItem)
                        }
                    }
                }
            }
            
            //Remove Pending Filters
            let arrPending = existingFilters.filter({ $0.status == FilterStatus.pending.rawValue })
            realm.delete(arrPending)
            completion()
        }
    }
    
}


//MARK: - Workouts
extension DatabaseManager{
    
    func deleteWrokout(by wId: String){
        
        guard let workout = self.getSavedWorkout(by: wId) else{
            return
        }
        
        let realm = try! Realm()
        realm.beginWrite()
        realm.delete(workout)
        try!realm.commitWrite()
    }
    
    func getSavedWorkouts() -> [Workout]{
        let realm = try! Realm()
        let arrWorkouts = realm.objects(Workout.self)
        return Array(arrWorkouts)
    }
    
    func getSavedWorkout(by wId: String) -> Workout?{
        let realm = try! Realm()
        return realm.objects(Workout.self).filter({ $0.workoutIdentifier == wId }).last
    }
    
    func saveWorkout(workoutItem: WorkoutDTO, audioLocalPath: String){
        
        let workoutIdentifier = "\(workoutItem.workoutId)"
        let workoutDict = workoutItem.toDict()
        let json = workoutDict.toJsonString
        
        let existingWorkout = getSavedWorkout(by: workoutIdentifier)
        if existingWorkout != nil{
            let realm = try! Realm()
            realm.beginWrite()
            existingWorkout?.workoutAudio = audioLocalPath
            existingWorkout?.workoutDetailJSON = json
            existingWorkout?.workoutDownloadStatus = WorkoutDownloadStatus.downloading.rawValue
            try!realm.commitWrite()
        }else{
            //Save New
            let workout = Workout()
            workout.workoutIdentifier = workoutIdentifier
            workout.workoutAudio = audioLocalPath
            workout.workoutDetailJSON = json
            workout.workoutDownloadStatus = WorkoutDownloadStatus.downloading.rawValue
            let realm = try! Realm()
            realm.beginWrite()
            realm.add(workout)
            try!realm.commitWrite()
        }
    }
    
    func updateWorkoutDownload(status: WorkoutDownloadStatus, workoutIdentifier: String){
        
        let existingWorkout = getSavedWorkout(by: workoutIdentifier)
        if existingWorkout != nil{
            let realm = try! Realm()
            realm.beginWrite()
            existingWorkout?.workoutDownloadStatus = status.rawValue
            try!realm.commitWrite()
        }
    }
    
    func pauseAllDowloadingWorkouts(){
        let realm = try! Realm()
        let downloadingWorkouts = realm.objects(Workout.self).filter({ $0.workoutDownloadStatus == WorkoutDownloadStatus.downloading.rawValue })
        
        realm.beginWrite()
        for item in downloadingWorkouts{
            item.workoutDownloadStatus = WorkoutDownloadStatus.paused.rawValue
        }
        try!realm.commitWrite()
    }    
}

