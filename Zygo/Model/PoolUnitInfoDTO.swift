//
//  PoolUnitInfoDTO.swift
//  Zygo
//
//  Created by Som on 07/03/22.
//  Copyright © 2022 Somparkash. All rights reserved.
//

import UIKit

struct PoolUnitInfoDTO {
 
    var unitPref: Units = ((NSLocale.current.regionCode ?? "").lowercased() == "us") ? .standard : .metric
    var defaultPoolLength: PoolType = .twentyFiveYards
    var customPoolDistance: Double = 0.0
    var customPoolLengthUnits: PoolLengthUnit = .yards
    
    
    init(_ dict: [String: Any]) {
        self.customPoolDistance = Double(dict["custom_pool_length_dist"] as? String ?? "0.0") ?? 0.0
        self.customPoolLengthUnits = PoolLengthUnit(rawValue: dict["custom_pool_length_units"] as? String ?? PoolLengthUnit.yards.rawValue) ?? .yards
        self.defaultPoolLength = PoolType(rawValue: dict["default_pool_length"] as? String ?? PoolType.twentyFiveYards.rawValue) ?? .twentyFiveYards
        self.unitPref = Units(rawValue: dict["unit_preference"] as? String ?? Units.standard.rawValue) ?? (((NSLocale.current.regionCode ?? "").lowercased() == "us") ? .standard : .metric)
    }
    
    func toDict() -> [String: Any]{
        return [
            "custom_pool_length_dist": "\(self.customPoolDistance)",
            "custom_pool_length_units": self.customPoolLengthUnits.rawValue,
            "default_pool_length": self.defaultPoolLength.rawValue,
            "unit_preference": self.unitPref.rawValue
        ]
    }
}
