//
//  ForgotpasswordViewController.swift
//  Zygo
//
//  Created by Priya Gandhi on 27/01/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit

class ForgotpasswordViewController: UIViewController {
    @IBOutlet weak var viewCode: UIView!
    @IBOutlet weak var viewPassword: UIView!
    @IBOutlet weak var viewCPassword: UIView!
    
    @IBOutlet weak var txtCode: UITextField!
    @IBOutlet weak var txtCPassword: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    @IBOutlet weak var btnShowPassword: UIButton!
    @IBOutlet weak var btnShowCPassword: UIButton!
    
    var viewModel: ForgotPasswordViewModel!
    
    //MARK:-Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    //MARK:- Setup
    func setupUI()  {
        Helper.shared.setupViewLayer(sender: self.viewCode,isSsubScriptionView: false);
        Helper.shared.setupViewLayer(sender: self.viewPassword, isSsubScriptionView: false);
        Helper.shared.setupViewLayer(sender: self.viewCPassword, isSsubScriptionView: false);
    }
    
    //MARK:- UIButton Actions
   
    @IBAction func showPassword(_ sender: UIButton){
        if(btnShowPassword.isSelected){
            btnShowPassword.isSelected = false
            txtPassword.isSecureTextEntry = true
        }else{
            btnShowPassword.isSelected = true
            txtPassword.isSecureTextEntry = false
        }
    }
   
    @IBAction func showCPassword(_ sender: UIButton){
        if(btnShowCPassword.isSelected){
            btnShowCPassword.isSelected = false
            txtCPassword.isSecureTextEntry = true
        }else{
            btnShowCPassword.isSelected = true
            txtCPassword.isSecureTextEntry = false
        }
    }
    
    @IBAction func updateBtnAction(sender : UIButton){
        
        let code = self.txtCode.text!.trimm()
        let pass = self.txtPassword.text!.trimm()
        let confirmPass = self.txtCPassword.text!.trimm()
        
        self.txtCode.resignFirstResponder()
        self.txtPassword.resignFirstResponder()
        self.txtCPassword.resignFirstResponder()
        
        viewModel.forgotPassword(code: code, pass: pass, cPass: confirmPass) { [weak self] (isUpdated) in
            
            Helper.shared.log(event: .FORGOTPASSWORD, params: [:])
            
            if isUpdated{
                self?.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    @IBAction func resendBtnAction(sender : UIButton){
        viewModel.verifyEmail(email: self.viewModel.email, completion: { (isVerify) in
            
        })
    }
    
    @IBAction func back(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
}
