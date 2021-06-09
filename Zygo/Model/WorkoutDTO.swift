//
//  WorkoutDTO.swift
//  Zygo
//
//  Created by Som on 30/01/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit

struct WorkoutDTO {
    
    var workoutId: Int = -1
    var workoutName: String = ""
    var isWorkoutAchived: Bool = false
    var byInstructor: String = ""
    var workoutDescription: String = ""
    var workoutBreakdown: String = ""
    var thumbnailURL: String = ""
    var workoutDuration: Double = 0
    var isInWater: Bool = false
    var workoutStartsAt: Int = 0//Seconds
    var audioURL: String = ""
    var completionsCount: Int = 0
    var finsRequired: Bool = false
    var paddlesRequired: Bool = false
    var buoyRequired: Bool = false
    var snorkelRequired: Bool = false
    var kickboardRequired: Bool = false
    var otherRequired: Bool = false
    var isFeatured: Bool = false
    var isTrending: Bool = false
    var thumbsUpCount: Int = 0
    var thumbsDownCount: Int = 0
    var difficultyRatingsCount: Int = 0
    var difficultyRatingsTotal: Int = 0
    var difficulityLevelId: Int = 0
    var musicType: String = ""
    var introVideo: String = ""
    var closingVideo: String = ""
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var isPopular: Bool = false
    
    var difficultyLevel: DifficultyLevelDTO = DifficultyLevelDTO([:])
    var poolLength: PoolLengthDTO = PoolLengthDTO([:])
    var workoutType: WorkoutTypeDTO = WorkoutTypeDTO([:])
    var instructor: WorkoutInstructorDTO = WorkoutInstructorDTO([:])
    var workoutMusicTypes: [WorkoutMusicTypeDTO] = []
    var workoutEquipments: [WorkoutEquipmentDTO] = []
    var workoutPlanLines: [WorkoutPlanLine] = []
    
    init(_ dict: [String: Any]) {
        
        self.workoutId = dict["id"] as? Int ?? -1
        self.workoutName = dict["workout_name"] as? String ?? ""
        self.isWorkoutAchived = NSNumber(value: dict["workout_archived"] as? Int ?? 0).boolValue
        self.byInstructor =  dict["by_instructor"] as? String ?? ""
        self.workoutDescription =  dict["workout_description"] as? String ?? ""
        self.workoutBreakdown = dict["workout_breakdown"] as? String ?? ""
        self.thumbnailURL = dict["thumbnail_url"] as? String ?? ""
        self.workoutDuration = dict["workout_duration"] as? Double ?? 0
        self.isInWater = NSNumber(value: dict["in_water"] as? Int ?? 0).boolValue
        self.workoutStartsAt = dict["workout_starts_at"] as? Int ?? 0
        self.audioURL = dict["audio_file"] as? String ?? ""
        self.completionsCount = dict["completions_count"] as? Int ?? 0
        self.finsRequired = NSNumber(value: dict["fins_required"] as? Int ?? 0).boolValue
        self.paddlesRequired = NSNumber(value: dict["paddles_required"] as? Int ?? 0).boolValue
        self.buoyRequired = NSNumber(value: dict["buoy_required"] as? Int ?? 0).boolValue
        self.snorkelRequired = NSNumber(value: dict["snorkel_required"] as? Int ?? 0).boolValue
        self.kickboardRequired = NSNumber(value: dict["kickboard_required"] as? Int ?? 0).boolValue
        self.otherRequired = NSNumber(value: dict["other_required"] as? Int ?? 0).boolValue
        self.isFeatured = NSNumber(value: dict["is_featured"] as? Int ?? 0).boolValue
        self.isTrending = NSNumber(value: dict["is_trending"] as? Int ?? 0).boolValue
        self.thumbsUpCount = dict["thumbs_up_count"] as? Int ?? 0
        self.thumbsDownCount = dict["thumbs_down_count"] as? Int ?? 0
        self.difficultyRatingsCount = dict["difficulty_ratings_count"] as? Int ?? 0
        self.difficultyRatingsTotal = dict["difficulty_ratings_total"] as? Int ?? 0
        self.difficulityLevelId = dict["difficulity_level_id"] as? Int ?? 0
        self.musicType = dict["music_type"] as? String ?? ""
        self.introVideo = dict["intro_video"] as? String ?? ""
        self.closingVideo = dict["closing_video"] as? String ?? ""
        
        if let created = dict["created_at"] as? String {
            self.createdAt = created.toCreatedDate()
        }
        
        if let updated = dict["updated_at"] as? String {
            self.updatedAt = updated.toCreatedDate()
        }
        
        self.isPopular = NSNumber(value: dict["is_popular"] as? Int ?? 0).boolValue
        
        self.poolLength = PoolLengthDTO(dict["pool_length"] as? [String: Any] ?? [:])
        self.workoutType = WorkoutTypeDTO(dict["workout_type"] as? [String: Any] ?? [:])
        
        self.instructor = WorkoutInstructorDTO(dict["instructor"] as? [String: Any] ?? [:])
        self.difficultyLevel = DifficultyLevelDTO(dict["difficulty_level"] as? [String: Any] ?? [:])
        
        let arrMusicTypes = dict["workout_music_type"] as? [[String: Any]] ?? []
        for musicDict in arrMusicTypes{
            self.workoutMusicTypes.append(WorkoutMusicTypeDTO(musicDict))
        }
        
        let arrEquipments = dict["workout_assigned_equipment"] as? [[String: Any]] ?? []
        for equipmentDict in arrEquipments{
            self.workoutEquipments.append(WorkoutEquipmentDTO(equipmentDict))
        }
        
        let arrPlanLinesEquipments = dict["workout_plan_line"] as? [[String: Any]] ?? []
        for planLineDict in arrPlanLinesEquipments{
            self.workoutPlanLines.append(WorkoutPlanLine(planLineDict))
        }
        
    }
    
