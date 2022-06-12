//
//  ChangePasswordVC.swift
//  Zygo
//
//  Created by Som on 08/03/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit

class ChangePasswordVC: UIViewController {
    @IBOutlet weak var viewOldPassword: UIView!
    @IBOutlet weak var viewPassword: UIView!
    @IBOutlet weak var viewCPassword: UIView!
    
    @IBOutlet weak var txtOldPassword: UITextField!
    @IBOutlet weak var txtCPassword: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    @IBOutlet weak var btnShowPassword: UIButton!
    @IBOutlet weak var btnShowCPassword: UIButton!
    
    var viewModel = ForgotPasswordViewModel()
    
    //MARK:-Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    //MARK:- Setup
    func setupUI()  {
        Helper.shared.setupViewLayer(sender: self.viewOldPassword,isSsubScriptionView: false);
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
        
        let oldPassword = self.txtOldPassword.text!.trimm()
        let pass = self.txtPassword.text!.trimm()
        let confirmPass = self.txtCPassword.text!.trimm()
        
        self.txtOldPassword.resignFirstResponder()
        self.txtPassword.resignFirstResponder()
        self.txtCPassword.resignFirstResponder()
        
        viewModel.updatePassword(oldPassword: oldPassword, pass: pass, cPass: confirmPass) { [weak self] (isUpdated) in
            if isUpdated{
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func back(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
}
