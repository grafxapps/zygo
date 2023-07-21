//
//  FilterViewModel.swift
//  Zygo
//
//  Created by Som on 30/01/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit

final class FilterViewModel: NSObject {
    
    //let arrFilterType: [FilterTypes] = [.workoutType, .duration, .difficultLevel, .instructor, .equipment, .series, .poolLength]
    
    let service = WorkoutsServices()
    
    var arrFiltes: [GroupedFilterDTO] = []
    var arrSelectedFiltes: [GroupedFilterDTO] = PreferenceManager.shared.selectedFilters
    var arrWorkouts: [WorkoutDTO] = []
    
    func getFilters(completion: @escaping () -> Void){
        
        self.arrSelectedFiltes = PreferenceManager.shared.selectedFilters
        
        //Show Data from DB first
        var filters = DatabaseManager.shared.getGroupFilters()
        filters.sort(by: { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending })
        self.arrFiltes.removeAll()
        self.arrFiltes.append(contentsOf: filters)
        completion()
        
        service.getFilters { [weak self] (error, filters) in
            DispatchQueue.main.async {
                if error != nil{
                    Helper.shared.alert(title: Constants.appName, message: error!)
                    return
                }
                
                self?.arrFiltes.removeAll()
                let sortedFilter = filters.sorted(by: { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending })
                self?.arrFiltes.append(contentsOf: sortedFilter)
                completion()
            }
            
        }
    }
    
    func getFilteredWorkouts(completion: @escaping () -> Void){
        Helper.shared.startLoading()
        service.getFilteredWorkouts(filters: self.arrSelectedFiltes) { [weak self] (error, arrWorkouts) in
            DispatchQueue.main.async {
                Helper.shared.stopLoading()
                if error != nil{
                    Helper.shared.alert(title: Constants.appName, message: error!)
                    completion()
                    return
                }
                
                self?.arrWorkouts.removeAll()
                self?.arrWorkouts.append(contentsOf: arrWorkouts)
                completion()
            }
        }
        
    }
}

/*enum FilterTypes: String{
 case workoutType = "Workout Type"
 case duration = "Duration"
 case difficultLevel = "DifficultLevel"
 case instructor = "Instructor"
 case equipment = "Equipment"
 case series = "Series"
 case poolLength = "Pool Length"
 }*/
