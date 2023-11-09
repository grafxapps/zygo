//
//  ForgotPasswordViewModel.swift
//  Zygo
//
//  Created by Priya Gandhi on 27/01/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit

class ForgotPasswordViewModel: NSObject {
    
    private let signupService = RegistrationServices()
    
    var email: String = ""
    var OTP: String = ""
    
    func verifyEmail( email: String, completion: @escaping (Bool) -> Void){
        
        if email.isEmpty{
            Helper.shared.alert(title: Constants.appName, message: "Please enter your email address.")
            completion(false)
            return
        }
        
        if !email.isEmailValid(){
            Helper.shared.alert(title: Constants.appName, message: "Please enter a valid email address.")
            completion(false)
            return
        }
        
        self.email = email
        Helper.shared.startLoading()
        self.signupService.verifyEmail(for: email ) { [weak self] (msg, isErr) in
            if self == nil{
                completion(false)
                return
            }
            DispatchQueue.main.async {
                Helper.shared.stopLoading()
                Helper.shared.alert(title: Constants.appName, message: msg) {
                    completion(!isErr)
                }
            }
        }
    }
    
    func forgotPassword(code: String, pass: String, cPass : String, completion: @escaping (Bool) -> Void){
        

        if code.isEmpty{
            completion(false)
            Helper.shared.alert(title: Constants.appName, message: "Please enter reset code.")
            return
        }
        
        if !pass.isValidPasswordLength(){
            Helper.shared.alert(title: Constants.appName, message: "Please enter a valid password.")
            completion(false)
            return
        }
        
        if !(cPass == pass){
            Helper.shared.alert(title: Constants.appName, message: "Password doesn't match.")
            completion(false)
            return
        }
        
        Helper.shared.startLoading()
        self.signupService.forgotPassword(for: code, pass: pass, cPass: cPass) { [weak self] (msg, isErr) in
            if self == nil{
                completion(false)
                return
            }
            
            DispatchQueue.main.async {
                Helper.shared.stopLoading()
                Helper.shared.alert(title: Constants.appName, message: msg) {
                    completion(!isErr)
                }
            }
        }
    }
    
    func updatePassword(oldPassword: String, pass: String, cPass : String, completion: @escaping (Bool) -> Void){
        

        if oldPassword.isEmpty{
            completion(false)
            Helper.shared.alert(title: Constants.appName, message: "Please enter a valid old password.")
            return
        }
        
        if !pass.isValidPasswordLength(){
            Helper.shared.alert(title: Constants.appName, message: "Please enter a valid password.")
            completion(false)
            return
        }
        
        if !(cPass == pass){
            Helper.shared.alert(title: Constants.appName, message: "Password doesn't match.")
            completion(false)
            return
        }
        
        Helper.shared.startLoading()
        self.signupService.updatePassword(for: oldPassword, pass: pass) { [weak self] (msg, isErr) in
            if self == nil{
                completion(false)
                return
            }
            
            DispatchQueue.main.async {
                Helper.shared.stopLoading()
                Helper.shared.alert(title: Constants.appName, message: msg) {
                    completion(!isErr)
                }
            }
        }
    }
    
}