    func toDict() -> [String: Any]{
        return [
            "id": self.workoutId,
            "workout_type": self.workoutType.toDict(),
            "workout_name": self.workoutName,
            "workout_archived": NSNumber(value: self.isWorkoutAchived).intValue,
            "by_instructor": self.byInstructor,
            "workout_description": self.workoutDescription,
            "thumbnail_url": self.thumbnailURL,
            "workout_duration": self.workoutDuration,
            "pool_length": self.poolLength.toDict(),
            "in_water": self.isInWater,
            "workout_starts_at": self.workoutStartsAt,
            "audio_file": self.audioURL,
            "completions_count": self.completionsCount,
            "fins_required": NSNumber(value: self.finsRequired).intValue,
            "paddles_required": NSNumber(value: self.paddlesRequired).intValue,
            "buoy_required": NSNumber(value: self.buoyRequired).intValue,
            "snorkel_required": NSNumber(value: self.snorkelRequired).intValue,
            "kickboard_required": NSNumber(value: self.kickboardRequired).intValue,
            "other_required": NSNumber(value: self.otherRequired).intValue,
            "is_featured": NSNumber(value: self.isFeatured).intValue,
            "is_trending": NSNumber(value: self.isTrending).intValue,
            "thumbs_up_count": self.thumbsUpCount,
            "thumbs_down_count": self.thumbsDownCount,
            "difficulty_ratings_count": self.difficultyRatingsCount,
            "difficulty_ratings_total": self.difficultyRatingsTotal,
            "difficulity_level_id": self.difficulityLevelId,
            "music_type": self.musicType,
            "intro_video": self.introVideo,
            "closing_video": self.closingVideo,
            "created_at": self.createdAt.toFormat(format: "yyyy-MM-dd'T'HH:mm:ss.000000Z"),
            "updated_at": self.updatedAt.toFormat(format: "yyyy-MM-dd'T'HH:mm:ss.000000Z"),
            "is_popular": NSNumber(value: self.isPopular).intValue,
            "instructor": self.instructor.toDict(),
            "workout_music_type": self.workoutMusicTypes.map({ $0.toDict() }),
            "workout_assigned_equipment": self.workoutEquipments.map({ $0.toDict() }),
            "difficulty_level": self.difficultyLevel.toDict(),
            "workout_plan_line": self.workoutPlanLines.map({ $0.toDict() })
            
        ]
    }
    
}

struct PoolLengthDTO {
    var poolId: Int = -1
    var poolLength: String = ""
    var createdAt: String = ""
    var updatedAt: String = ""
    
    init(_ dict: [String: Any]) {
        self.poolId = dict["id"] as? Int ?? 0
        self.poolLength = dict["pool_length"] as? String ?? ""
        self.createdAt = dict["created_at"] as? String ?? ""
        self.updatedAt = dict["updated_at"] as? String ?? ""
    }
    
    func toDict() -> [String: Any]{
        return [
            "id": self.poolId,
            "workout_types": self.poolLength,
            "created_at": self.createdAt,
            "updated_at": self.updatedAt
        ]
    }
}

struct WorkoutTypeDTO {
    var workoutTypeId: Int = -1
    var workoutType: String = ""
    var createdAt: String = ""
    var updatedAt: String = ""
    var isVisibleInSeries: Bool = false
    
