//
//  SignUpViewController.swift
//  Zygo
//
//  Created by Priya Gandhi on 23/01/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, GoogleLoginManagerDelegate {
    @IBOutlet weak var viewEmail: UIView!
    @IBOutlet weak var viewPassword: UIView!
    @IBOutlet weak var viewName: UIView!
    
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    private let viewModel = SignUpViewModel()
    private let sviewModel = SignInViewModel()

    //MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        GoogleLoginManager.shared.delegate = self;

        setupUI()
    }
    
    //MARK:- Setup
    func setupUI()  {
        Helper.shared.setupViewLayer(sender: self.viewName,isSsubScriptionView: false);
        Helper.shared.setupViewLayer(sender: self.viewEmail, isSsubScriptionView: false);
        Helper.shared.setupViewLayer(sender: self.viewPassword, isSsubScriptionView: false);
        
    }
    //MARK:- UIButton Action
    @IBAction func signInPressed(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func termsOfUsePressed(_ sender: UIButton){
    }
    
    @IBAction func privacyPolicyPressed(_ sender: UIButton){
    }
    
    @IBAction func appleButtonPressed(_ sender: UIButton){
    }
    
    @IBAction func facebookButtonPressed(_ sender: UIButton){
        FacebookManager.shared.login(from: self) { (msg, fbObj) in
            self.sviewModel.facebookSignInUser(accessToken: fbObj?.userId ?? "") { (isErr) in
                
            }
        }
    }
    
    @IBAction func googleButtonPressed(_ sender: UIButton){
        GoogleLoginManager.shared.login(from: self)
        
    }
    
    
    @IBAction func signupPressed(_ sender: UIButton){
        
        self.viewModel.userItem.name = self.txtName.text!.trimm()
        self.viewModel.userItem.email = self.txtEmail.text!.trimm().lowercased()
        self.viewModel.userItem.password = self.txtPassword.text!.trimm()
        
        self.txtName.resignFirstResponder()
        self.txtEmail.resignFirstResponder()
        self.txtPassword.resignFirstResponder()
        
        if self.viewModel.isValidate(){
            
            self.viewModel.signUpUser() { [weak self] (isSignUp) in
                DispatchQueue.main.async {
                    if self == nil{
                        return
                    }
                    if isSignUp{
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
    //MARK:- Google SignIn Delegates
    func didLogin(user: GoogleUserDTO) {
        sviewModel.googleSignInUser(accessToken: user.accessToken) { (isError) in
            AppDelegate.app.checkUserLoginStatus()
        }
    }
    
    func didFaildLogin(error: String) {
    }
}
