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
    
    func completeWorkout(_ workoutId: Int, _ timeInWater: Int, _ timeElapsed: Int, completion: @escaping (Bool, Int) -> Void){//Seconds
        Helper.shared.startLoading()
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
    
    func workoutFeedback(_ workoutId: Int, _ thumbStatus: ThumbStatus, _ dificultyLevel: Int, workoutLogId: Int, poolLength: Int, poolLengthUnits: String, poolType: String, laps: Int, distance: Double, strokeVlue: Int, city: String, completion: @escaping (Bool) -> Void){
        
        Helper.shared.startLoading()
        print("Workout Feedback")
        service.workoutFeedback(wId: workoutId, thumbStatus: thumbStatus, dificultyLevel: dificultyLevel, workoutLogId: workoutLogId, poolLength: poolLength, poolLengthUnits: poolLengthUnits, poolType: poolType, laps: laps, distance: distance, strokeValue: strokeVlue, city: city) { (error) in
            DispatchQueue.main.async {
                Helper.shared.stopLoading()
                if error != nil{
                    Helper.shared.alert(title: Constants.appName, message: error!)
                    completion(false)
                    return
                }
                
                completion(true)
            }
        }
    }
    
}
