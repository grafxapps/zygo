//
//  Workout.swift
//  Zygo
//
//  Created by Som on 19/02/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit
import RealmSwift

class Workout: Object {
    
    @objc dynamic var workoutIdentifier: String = ""//Workout Id
    @objc dynamic var workoutDetailJSON: String = ""
    @objc dynamic var workoutAudio: String = ""
    @objc dynamic var workoutDownloadStatus: String = WorkoutDownloadStatus.downloading.rawValue
    
    override class func primaryKey() -> String? {
        return "workoutIdentifier"
    }
}

enum WorkoutDownloadStatus: String {
    case downloading = "Downloading"
    case downloaded = "Downloaded"
    case paused = "Paused"
    case cancelled = "Cancelled"
}
