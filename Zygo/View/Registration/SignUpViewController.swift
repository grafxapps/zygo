//
//  SignUpViewController.swift
//  Zygo
//
//  Created by Priya Gandhi on 23/01/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit
import AuthenticationServices

protocol SignUpViewControllerDelegates {
    func signUpSuccess(email: String, password: String)
}

class SignUpViewController: UIViewController, GoogleLoginManagerDelegate {
    
    @IBOutlet weak var viewEmail: UIView!
    @IBOutlet weak var viewPassword: UIView!
    @IBOutlet weak var viewName: UIView!
    
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    var delegate: SignUpViewControllerDelegates?
    
    private let viewModel = SignUpViewModel()
    private let sviewModel = SignInViewModel()
    
    //MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
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
                self.sviewModel.facebookSignInUser(accessToken: token) { [weak self] (isLogin) in
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
    }
    
    @IBAction func googleButtonPressed(_ sender: UIButton){
        GoogleLoginManager.shared.delegate = self
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
                        self?.delegate?.signUpSuccess(email: self?.viewModel.userItem.email ?? "", password: self?.viewModel.userItem.password ?? "")
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
    //MARK:- Google SignIn Delegates
    func didLogin(user: GoogleUserDTO) {
        sviewModel.googleSignInUser(accessToken: user.accessToken) { [weak self] (isLogin) in
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

extension SignUpViewController: ASAuthorizationControllerDelegate {
    
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
                self.sviewModel.appleSignInUser(appleID: appleId, uName: appleUserFirstName+appleUserLastName, uEmail: appleUserEmail) { (isError) in
                    AppDelegate.app.checkUserLoginStatus()
                }
            }
            
        }
    }
    
}

extension SignUpViewController: ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
