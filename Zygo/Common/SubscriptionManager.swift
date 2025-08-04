//
//  SubscriptionManager.swift
//  Zygo
//
//  Created by Priya Gandhi on 20/02/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit
import StoreKit
import SwiftyStoreKit
class SubscriptionManager: NSObject {
    
    static let shared = SubscriptionManager()
    private let paymentService = SubscriptionServices()
    private var fetcher: ProductFetcher?
    private override init() {
    }
    
    func isValidSubscription() -> Bool{
        //TODO: Disbale for production
        if Helper.shared.isTestUser{
            return true
        }
        
        let cSubscription = PreferenceManager.shared.currentSubscribedProduct
        if cSubscription == nil{
            return false
        }else{
            if cSubscription!.expiryDate.isEmpty{
                return false
            }else{
                let expiryDate = cSubscription!.expiryDate.toSubscriptionDate()
                if expiryDate.compare(DateHelper.shared.currentUTCDateTime) == .orderedSame ||  expiryDate.compare(DateHelper.shared.currentUTCDateTime) == .orderedDescending{
                    return true
                }else{
                    return false
                }
            }
        }
    }
    
    
    func isValidSubscriptionFromApple(completion: @escaping (Bool) -> Void){
        
        SubscriptionManager.shared.verifyAnyActiveSubscription { (error, purachsedSubc) in
            
            if error != nil{
                completion(false)
                return
            }
            
            let userId = PreferenceManager.shared.userId
            
            var prize : Float = 14.99
            if purachsedSubc!.productId == SubscriptionManager.RegisteredPurchase.autoRenewableMonthly.rawValue{
                prize = 14.99
            }else if purachsedSubc!.productId == SubscriptionManager.RegisteredPurchase.autoRenewableYearly.rawValue{
                prize = 149.99
            }
            
            self.paymentService.updateSubscription(userId: userId, expiryDate: purachsedSubc!.expiryDate, transactionId: purachsedSubc!.transactionId, productId: purachsedSubc!.productId, amount: prize, originalTransactionId: purachsedSubc!.originalTransactionId) { (error, userInfo) in
                
                DispatchQueue.main.async {
                    
                    if error != nil{
                        if error == "This Apple ID already has a Zygo subscription associated with another Zygo account. Please log in with that account to access your subscription. To subscribe with a new Zygo account, first cancel your subscription in the App Store, then subscribe with a new account."{
                            completion(false)
                            return
                        }
                        Helper.shared.alert(title: Constants.appName, message: error!)
                        completion(false)
                        return
                    }
                    //Save purchase subcription in local preference
                    let subscriptionDict = [
                        "expiry_date": purachsedSubc!.expiryDate,
                        "transaction_id": purachsedSubc!.transactionId,
                        "plan_id": purachsedSubc!.productId,
                        "subscription_type": "apple_pay",
                        "original_transaction_id": purachsedSubc!.originalTransactionId
                    ]
                    
                    PreferenceManager.shared.currentSubscribedProduct = PurchasedSubscription(subscriptionDict)
                    
                    completion(true)//Payment Update Sucess Fully
                }
            }
        }
    }
    
    
    func purchase(product: RegisteredPurchase, completion: @escaping (String?) -> Void){
        
        SwiftyStoreKit.purchaseProduct(product.rawValue, atomically: true) { result in
            if case .success(let purchase) = result {
                
                let downloads = purchase.transaction.downloads
                if !downloads.isEmpty {
                    SwiftyStoreKit.start(downloads)
                }
                
                // Deliver content from server, then:
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
            }
            
            completion(self.messageForPurchaseResult(result))
        }
    }
    
    func fetchAllProducts(completion: @escaping (RetrieveResults) -> Void){
        
        //self.fetcher = TAProductFetcher(productIds: [RegisteredPurchase.autoRenewableYearly.rawValue, RegisteredPurchase.autoRenewableMonthly.rawValue, RegisteredPurchase.autoRenewableWeekly.rawValue], callback: completion)
        //self.fetcher?.start()
        self.fetchProducts(products: [ RegisteredPurchase.autoRenewableMonthly.rawValue, RegisteredPurchase.autoRenewableYearly.rawValue], completion: completion)
    }
    
