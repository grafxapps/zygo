//
//  HealthKitManager.swift
//  Zygo
//
//  Created by Som on 12/06/22.
//  Copyright © 2022 Somparkash. All rights reserved.
//

import UIKit
import HealthKit

final class HealthKitManager: NSObject {
    
    static let sharedInstance = HealthKitManager()
    private let healthStore = HKHealthStore()
    
    
    private enum HealthKitControllerError: Error {
        case DeviceNotSupported
        case DataTypeNotAvailable
    }
    
    func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Void) {
        
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, HealthKitControllerError.DeviceNotSupported)
            return
        }
        
        guard let distanceSwimming = HKObjectType.quantityType(forIdentifier: .distanceSwimming)
            else {
                completion(false, HealthKitControllerError.DataTypeNotAvailable)
                return
        }
        
        
        let dataToWrite: Set<HKSampleType> = [distanceSwimming]
        //let dataToRead: Set<HKSampleType> = [distanceSwimming]
        
        healthStore.requestAuthorization(toShare: dataToWrite, read: []) { (success, error) in
            if success{
                
            }
            completion(success, error)
        }
    }
    
    func writeSwimmingDistance(distance: Double, completion: @escaping () -> Void){
        guard let swimmingType = HKSampleType.quantityType(forIdentifier: .distanceSwimming) else {
            completion()
            return
        }
        
        self.writeSample(for: swimmingType, sampleQuantity: .init(unit: .yard(), doubleValue: distance)) { (sucess, error) in
            completion()
        }
    }
    
    func writeSample(for quantityType: HKQuantityType, sampleQuantity: HKQuantity, completion: @escaping (Bool, Error?) -> Void) {
        
        let sample = HKQuantitySample(type: quantityType, quantity: sampleQuantity, start: DateHelper.shared.currentLocalDateTime, end: DateHelper.shared.currentLocalDateTime)
        healthStore.save(sample) { (sucess, error) in
            DispatchQueue.main.async {
                completion(sucess, error)
            }
        }
    }

}
