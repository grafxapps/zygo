//
//  WorkoutInfoDTO.swift
//  Zygo
//
//  Created by Som on 29/01/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit

struct WorkoutInfoDTO {
    
    var headphonesSerialNumber: String = ""
    var workoutCount: Int = 0
    var timeInWater: String = ""
    var achievements: [String] = []
    var currentStreakLength: Int = 0
    var startDate: String = ""
    var cancelDate: String = ""
    var weekStartsOn: String = ""
    var workoutThisWeek: Int = 0
    var workoutLog: String = ""
    var workoutsCompleted: Int = 0
    var favoriteWorkouts: [String] = []
    var howOftenSwim: String = ""
    
    init(_ dict: [String: Any]) {
        
        self.headphonesSerialNumber = dict["headphones_serial_number"] as? String ?? ""
        self.workoutCount = dict["workout_count"] as? Int ?? 0
        self.timeInWater = dict["time_in_water"] as? String ?? ""
        self.achievements = dict["achievements"] as? [String] ?? []
        self.currentStreakLength = dict["current_streak_length"] as? Int ?? 0
        self.startDate = dict["start_date"] as? String ?? ""
        self.cancelDate = dict["cancel_date"] as? String ?? ""
        self.weekStartsOn = dict["week_starts_on"] as? String ?? ""
        self.workoutThisWeek = dict["workedout_this_week"] as? Int ?? 0
        self.workoutLog = dict["workout_log"] as? String ?? ""
        self.workoutsCompleted = dict["workouts_completed"] as? Int ?? 0
        self.favoriteWorkouts = dict["favorite_workouts"] as? [String] ?? []
        self.howOftenSwim = dict["how_often_swim"] as? String ?? ""
        
    }
    
    func toDict() -> [String: Any]{
        return [
            "headphones_serial_number": self.headphonesSerialNumber,
            "workout_count": self.workoutCount,
            "time_in_water": self.timeInWater,
            "achievements": self.achievements,
            "current_streak_length": self.currentStreakLength,
            "start_date": self.startDate,
            "cancel_date": self.cancelDate,
            "week_starts_on": self.weekStartsOn,
            "workedout_this_week": self.workoutThisWeek,
            "workout_log": self.workoutLog,
            "workouts_completed": self.workoutsCompleted,
            "favorite_workouts": self.favoriteWorkouts,
            "how_often_swim": self.howOftenSwim
        ]
    }
}