    func fetchProducts(products: Set<String>, completion: @escaping (RetrieveResults) -> Void){
        SwiftyStoreKit.retrieveProductsInfo(products) { result in
            completion(result)
        }
    }
    
    func verifyAnyActiveSubscription(completion: @escaping(String?, PurchasedSubscription?) -> Void){
        
        
        verifyReceipt { result in
            switch result {
            case .success(let receipt):
                print("Verify receipt Success: \(receipt)")
                
                let purchaseResult = SwiftyStoreKit.verifySubscriptions(ofType: .autoRenewable, productIds: [RegisteredPurchase.autoRenewableMonthly.rawValue, RegisteredPurchase.autoRenewableYearly.rawValue], inReceipt: receipt)
                
                switch purchaseResult {
                case .purchased(let expiryDate, let items):
                    
                    let arrReceipts = items.sorted(by: { $0.subscriptionExpirationDate!.compare($1.subscriptionExpirationDate!) == .orderedDescending })
                    
                    if let receiptInfo = arrReceipts.first{
                       
                        let subscriptionDict = [
                            "expiry_date": expiryDate.toSubscriptionDate(),
                            "transaction_id": receiptInfo.transactionId,
                            "plan_id": receiptInfo.productId,
                            "subscription_type": "apple_pay",
                            "original_transaction_id": receiptInfo.originalTransactionId
                        ]
                        
                        completion(nil, PurchasedSubscription(subscriptionDict))
                        return
                    }
                    
                    completion("You don't have an active subscription.", nil)
                case .expired(_ , _ ):
                    completion("Your subscription has expired.", nil)
                case .notPurchased:
                    completion("You don't have an active subscription.", nil)
                }
                
                
            case .error(let error):
                print("Verify receipt Failed: \(error)")
                switch error {
                case .noReceiptData:
                    completion("You don't have an active subscription.", nil)
                case .networkError(let error):
                    completion("Network error while verifying receipt.", nil)
                default:
                    completion("Receipt verification failed" , nil)
                }
            }
        }
        
    }
    
    func verifyPurchase(_ purchase: RegisteredPurchase, completion: @escaping ((String,String)?, VerifySubscriptionResult?) -> Void) {
        
        verifyReceipt { result in
            //NetworkActivityIndicatorManager.networkOperationFinished()
            switch result {
            case .success(let receipt):
                
                let productId = purchase.rawValue
                
                switch purchase {
                case  .autoRenewableMonthly:
                    let purchaseResult = SwiftyStoreKit.verifySubscription(
                        ofType: .autoRenewable,
                        productId: productId,
                        inReceipt: receipt)
                    completion(nil, purchaseResult)
                    print(purchaseResult)
                case .autoRenewableYearly:
                    let purchaseResult = SwiftyStoreKit.verifySubscription(
                        ofType: .autoRenewable,
                        productId: productId,
                        inReceipt: receipt)
                    completion(nil, purchaseResult)
                }
                
            case .error:
                let (title, message) = self.messageForVerifyReceipt(result)
                completion((title, message), nil)
            }
        }
    }
    
    func verifyReceipt(completion: @escaping (VerifyReceiptResult) -> Void) {
        
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: SubscriptionManager.IAPSecretKey)
        SwiftyStoreKit.verifyReceipt(using: appleValidator, completion: completion)
        
    }
}
extension SubscriptionManager{
    
    enum RegisteredPurchase: String {
        case autoRenewableMonthly  = "com.zygo.ios.month"
        case autoRenewableYearly  = "com.zygo.ios.year"
    }
    
    private static let IAPSecretKey = "5c29e2b65b1f472290b814f97cd7e70d"//"711244f8a8ff4bb1a7380dcd394c1079"
}

