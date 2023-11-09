//
//  DeleteAccountVC.swift
//  Zygo
//
//  Created by Som on 12/06/22.
//  Copyright © 2022 Somparkash. All rights reserved.
//

import UIKit

//MARK: -
class DeleteAccountVC: UIViewController {
    
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var lblNo: UILabel!
    @IBOutlet weak var lblYes: UILabel!

    private let service = UserServices()
    private let viewModel = SubscriptionViewModel()
    
    var onDeleteAccount: (() -> Void)?
    
    //MARK: - UIViewcontroller LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()

    }
    
    //MARK: - Setups
    func setupUI(){
        
        let attString = "This action cannot be reversed. Are you sure you want to delete your account?"
        let subString = "delete your account?"
        let att = NSMutableAttributedString(string: attString)
        att.addAttributes([.font: UIFont.appBold(with: 16.0)], range: (attString as NSString).range(of: subString))
        lblInfo.attributedText = att
        
        let notAttString = NSAttributedString(string: "No, just cancel my subscription", attributes: [.underlineStyle : NSUnderlineStyle.single.rawValue])
        lblNo.attributedText = notAttString
        
        let yesAttString = NSAttributedString(string: "Yes, permanently delete my account", attributes: [.underlineStyle : NSUnderlineStyle.single.rawValue])
        lblYes.attributedText = yesAttString
        
    }
    
    //MARK: - UIButton Actions
    @IBAction func cancelSubscriptionAction(_ sender: UIButton){
        if PreferenceManager.shared.currentSubscribedProduct?.type ?? "" == SubscriptionType.Stripe.rawValue{
            //Hit API
            Helper.shared.log(event: .CANCELSTRIPESUBSCRIPTION, params: [:])
            self.viewModel.cancelStripeSubscription { (isCancelled) in
                
                if isCancelled{
                    Helper.shared.alert(title: Constants.appName, message: "Your subscription has been cancelled successfully."){
                        self.exitAction()
                    }
                }
                
            }
            return
        }else if PreferenceManager.shared.currentSubscribedProduct?.type ?? "" == SubscriptionType.Google.rawValue{
            Helper.shared.alert(title: Constants.appName, message: "Sorry, this subscription was not purchased through Apple, and so can only be managed on an android device."){
                self.exitAction()
            }
            return
        }
        
        Helper.shared.log(event: .CANCELSUBSCRIPTION, params: [:])
        Helper.shared.openUrl(url: URL(string: Constants.cancelSubscription))
        self.exitAction()
    }
    
    @IBAction func exitAction(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func yesAction(_ sender: UIButton){
        Helper.shared.startLoading()
        self.service.deleteAccount { (error) in
            DispatchQueue.main.async {
                Helper.shared.stopLoading()
                
                if error != nil{
                    Helper.shared.alert(title: Constants.appName, message: error!)
                    return
                }
                
                self.dismiss(animated: true) {
                    self.onDeleteAccount?()
                }
            }
        }
    }

}
