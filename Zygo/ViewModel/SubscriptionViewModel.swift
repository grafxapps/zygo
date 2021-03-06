//
//  SubscriptionViewModel.swift
//  Zygo
//
//  Created by Priya Gandhi on 20/02/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit
import SwiftyStoreKit
import StoreKit
class SubscriptionViewModel: NSObject {
    
    let paymentService = SubscriptionServices()
    
    func uloadReceipt(receipt: VerifySubscriptionResult, completion: @escaping (String?,Bool) -> Void){
        
        switch receipt {
        case .purchased(let expiryDate, let items):
            
            let arrReceipts = items.sorted(by: { $0.subscriptionExpirationDate!.compare($1.subscriptionExpirationDate!) == .orderedDescending })
            if let receiptInfo = arrReceipts.first{
                self.updateReceipt(expiryDate: expiryDate, transactionId: receiptInfo.transactionId, productId: receiptInfo.productId, completion: completion)
                return
            }
            
            Helper.shared.stopLoading()
            Helper.shared.alert(title: Constants.appName, message: "This subscription has never been purchased")
            completion(nil, false)
        case .expired(_ , _):
            Helper.shared.stopLoading()
            Helper.shared.alert(title: Constants.appName, message: "Your subscription has expired")
            completion(nil, false)
        case .notPurchased:
            Helper.shared.stopLoading()
            Helper.shared.alert(title: Constants.appName, message: "This subscription has never been purchased")
            completion(nil, false)
        }
    }
    
    
    func updateReceipt(expiryDate: Date,transactionId: String, productId: String, completion: @escaping (String?,Bool) -> Void){
       
        let userId = PreferenceManager.shared.userId
        paymentService.updateSubscription(userId: userId, expiryDate: expiryDate.toSubscriptionDate(), transactionId: transactionId, productId: productId, amount: "") { (error, userInfo) in
            
            DispatchQueue.main.async {
                
                Helper.shared.stopLoading()
                if error != nil{
                    completion(error!, false)//User Can try again to upload receipt on server
                    return
                }
                
                //Save purchase subcription in local preference
                let subscriptionDict = [
                    "expiry_date": expiryDate.toSubscriptionDate(),
                    "transaction_id": transactionId,
                    "plan_id": productId,
                    "subscription_type": "apple_pay"
                ]
                
                PreferenceManager.shared.currentSubscribedProduct = PurchasedSubscription(subscriptionDict)
                
                completion(nil, true)//Payment Update Sucess Fully
            }
        }
    }
    
}
