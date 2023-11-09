//
//  SubscriptionCancelVC.swift
//  Zygo
//
//  Created by Som on 05/03/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit
import StoreKit
import SwiftyStoreKit

class SubscriptionCancelVC: UIViewController {
    
    @IBOutlet weak var viewSubscription : UIView!
    @IBOutlet weak var lblMonthlyPrice : UILabel!
    private let viewModel = SubscriptionViewModel()
    
    var isNeedToCheckCountry: Bool = false
    
    //MARK: - UIViewcontroller LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.fetchProducts()
    }
    
    func setupUI()  {
        Helper.shared.setupViewLayer(sender: self.viewSubscription, isSsubScriptionView: true);
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let storeFront = SKPaymentQueue.default().storefront {
            if storeFront.countryCode != "USA"{
                Helper.shared.alert(title: Constants.appName, message: "Sorry! Due to music licensing rights, subscriptions are currently only available in the United States.") {
                    self.backAction()
                }
            }
            print("Storefront", storeFront.countryCode)
        } else {
            self.isNeedToCheckCountry = true
            print("Storefront nil")
        }
    }
    
    //MARK: - UIButton Action
    @IBAction func backAction(){
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func privacyPolicyAction(){
        let url = URL(string: Constants.privacyPolicy)
        Helper.shared.openUrl(url: url)
    }
    
    @IBAction func termsOfUseAction(){
        let url = URL(string: Constants.termsOfService)
        Helper.shared.openUrl(url: url)
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
            
            var prize : Float = 14.99
            if purachsedSubc!.productId == SubscriptionManager.RegisteredPurchase.autoRenewableMonthly.rawValue{
                prize = 14.99
            }else if purachsedSubc!.productId == SubscriptionManager.RegisteredPurchase.autoRenewableYearly.rawValue{
                prize = 149.99
            }
            
            self.viewModel.updateReceipt(expiryDate: purachsedSubc!.expiryDate.toSubscriptionDate(), transactionId: purachsedSubc!.transactionId, productId: purachsedSubc!.productId, amount: prize, originalTransactionId: purachsedSubc!.originalTransactionId) { (retryError, isUploaded) in
                
                if isUploaded{
                    Helper.shared.alert(title: "Success!", message: "Plan successully updated.") {
                        self.navigationController?.popViewController(animated: true)
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
                            
                            Helper.shared.alert(title: "Success!", message: "Plan successully updated.") {
                                self.navigationController?.popViewController(animated: true)
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
    
    
    @IBAction func cancelSubscription(sender: UIButton){
        
        if PreferenceManager.shared.currentSubscribedProduct?.type ?? "" == SubscriptionType.Stripe.rawValue{
            //Hit API
            Helper.shared.log(event: .CANCELSTRIPESUBSCRIPTION, params: [:])
            self.viewModel.cancelStripeSubscription { (isCancelled) in
                
                if isCancelled{
                    Helper.shared.alert(title: Constants.appName, message: "Your subscription has been cancelled successfully."){
                        self.backAction()
                    }
                }
                
            }
            return
        }else if PreferenceManager.shared.currentSubscribedProduct?.type ?? "" == SubscriptionType.Google.rawValue{
            Helper.shared.alert(title: Constants.appName, message: "Sorry, this subscription was not purchased through Apple, and so can only be managed on an android device.")
            return
        }
        
        Helper.shared.log(event: .CANCELSUBSCRIPTION, params: [:])
        Helper.shared.openUrl(url: URL(string: Constants.cancelSubscription))
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
    
    @IBAction func reseemCodeAction (sender : UIButton){
        
    }
    
    @IBAction func deleteAccountAction(_ sender: UIButton){
        
        let deleteDesVC = DeleteAccountDescriptionVC(nibName: "DeleteAccountDescriptionVC", bundle: nil)
        deleteDesVC.modalPresentationStyle = .overCurrentContext
        deleteDesVC.onContinue = {
            let deleteVC = DeleteAccountVC(nibName: "DeleteAccountVC", bundle: nil)
            deleteVC.transitioningDelegate = self
            deleteVC.modalPresentationStyle = .custom
            deleteVC.onDeleteAccount = {
                //Silent logout and go to login screen
                Helper.shared.silentLogout()
            }
            
            self.present(deleteVC, animated: true, completion: nil)
        }
        self.present(deleteDesVC, animated: true, completion: nil)
        
    }
}


//MARK: - InApp Purchase
extension SubscriptionCancelVC{
    
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
            
            var cIdentifier = PreferenceManager.shared.currentSubscribedProduct?.productId ?? ""
            if cIdentifier.isEmpty{
                cIdentifier = SubscriptionManager.RegisteredPurchase.autoRenewableYearly.rawValue
            }
            switch productType {
            case .autoRenewableMonthly:
                if cIdentifier == SubscriptionManager.RegisteredPurchase.autoRenewableMonthly.rawValue{
                    self.updateMonthlyProductInfo(product: product)
                }
                
            case .autoRenewableYearly:
                if cIdentifier == SubscriptionManager.RegisteredPurchase.autoRenewableYearly.rawValue{
                    self.updateYearlyProductInfo(product: product)
                }
                print("")
            }
        }
        
        if self.lblMonthlyPrice.text!.isEmpty{
            let price = "$14.99"
            let attributeString = NSMutableAttributedString(string: "\(price)/month")
            attributeString.addAttributes([.font: UIFont.appBold(with: 26.0)], range: NSRange(location: 0, length: price.count))
            attributeString.addAttributes([.font: UIFont.appBold(with: 14.0)], range: NSRange(location: price.count, length: 6))
            attributeString.addAttributes([.foregroundColor: UIColor.appBlueColor()], range: NSRange(location: 0, length: price.count + 6))
            
            lblMonthlyPrice.attributedText = attributeString
        }
    }
    
    func updateMonthlyProductInfo(product: SKProduct){
        
        //  lblMonthlyDurationTitle.text = SubscriptionManager.shared.getDurationTitle(product: product, defaultTitle: "Month")
        
        if isNeedToCheckCountry{
            let priceIdentifier = product.priceLocale.identifier
            let arrSubStrings = priceIdentifier.components(separatedBy: "@")
            if arrSubStrings.count > 0{
                let countryCode = arrSubStrings[0]
                if countryCode != "en_US"{
                    Helper.shared.alert(title: Constants.appName, message: "Sorry! Due to music licensing rights, subscriptions are currently only available in the United States.") {
                        self.backAction()
                    }
                }
            }
        }
        
        let price = product.localizedPrice ?? "$14.99"
        let attributeString = NSMutableAttributedString(string: "\(price)/month")
        attributeString.addAttributes([.font: UIFont.appBold(with: 26.0)], range: NSRange(location: 0, length: price.count))
        attributeString.addAttributes([.font: UIFont.appBold(with: 14.0)], range: NSRange(location: price.count, length: 6))
        attributeString.addAttributes([.foregroundColor: UIColor.appBlueColor()], range: NSRange(location: 0, length: price.count + 6))
        
        lblMonthlyPrice.attributedText = attributeString
        
    }
    
    
    func updateYearlyProductInfo(product: SKProduct){
        
        if isNeedToCheckCountry{
            let priceIdentifier = product.priceLocale.identifier
            let arrSubStrings = priceIdentifier.components(separatedBy: "@")
            if arrSubStrings.count > 0{
                let countryCode = arrSubStrings[0]
                if countryCode != "en_US"{
                    Helper.shared.alert(title: Constants.appName, message: "Sorry! Due to music licensing rights, subscriptions are currently only available in the United States.") {
                        self.backAction()
                    }
                }
            }
        }
        
        let price = product.localizedPrice ?? "$149.99"
        let attributeString = NSMutableAttributedString(string: "\(price)/year")
        attributeString.addAttributes([.font: UIFont.appBold(with: 26.0)], range: NSRange(location: 0, length: price.count))
        attributeString.addAttributes([.font: UIFont.appBold(with: 14.0)], range: NSRange(location: price.count, length: 5))
        attributeString.addAttributes([.foregroundColor: UIColor.appBlueColor()], range: NSRange(location: 0, length: price.count + 5))
        
        lblMonthlyPrice.attributedText = attributeString
        
    }
}


extension SubscriptionCancelVC: UIViewControllerTransitioningDelegate{
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentingAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissingAnimator()
    }
    
}