extension SubscriptionManager{
    func getDurationTitle(product: SKProduct, defaultTitle: String = "months") -> String{
        var strDuration = defaultTitle
        
        let isSingular = (product.subscriptionPeriod?.numberOfUnits ?? 1) <= 1
        
        let unit = product.subscriptionPeriod?.unit
        switch unit {
        case .day:
            strDuration = isSingular ? "day" : "days"
        case .month:
            strDuration = isSingular ? "month" : "months"
        case .week:
            strDuration = isSingular ? "week" : "weeks"
        case .year:
            strDuration = isSingular ? "year" : "years"
        case .none:
            strDuration = isSingular ? defaultTitle : "\(defaultTitle)s"
        case .some(_):
            strDuration = isSingular ? defaultTitle : "\(defaultTitle)s"
        }
        
        return strDuration
    }
    
    func messageForPurchaseResult(_ result: PurchaseResult) -> String? {
        switch result {
        case .success(_ ):
            return nil
        case .error(let error):
            print("Purchase Failed: \(error)")
            switch error.code {
            case .unknown: return (error as NSError).localizedDescription
            case .clientInvalid: // client is not allowed to issue the request, etc.
                return "The payment process failed. Please try again."
            case .paymentCancelled: // user cancelled the request, etc.
                return "Your purchase request was cancelled."
            case .paymentInvalid: // purchase identifier was invalid, etc.
                return "The purchase identifier was invalid"
            case .paymentNotAllowed: // this device is not allowed to make the payment
                return "The device is not allowed to make the payment"
            case .storeProductNotAvailable: // Product is not available in the current storefront
                return "This product is currently not available."
            case .cloudServicePermissionDenied: // user has not allowed access to cloud service information
                return "Permission to cloud service information failed."
            case .cloudServiceNetworkConnectionFailed: // the device could not connect to the nework
                return "Could not connect to the network."
            case .cloudServiceRevoked: // user has revoked permission to use this cloud service
                return "Cloud service access was revoked."
            default:
                return (error as NSError).localizedDescription
            }
        }
    }
    
    func messageForVerifySubscriptions(_ result: VerifySubscriptionResult, productIds: Set<String>) -> (String,String) {
        
        switch result {
        case .purchased(let expiryDate, let items):
            print("\(productIds) is valid until \(expiryDate)\n\(items)\n")
            return ("Product is purchased", "Product is valid until \(expiryDate)")
        case .expired(let expiryDate, let items):
            print("\(productIds) is expired since \(expiryDate)\n\(items)\n")
            return ("Product expired", "Product is expired since \(expiryDate)")
        case .notPurchased:
            print("\(productIds) has never been purchased")
            return ("Not purchased", "This product has never been purchased")
        }
    }
    
    func messageForVerifyReceipt(_ result: VerifyReceiptResult) -> (String,String) {
        
        switch result {
        case .success(let receipt):
            print("Verify receipt Success: \(receipt)")
            return ("Receipt verified","Receipt verified remotely")
        case .error(let error):
            print("Verify receipt Failed: \(error)")
            switch error {
            case .noReceiptData:
                return ("Receipt verification","No receipt data. Try again.")
            case .networkError(let error):
                return ("Receipt verification","We couldn’t connect to the server. Please try again.")
                //return ("Receipt verification","Network error while verifying receipt: \(error.localizedDescription)")
            default:
                return ("Receipt verification","Receipt verification failed. Please try again.")
            }
        }
    }
}

struct PurchasedSubscription {
    var productId: String = ""
    var transactionId: String = ""
    var expiryDate: String = ""
    var type: String = "apple_pay"
    var originalTransactionId: String = ""
    
    init(_ dict: [String: Any]) {
        self.expiryDate = dict["expiry_date"] as? String ?? ""
        self.transactionId = dict["transaction_id"] as? String ?? ""
        self.productId = dict["plan_id"] as? String ?? ""
        self.type = dict["subscription_type"] as? String ?? ""
        self.originalTransactionId = dict["original_transaction_id"] as? String ?? ""
    }
    
    func toDict() -> [String: Any]{
        return [
            "expiry_date": self.expiryDate,
            "transaction_id": self.transactionId,
            "plan_id": self.productId,
            "subscription_type": self.type,
            "original_transaction_id": self.originalTransactionId
        ]
    }
}
