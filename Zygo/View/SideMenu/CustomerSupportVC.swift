//
//  CustomerSupportVC.swift
//  Zygo
//
//  Created by Som on 28/01/22.
//  Copyright © 2022 Somparkash. All rights reserved.
//

import UIKit
import MessageUI

//MARK: -
class CustomerSupportVC: UIViewController {

    //MARK: - UIViewcontroller LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    //MARK: - Setups
    
    
    //MARK: - UIButton Actions
    @IBAction func backAction(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func faqAction(_ sender: UIButton){
        Helper.shared.log(event: .FAQ, params: [:])
        let url = URL(string: Constants.faq)
        Helper.shared.openUrl(url: url)
    }
    
    @IBAction func contactusAction(_ sender: UIButton){
        Helper.shared.log(event: .CONTACTUS, params: [:])
        
        if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setToRecipients(["help@zygoco.com"])
                mail.setSubject("")
                mail.setMessageBody("", isHTML: false)
                
                self.present(mail, animated: true)
                
            //}
        } else {
            Helper.shared.alert(title: Constants.appName, message: "Please configure email account on your device first.")
        }
    }
    
    @IBAction func termsOfUsePressed(_ sender: UIButton){
        Helper.shared.log(event: .TERMOFSERVICE, params: [:])
        let url = URL(string: Constants.termsOfService)
        Helper.shared.openUrl(url: url)
    }
    
    @IBAction func privacyPolicyPressed(_ sender: UIButton){
        Helper.shared.log(event: .PRIVACYPOLICY, params: [:])
        let url = URL(string: Constants.privacyPolicy)
        Helper.shared.openUrl(url: url)
    }
    
    
    //MARK: -

}

extension CustomerSupportVC: MFMailComposeViewControllerDelegate{
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        
        if error != nil{
            Helper.shared.alert(title: Constants.appName, message: error!.localizedDescription)
        }
    }
}
