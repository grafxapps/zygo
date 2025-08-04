//
//  BLEServices.swift
//  Zygo
//
//  Created by Som Parkash on 15/12/22.
//  Copyright © 2022 Somparkash. All rights reserved.
//

import UIKit

class BLEServices: NSObject {
    
    func fetchFirmwareDetails(zygoVersion: ZygoDeviceVersion, completion: @escaping (String?,  [String: Any]) -> Void){
        var params: [String:Any]
        if zygoVersion == .v1{
            params = ["group_id": Constants.BLEBatchID]
        }else{
            params = ["group_id": Constants.BLEZ2BatchID]
        }
        
        NetworkManager.shared.request(withEndPoint: .getFirmwareFiles, method: .get, headers: nil, params: params) { (response) in
            
            switch response{
            case .success(let jsonResponse):
                let responseDict = jsonResponse[AppKeys.data.rawValue] as? [String:Any] ?? [:]
                completion(nil,responseDict)
            case .failure(let status, let message):
                if status == .Cancelled{
                    completion(nil,[:])
                    return
                }
                print(message)
                completion(message,[:])
            case .notConnectedToInternet:
                print(Constants.internetNotWorking)
                completion(Constants.internetNotWorking, [:])
            }
        }
    }
}