    init(_ dict: [String: Any]) {
        self.workoutTypeId = dict["id"] as? Int ?? 0
        self.workoutType = dict["workout_types"] as? String ?? ""
        self.createdAt = dict["created_at"] as? String ?? ""
        self.updatedAt = dict["updated_at"] as? String ?? ""
        self.isVisibleInSeries = NSNumber(value: Int((dict["is_visible_in_series"] as? String ?? "0")) ?? 0).boolValue
    }
    
    func toDict() -> [String: Any]{
        return [
            "id": self.workoutTypeId,
            "workout_types": self.workoutType,
            "created_at": self.createdAt,
            "updated_at": self.updatedAt,
            "is_visible_in_series": "\(NSNumber(value: self.isVisibleInSeries).intValue)"
        ]
    }
}

struct WorkoutMusicTypeDTO {
    
    var tId: Int = -1
    var workoutId: Int = -1
    var workoutMusicTypeId: Int = -1
    var createdAt: String = ""
    var updatedAt: String = ""
    
    init(_ dict: [String: Any]) {
        self.tId = dict["id"] as? Int ?? 0
        self.workoutId = dict["workout_id"] as? Int ?? 0
        self.workoutMusicTypeId = dict["music_type_id"] as? Int ?? 0
        self.createdAt = dict["created_at"] as? String ?? ""
        self.updatedAt = dict["updated_at"] as? String ?? ""
    }
    
    func toDict() -> [String: Any]{
        return [
            "id": self.tId,
            "workout_id": self.workoutId,
            "music_type_id": self.workoutMusicTypeId,
            "created_at": self.createdAt,
            "updated_at": self.updatedAt
        ]
    }
}

struct WorkoutEquipmentDTO {
    
    var eId: Int = -1
    var name: String = ""
    var image: String = ""
    
    init(_ dict: [String: Any]) {
        guard let equiptDict = dict["equipment"] as? [String: Any] else{
            return
        }
        self.eId = equiptDict["id"] as? Int ?? 0
        self.name = equiptDict["name"] as? String ?? ""
        self.image = equiptDict["image"] as? String ?? ""
    }
    
    func toDict() -> [String: Any]{
        return [
            "equipment": [
                "id": self.eId,
                "name": self.name,
                "image": self.image
            ]
        ]
    }
}

struct DifficultyLevelDTO {
    var dId: Int = -1
    var title: String = ""
    var createdAt: String = ""
    var updatedAt: String = ""
    
    init(_ dict: [String: Any]) {
        self.dId = dict["id"] as? Int ?? 0
        self.title = (dict["difficulty_level"] as? String ?? "").capitalized
        self.createdAt = dict["created_at"] as? String ?? ""
        self.updatedAt = dict["updated_at"] as? String ?? ""
    }
    
    func toDict() -> [String: Any]{
        return [
            "id": self.dId,
            "difficulty_level": self.title,
            "created_at": self.createdAt,
            "updated_at": self.updatedAt
        ]
    }
}


struct WorkoutPlanLine{
    
    var pId: Int = -1
    var title: String = ""
    var time: String = ""
    var createdAt: String = ""
    var updatedAt: String = ""
    
    init(_ dict: [String: Any]) {
        self.pId = dict["id"] as? Int ?? 0
        self.title = dict["workout_section"] as? String ?? ""
        self.time = "\(dict["section_length"] as? Int ?? 0) min"
        self.createdAt = dict["created_at"] as? String ?? ""
        self.updatedAt = dict["updated_at"] as? String ?? ""
    }
    
    func toDict() -> [String: Any]{
        return [
            "id": self.pId,
            "workout_section": self.title,
            "section_length": self.title,
            "created_at": self.createdAt,
            "updated_at": self.updatedAt
        ]
    }
}


struct SeriesDTO {
    var createdDate: String = ""
    var seriesDescription: String = ""
    var seriesGraphic: String = ""
    var seriesIsActive: Bool = true
    var seriesName: String = ""
    var seriesSortOrder : String = ""
    var updatedDate: String = ""
    var seriesID: Int = -1
    var seriesWorkouts: [WorkoutDTO] = []
    
    
    init(_ dict: [String: Any]) {
        self.seriesID = dict["id"] as? Int ?? 0
        self.seriesName = dict["series_name"] as? String ?? ""
        self.seriesDescription = dict["series_description"] as? String ?? ""
        self.seriesGraphic = dict["series_graphic"] as? String ?? ""
        self.createdDate = dict["created_at"] as? String ?? ""
        self.updatedDate = dict["updated_at"] as? String ?? ""
        let arrSeriesWorkout = dict["series_workout"] as? [[String: Any]] ?? []
        for seriesDict in arrSeriesWorkout{
            self.seriesWorkouts.append(WorkoutDTO(seriesDict["workouts"] as? [String: Any] ?? [:]))
        }
        
    }
}
