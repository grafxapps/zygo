//
//  SubscriptionServices.swift
//  Zygo
//
//  Created by Priya Gandhi on 20/02/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit

class SubscriptionServices: NSObject {
    
    func updateSubscription(userId: Int, expiryDate: String, transactionId: String, productId: String,amount : Float, originalTransactionId: String,  completion: @escaping (String?,  [String: Any]?) -> Void){
        let header = NetworkManager.shared.getHeader()
        print(header)
        let param = [
            "plan_id": productId,
            "subscription_id": transactionId,
            "expire_date": expiryDate,
            "amount": amount,
            "subscription_status": "active",
            "trail_days": "14",
            "apple_unique_id": originalTransactionId
            ] as [String : Any]
        print(param)
        NetworkManager.shared.request(withEndPoint: .subscriptionPayment, method: .post, headers: header, params: param) { (response) in
            
            switch response{
            case .success(let jsonResponse):
                let responseDict = jsonResponse[AppKeys.details.rawValue] as? [String:Any] ?? [:]
                completion(nil,responseDict)
            case .failure(_, let message):
                print(message)
                completion(message,nil)
            case .notConnectedToInternet:
                print(Constants.internetNotWorking)
                completion(Constants.internetNotWorking, nil)
            }
        }
    }
    
    func cancelSubscription(userId: Int, expiryDate: String, transactionId: String, productId: String,  completion: @escaping (String?) -> Void){
        
        let param = [:] as [String : Any]
        
        
        NetworkManager.shared.request(withEndPoint: .cancelSubscription, method: .post, headers: nil, params: param) { (response) in
            
            switch response{
            case .success(_ ):
                completion(nil)
            case .failure(_, let message):
                print(message)
                completion(message)
            case .notConnectedToInternet:
                print(Constants.internetNotWorking)
                completion(Constants.internetNotWorking)
            }
        }
    }
    
    func cancelOtherSubscription(completion: @escaping (String?) -> Void){
        
        let header = NetworkManager.shared.getHeader()
        let param = [:] as [String : Any]
        
        
        NetworkManager.shared.request(withEndPoint: .cancelOtherSubscription, method: .post, headers: header, params: param) { (response) in
            
            switch response{
            case .success(_ ):
                completion(nil)
            case .failure(_, let message):
                print(message)
                completion(message)
            case .notConnectedToInternet:
                print(Constants.internetNotWorking)
                completion(Constants.internetNotWorking)
            }
        }
    }
    
    
}
