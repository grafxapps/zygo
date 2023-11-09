//
//  TrackingDTO.swift
//  Zygo
//
//  Created by Som on 05/03/22.
//  Copyright © 2022 Somparkash. All rights reserved.
//

import UIKit

struct TrackingInfoDTO {
    
    var isDistanceTracking: Bool = true
    var isTempoTracking: Bool = true
    
    init(_ dict: [String: Any]) {
        self.isDistanceTracking = NSNumber(value: dict["distance_tracking_on"] as? Int ?? 1).boolValue
        self.isTempoTracking = NSNumber(value: dict["tempo_tracking_on"] as? Int ?? 1).boolValue
    }
    
    func toDict() -> [String: Any]{
        return [
            "distance_tracking_on": NSNumber(value: self.isDistanceTracking).intValue,
            "tempo_tracking_on": NSNumber(value: self.isTempoTracking).intValue,
        ]
    }
}
