//
//  SignInViewController.swift
//  Zygo
//
//  Created by Priya Gandhi on 23/01/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit
import AuthenticationServices

class SignInViewController: UIViewController, GoogleLoginManagerDelegate, SignUpViewControllerDelegates {
    
    @IBOutlet weak var viewEmail: UIView!
    @IBOutlet weak var viewPassword: UIView!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    private let viewModel = SignInViewModel()
    
    //MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
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
        signUpVC.delegate = self
        self.navigationController?.pushViewController(signUpVC, animated: true);
    }
    
    func signUpSuccess(email: String, password: String) {
        //Set Auto Fill for login now
        self.txtEmail.text = email
        self.txtPassword.text = password
    }
    
    @IBAction func termsOfUsePressed(_ sender: UIButton){
        let url = URL(string: Constants.termsOfService)
        Helper.shared.openUrl(url: url)
    }
    
    @IBAction func privacyPolicyPressed(_ sender: UIButton){
        let url = URL(string: Constants.privacyPolicy)
        Helper.shared.openUrl(url: url)
    }
    
    @IBAction func appleButtonPressed(_ sender: UIButton){
        self.handleAppleIdRequest()
    }
    
    @IBAction func facebookButtonPressed(_ sender: UIButton){
        FacebookManager.shared.login(from: self) { (error, token) in
            
            if error != nil{
                Helper.shared.alert(title: Constants.appName, message: error!)
                return
            }
            
            if !token.isEmpty{
                self.viewModel.facebookSignInUser(accessToken: token) { [weak self] (isLogin) in
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
    }
    
    @IBAction func googleButtonPressed(_ sender: UIButton){
        GoogleLoginManager.shared.delegate = self
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
                    }else{
                        FacebookManager.shared.logout()
                    }
                }
            }
            
        }
    }
    
    //MARK:- Google SignIn Delegates
    func didLogin(user: GoogleUserDTO) {
        viewModel.googleSignInUser(accessToken: user.accessToken) { [weak self] (isLogin) in
            DispatchQueue.main.async {
                Helper.shared.stopLoading()
                if self == nil{
                    return
                }
                
                if isLogin{
                    AppDelegate.app.checkUserLoginStatus()
                }else{
                    GoogleLoginManager.shared.logout()
                }
            }
        }
    }
    
    func didFaildLogin(error: String) {
    }
}

extension SignInViewController: ASAuthorizationControllerDelegate {
    
    @objc func handleAppleIdRequest() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            DispatchQueue.main.async {
                
                let appleId = "\(appleIDCredential.user)"
                let appleUserFirstName = "\(appleIDCredential.fullName?.givenName ?? "")"
                let appleUserLastName = "\(appleIDCredential.fullName?.familyName ?? "")"
                let appleUserEmail = "\(appleIDCredential.email ?? "")"
                self.viewModel.appleSignInUser(appleID: appleId, uName: appleUserFirstName+appleUserLastName, uEmail: appleUserEmail) { (isError) in
                    AppDelegate.app.checkUserLoginStatus()
                }
            }
            
        }
    }
    
}

extension SignInViewController: ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
