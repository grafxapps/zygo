//
//  SignUpViewModel.swift
//  Zygo
//
//  Created by Priya Gandhi on 23/01/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit

final class SignUpViewModel: NSObject {
    
    private let signupService = RegistrationServices()
    
    var userItem = SignUpUserDTO()
    
    func isValidate() -> Bool{
        if userItem.name.isEmpty{
            Helper.shared.alert(title: Constants.appName, message: NSLocalizedString("Please enter your name.", comment: ""))
            return false
        }else if userItem.email.isEmpty{
            Helper.shared.alert(title: Constants.appName, message: "Please enter your email address.")
            return false
        }else if !userItem.email.isEmailValid(){
            Helper.shared.alert(title: Constants.appName, message: "Please enter valid email address.")
            return false
        }else if userItem.password.isEmpty{
            Helper.shared.alert(title: Constants.appName, message: NSLocalizedString("Please enter your password.", comment: ""))
            return false
        }else if !userItem.password.isValidPasswordLength(){
            Helper.shared.alert(title: Constants.appName, message: NSLocalizedString("Password must be atleast 6 digits long", comment: ""))
            return false
        }
        
        return true
    }
    
    
    func signUpUser(completion: @escaping (Bool) -> Void){
        Helper.shared.startLoading()
        
        self.signupService.signUp(user: self.userItem) { [weak self] (msg,error) in
            if self == nil{
                completion(false)
                return
            }
            
            DispatchQueue.main.async {
                Helper.shared.stopLoading()
                Helper.shared.alert(title: Constants.appName, message: msg) {
                    completion(!error)
                }
            }
        }
    }
    
}

struct SignUpUserDTO {
    var name: String = ""
    var email: String = ""
    var password: String = ""
    var code : String = ""
    var cPass : String = ""
}
