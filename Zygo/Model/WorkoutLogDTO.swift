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
    
    var timeInWater: Double = 0
    var poolLength: Int = 0
    var poolLengthUnit: String = ""
    var poolType: String = ""
    var distance: Double = 0
    var strokeValue: Int = 0
    var laps: Int = 0
    var city: String = ""
    
    init(_ dict: [String: Any]) {
        
        self.WId = dict["workout_id"] as? Int ?? Int(dict["workout_id"] as? String ?? "0") ?? 0
        self.workoutName = dict["workout_name"] as? String ?? ""
        self.workoutDuration = "\(dict["workout_duration"] as? Int ?? 0)"
        let strWorkoutDate = dict["date_of_workout"] as? String ?? ""
        self.dateOfWorkout = strWorkoutDate.convertToFormat("yyyy-MM-dd HH:mm:ss")
        self.location = dict["location_city"] as? String ?? ""
        self.workoutTypeTitle = dict["workout_type_title"] as? String ?? ""
        self.instructorName = dict["instructor_name"] as? String ?? ""
        self.timeInWater = dict["time_elapsed"] as? Double ?? Double(dict["time_elapsed"] as? String ?? "0") ?? 0
        self.poolLength = dict["pool_length"] as? Int ?? 0
        self.poolLengthUnit = dict["pool_length_units"] as? String ?? ""
        self.poolType = dict["pool_type"] as? String ?? ""
        self.distance = Double(dict["distance"] as? String ?? "0") ?? 0
        self.strokeValue = dict["stroke_value"] as? Int ?? Int(dict["stroke_value"] as? String ?? "0") ?? 0
        self.city = dict["location_city"] as? String ?? ""
        self.laps = dict["laps"] as? Int ?? 0
    }

}
