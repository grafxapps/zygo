//
//  InstructorViewMode.swift
//  Zygo
//
//  Created by Som on 28/06/21.
//  Copyright © 2021 Somparkash. All rights reserved.
//

import UIKit

final class InstructorViewModel: NSObject {
    var arrInstuctorSections: [InstructorView] = [.profile,.workoutTitle, .video, .workouts]
    var arrWorkouts: [WorkoutDTO] = []
    var instructor = WorkoutInstructorDTO([:])
   
    var arrInstructors: [WorkoutInstructorDTO] = []
    
    let service = WorkoutsServices()
    
    func getInstructors(completion: @escaping () -> Void){
        
        Helper.shared.startLoading()
        
        service.getInstructorsList { (error, arrInstructors) in
            DispatchQueue.main.async {
                Helper.shared.stopLoading()
                
                if error != nil{
                    Helper.shared.alert(title: Constants.appName, message: error!)
                    completion()
                    return
                }
                
                self.arrInstructors.removeAll()
                self.arrInstructors.append(contentsOf: arrInstructors)
                completion()
            }
        }
        
    }
    
    func getInstructorDetail(completion: @escaping () -> Void){
        Helper.shared.startLoading()
        
        service.getInstructor(instructorId: instructor.instructorId) { (error, item, arrWorkouts) in
            DispatchQueue.main.async {
                Helper.shared.stopLoading()
                
                if error != nil{
                    Helper.shared.alert(title: Constants.appName, message: error!)
                    completion()
                    return
                }
                
                self.instructor = item
                self.arrWorkouts = arrWorkouts
                completion()
            }
        }
    }
}

enum InstructorView{
    case profile
    case workoutTitle
    case video
    case workouts
}
