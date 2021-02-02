//
//  SignInViewController.swift
//  Zygo
//
//  Created by Priya Gandhi on 23/01/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController, GoogleLoginManagerDelegate {
        
    @IBOutlet weak var viewEmail: UIView!
    @IBOutlet weak var viewPassword: UIView!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    private let viewModel = SignInViewModel()
    
    //MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        GoogleLoginManager.shared.delegate = self;
        self.setupUI()
        
    }
    //MARK:- Setup
    func setupUI()  {
        Helper.shared.setupViewLayer(sender: self.viewEmail, isSsubScriptionView: false);
        Helper.shared.setupViewLayer(sender: self.viewPassword, isSsubScriptionView: false);
    }
    
    //MARK:- UIButton Actions
    @IBAction func signUpPressed(_ sender: UIButton){
        let signUpVC = self.storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        self.navigationController?.pushViewController(signUpVC, animated: true);
    }
    
    @IBAction func termsOfUsePressed(_ sender: UIButton){
    }
    
    @IBAction func privacyPolicyPressed(_ sender: UIButton){
    }
    
    @IBAction func appleButtonPressed(_ sender: UIButton){
    }
    
    @IBAction func facebookButtonPressed(_ sender: UIButton){
        FacebookManager.shared.login(from: self) { (msg, fbObj) in
            self.viewModel.facebookSignInUser(accessToken: fbObj?.userId ?? "") { (isErr) in
                
            }
        }
    }
    
    @IBAction func googleButtonPressed(_ sender: UIButton){
        GoogleLoginManager.shared.login(from: self)
        
    }
    
    @IBAction func forgotButtonPressed(_ sender: UIButton){
        let forgotPassVC = self.storyboard?.instantiateViewController(withIdentifier: "VerifyForgotPasswordViewController") as! VerifyForgotPasswordViewController
        self.navigationController?.pushViewController(forgotPassVC, animated: true);
    }
    
    @IBAction func signuInPressed(_ sender: UIButton){
        
        self.viewModel.userItem.email = self.txtEmail.text!.trimm().lowercased()
        self.viewModel.userItem.password = self.txtPassword.text!.trimm()
        
        self.txtEmail.resignFirstResponder()
        self.txtPassword.resignFirstResponder()
        
        if self.viewModel.isValidate(){
            
            self.viewModel.signInUser() { [weak self] (isLogin) in
                DispatchQueue.main.async {
                    Helper.shared.stopLoading()
                    if self == nil{
                        return
                    }
                    
                    if isLogin{
                        AppDelegate.app.checkUserLoginStatus()
                    }
                }
            }
            
        }
    }
    //MARK:- Google SignIn Delegates
    func didLogin(user: GoogleUserDTO) {
        viewModel.googleSignInUser(accessToken: user.accessToken) { (isError) in
            AppDelegate.app.checkUserLoginStatus()
        }
    }
    
    func didFaildLogin(error: String) {
    }
}
