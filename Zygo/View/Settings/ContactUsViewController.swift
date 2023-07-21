//
//  ContactUsViewController.swift
//  Zygo
//
//  Created by Som on 18/06/22.
//  Copyright © 2022 Somparkash. All rights reserved.
//

import UIKit
import MessageUI

//MARK: -
class ContactUsViewController: UIViewController {
    
    @IBOutlet weak var lblLiveTime: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblEmailTime: UILabel!
    @IBOutlet weak var lblPhone: UILabel!
    @IBOutlet weak var lblPhoneTime: UILabel!
    
    @IBOutlet weak var contentHideView: UIView!
    
    var phone: String = "+13233800902"
    var email: String = "help@zygoco.com"
    var chatURL: String = ""
    
    private let service = UserServices()
    
    //MARK: - UIViewcontroller LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.contentHideView.isHidden = false
        self.setupData()
    }
    
    //MARK: - Setups
    func setupData(){
        self.getContactUSDetail()
    }
    
    //MARK: - UIButton Actions
    @IBAction func backAction(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func liveChatAction(_ sender: UIButton){
        Helper.shared.openUrl(url: URL(string: self.chatURL))
    }
    
    @IBAction func emailAction(_ sender: UIButton){
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([self.email])
            mail.setSubject("")
            mail.setMessageBody("", isHTML: false)
            
            self.present(mail, animated: true)
            
            //}
        } else {
            Helper.shared.alert(title: Constants.appName, message: "Please configure email account on your device first.")
        }
    }
    
    @IBAction func phoneAction(_ sender: UIButton){
        
        guard let url = URL(string: "tel://\(self.phone)") else{
            return
        }
        
        Helper.shared.openUrl(url: url)
    }
    
    //MARK: -
}

//MARK: - Network
extension ContactUsViewController{
    
    func getContactUSDetail(){
        Helper.shared.startLoading()
        self.service.getContactUsDetail { (error, detailDict) in
        
            DispatchQueue.main.async {
                Helper.shared.stopLoading()
                
                if error != nil{
                    return
                }
                
                let liveTime = detailDict["live_time"] as? String ?? ""
                self.lblLiveTime.attributedText = liveTime.htmlToAttributedString
                
                self.chatURL = detailDict["chat_url"] as? String ?? ""
                
                let emailTime = detailDict["email_time"] as? String ?? ""
                self.lblEmailTime.attributedText = emailTime.htmlToAttributedString
                
                self.email = detailDict["email"] as? String ?? ""
                let callTime = detailDict["call_time"] as? String ?? ""
                self.lblPhoneTime.attributedText = callTime.htmlToAttributedString
                
                let callPhone = detailDict["call_phone"] as? String ?? ""
                self.lblPhone.text = callPhone
                self.phone = callPhone.replacingOccurrences(of: "-", with: "")
                
                self.contentHideView.alpha = 1.0
                UIView.animate(withDuration: 0.4) {
                    self.contentHideView.alpha = 0.0
                } completion: { complete in
                    self.contentHideView.isHidden = true
                }
                
            }
        }
    }
    
}

extension ContactUsViewController: MFMailComposeViewControllerDelegate{
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        
        if error != nil{
            Helper.shared.alert(title: Constants.appName, message: error!.localizedDescription)
        }
    }
}
