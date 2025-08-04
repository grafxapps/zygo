//
//  WorkoutPlayerViewModel.swift
//  Zygo
//
//  Created by Som on 13/02/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit

final class WorkoutPlayerViewModel: NSObject {
    
    private let service = WorkoutsServices()
    var arrAchievements: [AchievementDTO] = []
    var lastSavedWorkout: LastSavedWorkout?
    private var dispatchGroup: DispatchGroup?
    
    func fetchLastCompletedWorkout(completion: @escaping () -> Void){
        self.service.fetchLastCompletedWorkout() { [weak self] (error, lastCompletedWorkout) in
            DispatchQueue.main.async {
                Helper.shared.stopLoading()
                self?.lastSavedWorkout = lastCompletedWorkout
                completion()
            }
        }
    }
    
    func completeWorkout(_ workoutId: Int, _ timeInWater: Int, _ timeElapsed: Int, completion: @escaping (Bool, Int) -> Void){//Seconds
        
        //Here we need to check application status, if it's in the background then wait for it to launch or we can complete the workout without location.
        
        Helper.shared.startLoading()
        if UIApplication.shared.applicationState == .active{
            LocationManager.shared.startLoction()
            LocationManager.shared.onUpdate = { [weak self] location in
                guard let mLocation = location else{
                    //Helper.shared.stopLoading()
                    //completion(false, -1)
                    self?.completeWorout(with: 0.0, 0.0, workoutId, timeInWater, timeElapsed, completion: completion)
                    return
                }
                self?.completeWorout(with: mLocation.latitude, mLocation.longitude , workoutId, timeInWater, timeElapsed, completion: completion)
            }
        }else{
            self.completeWorout(with: 0.0, 0.0, workoutId, timeInWater, timeElapsed, completion: completion)
        }
    }
    
    private func completeWorout(with lat: Double, _ lng: Double, _ workoutId: Int, _ timeInWater: Int, _ timeElapsed: Int, completion: @escaping (Bool, Int) -> Void){
        self.service.completeWorkout(wId: workoutId, timeInWater: timeInWater, timeElapsed: timeElapsed, lat: lat, lng: lng) { [weak self] (error, arrAchievements, workoutLogId) in
            DispatchQueue.main.async {
                Helper.shared.stopLoading()
                if error != nil{
                    Helper.shared.alert(title: Constants.appName, message: error!)
                    completion(false, -2)
                    return
                }
                
                self?.arrAchievements.removeAll()
                self?.arrAchievements.append(contentsOf: arrAchievements)
                completion(true, workoutLogId)
            }
        }
    }
    
    var isWorkoutFeedbackSuccess: Bool = false
    func workoutFeedback(_ workoutId: Int, _ thumbStatus: ThumbStatus, _ dificultyLevel: Int, workoutLogId: Int, poolLength: Int, poolLengthUnits: String, poolType: String, laps: Int, distance: Double, strokeVlue: Int, city: String, timeElapsed: Int,  whyBreak: Bool, whyEndless: Bool, whyNoSync: Bool, whyDontKnow: Bool, completion: @escaping (Bool) -> Void){
        
        isWorkoutFeedbackSuccess = false
        Helper.shared.startLoading()
        print("Workout Feedback")
        
        HealthKitManager.sharedInstance.writeSwimmingDistance(distance: distance) {
            print("Swimming distance added ")
        }
        
        let lapData = PreferenceManager.shared.lapInfo
        let batteryData = PreferenceManager.shared.deviceInfo
        
        dispatchGroup = DispatchGroup()
        
        dispatchGroup?.enter()
        service.workoutFeedback(wId: workoutId, thumbStatus: thumbStatus, dificultyLevel: dificultyLevel, workoutLogId: workoutLogId, poolLength: poolLength, poolLengthUnits: poolLengthUnits, poolType: poolType, laps: laps, distance: distance, strokeValue: strokeVlue, city: city, timeElapsed: timeElapsed, whyBreak: whyBreak, whyEndless: whyEndless, whyNoSync: whyNoSync, whyDontKnow: whyDontKnow, lapData: lapData, batteryData: batteryData) { (error) in
            DispatchQueue.main.async {
                self.dispatchGroup?.leave()
                if error != nil{
                    Helper.shared.alert(title: Constants.appName, message: error!)
                    self.isWorkoutFeedbackSuccess = false
                    //completion(false)
                    return
                }
                
                self.isWorkoutFeedbackSuccess = true
                //completion(true)
            }
        }
        
        
        dispatchGroup?.enter()
        self.BLESyncData { isComplete in
            self.dispatchGroup?.leave()
        }
        
        dispatchGroup?.notify(queue: .main, execute: {
            Helper.shared.stopLoading()
            completion(self.isWorkoutFeedbackSuccess)
        })
        
    }
    
    func BLESyncData(completion: @escaping (Bool) -> Void){
        
        let lapData = PreferenceManager.shared.lapInfo
        let batteryData = PreferenceManager.shared.deviceInfo
        let userId = PreferenceManager.shared.userId
        
        service.BLEPairingData(userId: userId, lapData: lapData, batteryData: batteryData) { (error) in
            DispatchQueue.main.async {
                if error != nil{
                    completion(false)
                    return
                }
                
                completion(true)
            }
        }
        
    }
    
}
