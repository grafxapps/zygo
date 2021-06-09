//
//  WorkoutLogDTO.swift
//  Zygo
//
//  Created by Som on 24/02/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit

struct WorkoutLogDTO{
    var WId: Int = -1
    var workoutName: String = ""
    var workoutDuration: String = ""
    var workoutTypeTitle: String = ""
    var instructorName: String = ""
    var dateOfWorkout: Date = Date()
    var location: String = ""
    
    init(_ dict: [String: Any]) {
        
        self.WId = dict["workout_id"] as? Int ?? Int(dict["workout_id"] as? String ?? "0") ?? 0
        self.workoutName = dict["workout_name"] as? String ?? ""
        self.workoutDuration = "\(dict["workout_duration"] as? Int ?? 1)"
        let strWorkoutDate = dict["date_of_workout"] as? String ?? ""
        self.dateOfWorkout = strWorkoutDate.convertToFormat("yyyy-MM-dd HH:mm:ss")
        self.location = dict["workout_location"] as? String ?? ""
        self.workoutTypeTitle = dict["workout_type_title"] as? String ?? ""
        self.instructorName = dict["instructor_name"] as? String ?? ""
    }

}
