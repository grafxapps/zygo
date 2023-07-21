//
//  ProductFetcher.swift
//  Zygo
//
//  Created by Priya Gandhi on 20/02/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit
import StoreKit
import SwiftyStoreKit

typealias InAppProductRequestCallback = (RetrieveResults) -> Void

class ProductFetcher: NSObject, SKProductsRequestDelegate {
    
    private let request: SKProductsRequest
    private let callback: InAppProductRequestCallback
    
    deinit {
        request.delegate = nil
    }
    init(productIds: Set<String>, callback: @escaping InAppProductRequestCallback) {
        
        self.callback = callback
        request = SKProductsRequest(productIdentifiers: productIds)
        super.init()
        request.delegate = self
    }
    
    func start() {
        request.start()
    }
    func cancel() {
        request.cancel()
    }
    
    // MARK: SKProductsRequestDelegate
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        let retrievedProducts = Set<SKProduct>(response.products)
        let invalidProductIDs = Set<String>(response.invalidProductIdentifiers)
        performCallback(RetrieveResults(retrievedProducts: retrievedProducts,
                                        invalidProductIDs: invalidProductIDs, error: nil))
    }
    
    func requestDidFinish(_ request: SKRequest) {
        
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        performCallback(RetrieveResults(retrievedProducts: Set<SKProduct>(), invalidProductIDs: Set<String>(), error: error))
    }
    
    private func performCallback(_ results: RetrieveResults) {
        DispatchQueue.main.async {
            self.callback(results)
        }
    }
    
}
