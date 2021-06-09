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
    
    func completeWorkout(_ workoutId: Int, _ timeInWater: Int, _ timeElapsed: Int, completion: @escaping (Bool) -> Void){//Seconds
        Helper.shared.startLoading()
        LocationManager.shared.startLoction()
        LocationManager.shared.onUpdate = { [weak self] location in
            guard let mLocation = location else{
                Helper.shared.stopLoading()
                completion(false)
                return
            }
            self?.completeWorout(with: mLocation.latitude, mLocation.longitude , workoutId, timeInWater, timeElapsed, completion: completion)
        }
        
    }
    
    private func completeWorout(with lat: Double, _ lng: Double, _ workoutId: Int, _ timeInWater: Int, _ timeElapsed: Int, completion: @escaping (Bool) -> Void){
        self.service.completeWorkout(wId: workoutId, timeInWater: timeInWater, timeElapsed: timeElapsed, lat: lat, lng: lng) { [weak self] (error, arrAchievements) in
            DispatchQueue.main.async {
                Helper.shared.stopLoading()
                if error != nil{
                    Helper.shared.alert(title: Constants.appName, message: error!)
                    completion(false)
                    return
                }
                
                self?.arrAchievements.removeAll()
                self?.arrAchievements.append(contentsOf: arrAchievements)
                completion(true)
            }
        }
    }
    
    func workoutFeedback(_ workoutId: Int, _ thumbStatus: ThumbStatus, _ dificultyLevel: Int, completion: @escaping (Bool) -> Void){
        
        Helper.shared.startLoading()
        print("Workout Feedback")
        service.workoutFeedback(wId: workoutId, thumbStatus: thumbStatus, dificultyLevel: dificultyLevel) { (error) in
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
