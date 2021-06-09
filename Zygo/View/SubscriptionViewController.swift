//
//  SubscriptionViewController.swift
//  Zygo
//
//  Created by Priya Gandhi on 23/01/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit
import StoreKit
import SwiftyStoreKit
import IQKeyboardManagerSwift

class SubscriptionViewController: UIViewController {
    
    @IBOutlet weak var viewSubscription : UIView!
    
    @IBOutlet weak var btnRedeemCode : UIButton!
    
    
    @IBOutlet weak var lblMonthlyPrice : UILabel!
    
    private let viewModel = SubscriptionViewModel()
    var isForChangeSubscription: Bool = false
    
    //MARK: - UIViewcontroller LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 14.0, *) {
            self.btnRedeemCode.isHidden = false
        }else{
            self.btnRedeemCode.isHidden = true
        }
        
        self.setupUI()
        self.fetchProducts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = true
    }
    
    func setupUI()  {
        Helper.shared.setupViewLayer(sender: self.viewSubscription, isSsubScriptionView: true);
    }
    
    //MARK: - UIButton Action
    @IBAction func backAction(){
        Helper.shared.logout()
    }
    
    
    @IBAction func privacyPolicyAction(){
        let url = URL(string: Constants.privacyPolicy)
        Helper.shared.openUrl(url: url)
    }
    
    @IBAction func termsOfUseAction(){
        let url = URL(string: Constants.termsOfService)
        Helper.shared.openUrl(url: url)
    }
    
    @IBAction func redeemAction(){
        let paymentQueue = SKPaymentQueue.default()
        if #available(iOS 14.0, *) {
            paymentQueue.presentCodeRedemptionSheet()
        }
    }
    
    @IBAction func alreadyPaidAction (sender : UIButton){
        
        Helper.shared.startLoading()
        SubscriptionManager.shared.verifyAnyActiveSubscription { (error, purachsedSubc) in
            Helper.shared.stopLoading()
            
            if error != nil{
                Helper.shared.alert(title: Constants.appName, message: error!)
                return
            }
            Helper.shared.startLoading()
            
            self.viewModel.updateReceipt(expiryDate: purachsedSubc!.expiryDate.toSubscriptionDate(), transactionId: purachsedSubc!.transactionId, productId: purachsedSubc!.productId) { (retryError, isUploaded) in
                
                if isUploaded{
                    //  PreferenceManager.shared.isSubscriptionPending = false
                    
                    if self.isForChangeSubscription{
                        //Helper.shared.alert(title: "Success!", message: "Plan successfully changed.")
                        self.navigationController?.popViewController(animated: true)
                    }else{
                        //CHECK IF USER PROFILE IS NOT UPDATED THEN MOVE TO PROFILE SCREEN
                        let userItem = PreferenceManager.shared.user
                        if userItem.gender.isEmpty || userItem.email.isEmpty{//MEANS PROFILE ISN'T UPDATED
                            Helper.shared.setCreateProfileRoot()
                            
                        }else{
                            //MOVE TO DASHBOARD
                            Helper.shared.setDashboardRoot()
                        }
                    }
                    
                    return
                }
                
                if retryError != nil{
                    Helper.shared.alert(title: Constants.appName, message: retryError!)
                    return
                }
            }
        }
    }
    
    func verifyPucrchased(product: SubscriptionManager.RegisteredPurchase){
        
        Helper.shared.startLoading()
        SubscriptionManager.shared.verifyPurchase(product) { ( error, purchasedProductReceipt) in
            
            DispatchQueue.main.async {
                Helper.shared.stopLoading()
                if error != nil{
                    Helper.shared.alert(title: error!.0, message: error!.1)
                    return
                }
                
                if purchasedProductReceipt != nil{
                    Helper.shared.startLoading()
                    self.viewModel.uloadReceipt(receipt: purchasedProductReceipt!) { (retryError, isUploaded) in
                        
                        if isUploaded{
                            // PreferenceManager.shared.isSubscriptionPending = false
                            
                            if self.isForChangeSubscription{
                                Helper.shared.alert(title: "Success!", message: "Plan successfully changed.")
                                self.navigationController?.popViewController(animated: true)
                            }else{
                                //CHECK IF USER PROFILE IS NOT UPDATED THEN MOVE TO PROFILE SCREEN
                                let userItem = PreferenceManager.shared.user
                                if userItem.gender.isEmpty || userItem.email.isEmpty{//MEANS PROFILE ISN'T UPDATED
                                    Helper.shared.setCreateProfileRoot()
                                    
                                }else{
                                    //MOVE TO DASHBOARD
                                    Helper.shared.setDashboardRoot()
                                }
                            }
                            
                            return
                        }
                        
                        if retryError != nil{
                            Helper.shared.alertYesNoActions(title: Constants.appName, message: retryError!, yesActionTitle: "Try Again", noActionTitle: "Cancel") { (isTryAgain) in
                                if isTryAgain{
                                    self.verifyPucrchased(product: product)
                                }
                            }
                            return
                        }
                    }
                }
            }
        }
    }
    @IBAction func subscribeAction (sender : UIButton){
        
        let product = SubscriptionManager.RegisteredPurchase.autoRenewableMonthly.rawValue
        Helper.shared.startLoading()
        SubscriptionManager.shared.purchase(product: SubscriptionManager.RegisteredPurchase(rawValue: product)!) { (error) in
            Helper.shared.stopLoading()
            if error != nil{
                Helper.shared.alert(title: Constants.appName, message: error!)
                return
            }
            
            //Verify Receipt
            //For Update on server need to fetch receipt from app.
            self.verifyPucrchased(product: SubscriptionManager.RegisteredPurchase(rawValue: product)!)
            
        }
        
        
        //PreferenceManager.shared.isSubscriptionPending = false
        //Helper.shared.setDashboardRoot()
        
    }
}
//MARK: - InApp Purchase
extension SubscriptionViewController{
    
    func fetchProducts() {
        SubscriptionManager.shared.fetchAllProducts { [weak self] (result) in
            self?.updateProductsInfo(result)
        }
    }
    
    func updateProductsInfo(_ result: RetrieveResults){
        if result.invalidProductIDs.count > 0{
            //If any product reterieved invalid then no need to update the information of other products
            return
        }
        for product in result.retrievedProducts{
            let productType = SubscriptionManager.RegisteredPurchase(rawValue: product.productIdentifier)!
            
            switch productType {
            case .autoRenewableMonthly:
                self.updateMonthlyProductInfo(product: product)
            }
        }
    }
    
    func updateMonthlyProductInfo(product: SKProduct){
        
        //  lblMonthlyDurationTitle.text = SubscriptionManager.shared.getDurationTitle(product: product, defaultTitle: "Month")
        
        let price = product.localizedPrice ?? "$14.99"
        let attributeString = NSMutableAttributedString(string: "\(price)/month")
        attributeString.addAttributes([.font: UIFont.appBold(with: 26.0)], range: NSRange(location: 0, length: price.count))
        attributeString.addAttributes([.font: UIFont.appBold(with: 14.0)], range: NSRange(location: price.count, length: 6))
        attributeString.addAttributes([.foregroundColor: UIColor.appBlueColor()], range: NSRange(location: 0, length: price.count + 6))
        
        lblMonthlyPrice.attributedText = attributeString
        
    }
    
    
}

