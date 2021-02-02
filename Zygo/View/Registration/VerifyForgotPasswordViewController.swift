//
//  VerifyForgotPasswordViewController.swift
//  Zygo
//
//  Created by Priya Gandhi on 27/01/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit

class VerifyForgotPasswordViewController: UIViewController {
    @IBOutlet weak var viewEmail: UIView!
    @IBOutlet weak var txtEmail: UITextField!
    private let viewModel = ForgotPasswordViewModel()
    
    //MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    //MARK:- Setup
    func setupUI()  {
        Helper.shared.setupViewLayer(sender: self.viewEmail,isSsubScriptionView: false);
    }
    
    //MARK:- UIButton Action
    @IBAction func submitAction (sender: UIButton){
        let email = self.txtEmail.text!.trimm()
        
        self.txtEmail.resignFirstResponder()
        
        viewModel.verifyEmail(email: email) { (isVerify) in
            if isVerify{
                let forgotPassVC = self.storyboard?.instantiateViewController(withIdentifier: "ForgotpasswordViewController") as! ForgotpasswordViewController
                forgotPassVC.viewModel = self.viewModel
                self.navigationController?.pushViewController(forgotPassVC, animated: true);
            }
        }
    }
    
    @IBAction func back(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
}














