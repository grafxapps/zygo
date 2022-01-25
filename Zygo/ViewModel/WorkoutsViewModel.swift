//
//  WorkoutsViewModel.swift
//  Zygo
//
//  Created by Som on 30/01/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit

final class WorkoutsViewModel: NSObject {
    
    var arrWorkouts: [WorkoutDTO] = []
    var arrSeriesWorkouts: [SeriesDTO] = []
    
    var downloadedWorkout: Workout?
    private let workoutService = WorkoutsServices()
    private let userService = UserServices()
    
    func getUserProfile(completion: @escaping () -> Void){
        userService.getUserProfile { [weak self] (error) in
            if self == nil{
                return
            }
            
            if error != nil{
                print(error!)
            }
            
            DispatchQueue.main.async {
                
                //Check for rating poup
                if PreferenceManager.shared.lastRatingPopupDate == nil{
                    if PreferenceManager.shared.completedWorkouts.count >= 3{
                        Helper.shared.requestToRate()
                    }
                }else{
                    //Show popup after every 4 month
                    if let ratingDate = PreferenceManager.shared.lastRatingPopupDate{
                        
                        let calendar = Calendar.current
                        if let nextPopupDate = calendar.date(byAdding: .month, value: 4, to: ratingDate){
                            if nextPopupDate.compare(DateHelper.shared.currentUTCDateTime) == .orderedAscending || nextPopupDate.compare(DateHelper.shared.currentUTCDateTime) == .orderedSame{
                                Helper.shared.requestToRate()
                            }
                        }
                    }
                }
                
                AppDelegate.app.protector.startPreventing()
                
                //If Demo mode or Test user enable then no need to check subscription status, let user to explore app and play workouts for 3 minutes
                if Helper.shared.isTestUser{
                    PreferenceManager.shared.isDemoMode = false
                    completion()
                    return
                }
                
                    //Check subscription from apple
                    if !SubscriptionManager.shared.isValidSubscription(){//If not valid subscription
                        let type = PreferenceManager.shared.currentSubscribedProduct?.type ?? ""
                        if type == SubscriptionType.Stripe.rawValue || type == SubscriptionType.Google.rawValue{
                            PreferenceManager.shared.isDemoMode = true
                            // If user not subscribed then set Subscription as root
                            //Helper.shared.setSubscriptionRoot()
                            completion()
                            return
                        }
                        
                        SubscriptionManager.shared.isValidSubscriptionFromApple { (isSubscribed) in
                            if !isSubscribed{// If user not subscribed then set Subscription as root
                                PreferenceManager.shared.isDemoMode = true
                                //Helper.shared.setSubscriptionRoot()
                            }else{
                                PreferenceManager.shared.isDemoMode = false
                            }
                            completion()
                        }
                        
                    }else{
                        PreferenceManager.shared.isDemoMode = false
                        completion()
                    }
            }
        }
    }
    
    func getDownloadedWorkout(wId: Int){
        downloadedWorkout = DatabaseManager.shared.getSavedWorkout(by: "\(wId)")
    }
    
    func getWorkoutList(isLoading: Bool = true, isLoadingStop: Bool = true, completion: @escaping (Bool) -> Void){
        if isLoading{
            Helper.shared.startLoading()
        }
        self.workoutService.getDefaultWorkouts { [weak self] (error, workouts) in
            DispatchQueue.main.async {
                if isLoadingStop{
                    Helper.shared.stopLoading()
                }
                
                self?.arrWorkouts.removeAll(keepingCapacity: true)
                if error != nil{
                    //Helper.shared.alert(title: Constants.appName, message: error!)
                    completion(true)
                    return
                }
                
                
                self?.arrWorkouts.append(contentsOf: workouts)
                completion(false)
            }
        }
    }
    
    func getFilteredWorkouts(isLoading: Bool = true, isLoadingStop: Bool = true, selectedFilters: [GroupedFilterDTO], completion: @escaping (Bool) -> Void){
        if isLoading{
            Helper.shared.startLoading()
        }
        self.workoutService.getFilteredWorkouts(filters: selectedFilters) { [weak self] (error, arrWorkouts) in
            DispatchQueue.main.async {
                if isLoadingStop{
                    Helper.shared.stopLoading()
                }
                
                self?.arrWorkouts.removeAll(keepingCapacity: true)
                
                if error != nil{
                    //Helper.shared.alert(title: Constants.appName, message: error!)
                    completion(true)
                    return
                }
                
                
                self?.arrWorkouts.append(contentsOf: arrWorkouts)
                completion(false)
            }
        }
    }
    
    func getWorkoutSeriesList(completion: @escaping (Bool) -> Void){
        Helper.shared.startLoading()
        self.workoutService.getWorkoutsSeries { [weak self] (error, workouts) in
            DispatchQueue.main.async {
                Helper.shared.stopLoading()
                self?.arrSeriesWorkouts.removeAll(keepingCapacity: true)
                
                if error != nil{
                    //Helper.shared.alert(title: Constants.appName, message: error!)
                    completion(true)
                    return
                }
                
                
                self?.arrSeriesWorkouts.append(contentsOf: workouts)
                completion(false)
            }
        }
    }
    
    
    func getWorkoutDetail(by wId: Int, isLoading: Bool = true, completion: @escaping (WorkoutDTO?) -> Void){
        if isLoading{
            Helper.shared.startLoading()
        }
        
        self.workoutService.getWorkoutDetail(by: wId, completion: { [weak self] (error, workout) in
            DispatchQueue.main.async {
                Helper.shared.stopLoading()
                if error != nil{
                    if isLoading{
                        Helper.shared.alert(title: Constants.appName, message: error!)
                    }
                    completion(nil)
                    return
                }
                
                completion(workout)
            }
        })
    }
}
