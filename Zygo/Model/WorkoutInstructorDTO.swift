//
//  WorkoutInstructorDTO.swift
//  Zygo
//
//  Created by Som on 30/01/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit

struct WorkoutInstructorDTO{
    var instructorId: Int = -1
    var instructorFirstName: String = ""
    var instructorLastName: String = ""
    var instructorPic: String = ""
    var instructorBio: String = ""
    var instructorVideo: String = ""
    var instructorVideoThumbnail: String = ""
    var socialMedia: String = ""
    var createdAt: String = ""
    var updatedAt: String = ""
    
    init(_ dict: [String: Any]) {
        //TODO: Add Social media
        self.instructorId = dict["id"] as? Int ?? 0
        self.instructorFirstName = dict["instructor_first_name"] as? String ?? ""
        self.instructorLastName = dict["instructor_last_name"] as? String ?? ""
        self.instructorPic = dict["instructor_pic"] as? String ?? ""
        self.instructorBio = dict["instructor_bio"] as? String ?? ""
        self.instructorVideo = dict["instructor_video"] as? String ?? ""
        self.instructorVideoThumbnail = dict["instructor_video_thumbnail"] as? String ?? ""
        self.socialMedia = dict["social_media"] as? String ?? ""
        self.createdAt = dict["created_at"] as? String ?? ""
        self.updatedAt = dict["updated_at"] as? String ?? ""
        
    }
    
    func toDict() -> [String: Any]{
        return [
            "id": self.instructorId,
            "instructor_first_name": self.instructorFirstName,
            "instructor_last_name": self.instructorLastName,
            "instructor_pic": self.instructorPic,
            "instructor_bio": self.instructorBio,
            "instructor_video": self.instructorVideo,
            "instructor_video_thumbnail": self.instructorVideoThumbnail,
            "social_media": self.socialMedia,
            "created_at": self.createdAt,
            "updated_at": self.updatedAt
        ]
    }
}
