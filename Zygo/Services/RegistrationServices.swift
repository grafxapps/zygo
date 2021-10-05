//
//  RegistrationServices.swift
//  Zygo
//
//  Created by Priya Gandhi on 23/01/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit

final class RegistrationServices: NSObject {
    
    func signUp(user: SignUpUserDTO, completion: @escaping (String, Bool) -> Void){
        let param = [
            "user_display_name": user.name,
            "email": user.email,
            "password": user.password,
        ] as [String : Any]
        
        NetworkManager.shared.request(withEndPoint: .signUp, method: .post, headers: nil, params: param) { (response) in
            
            switch response{
            case .success(let jsonResponse):
                guard let responseDict = jsonResponse["message"] as? String else {
                    completion(Constants.internalServerError, true)
                    return
                }
                completion(responseDict,false)
            case .failure(_, let message):
                print(message)
                completion(message, true)
            case .notConnectedToInternet:
                print(Constants.internetNotWorking)
                completion(Constants.internetNotWorking, true)
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (_ error: String?,_ isEmailVerified: Bool, [String: Any]) -> Void){
        let param = [
            "email": email,
            "password": password,
            "device_id": Helper.shared.deviceId,
            "device_type": Constants.deviceType,
            "device_token": PreferenceManager.shared.deviceToken,
            
        ] as [String : Any]
        
        NetworkManager.shared.request(withEndPoint: .signIn, method: .post, headers: nil, params: param) { (response) in
            
            switch response{
            case .success(let jsonResponse):
                
                let isEmailVerified = NSNumber(value: (jsonResponse[AppKeys.isEmailVerified.rawValue] as? Int ?? 1)).boolValue
                
                let responseDict = jsonResponse[AppKeys.details.rawValue] as? [String:Any] ?? [:]
                
                let userToken = jsonResponse[AppKeys.accessToken.rawValue] as? String ?? ""
                PreferenceManager.shared.authToken = userToken
                completion(nil, isEmailVerified,responseDict)
            case .failure(_, let message):
                print(message)
                completion(message,true,[:])
            case .notConnectedToInternet:
                print(Constants.internetNotWorking)
                completion(Constants.internetNotWorking,true,[:])
            }
        }
    }
    
    func appleSignIn(appleID: String, uName: String, uEmail: String, completion: @escaping (_ error: String?,_ isEmailVerified: Bool, [String: Any]) -> Void){
        
        let param = [
            "device_type": Constants.deviceType,
            "login_type": LoginType.apple.rawValue,
            "device_id": Helper.shared.deviceId,
            "device_token": PreferenceManager.shared.deviceToken,
            "apple_id": appleID,
            "user_first_name": uName,
            "user_display_name": uName,
            "email": uEmail,

           
        ] as [String : Any]
        
        NetworkManager.shared.request(withEndPoint: .appleSignIn, method: .post, headers: nil, params: param) { (response) in
            
            switch response{
            case .success(let jsonResponse):
                
                let isEmailVerified = NSNumber(value: (jsonResponse[AppKeys.isEmailVerified.rawValue] as? Int ?? 1)).boolValue
                
                let responseDict = jsonResponse[AppKeys.details.rawValue] as? [String:Any] ?? [:]
                
                let userToken = jsonResponse[AppKeys.accessToken.rawValue] as? String ?? ""
                PreferenceManager.shared.authToken = userToken
                completion(nil, isEmailVerified,responseDict)
            case .failure(_, let message):
                print(message)
                completion(message,true,[:])
            case .notConnectedToInternet:
                print(Constants.internetNotWorking)
                completion(Constants.internetNotWorking,true,[:])
            }
        }
    }
    
    func resendVerificationLink(for email: String, completion: @escaping (String?) -> Void){
        
        let params : [String : Any] = [
            "email": email,
        ]
        
        NetworkManager.shared.request(withEndPoint: .resendVerificationEmail, method: .get, headers: nil, params: params) { (response) in
            switch response{
            case .success( _):
                completion(nil)
            case .failure(_ , let message):
                completion(message)
            case .notConnectedToInternet:
                completion(Constants.internetNotWorking)
            }
        }
    }
    
    func verifyEmail(for email: String, completion: @escaping (String, Bool) -> Void){
        let params : [String : Any] = [
            "email": email,
        ]
        NetworkManager.shared.request(withEndPoint: .verifyEmail, method: .post, headers: nil, params: params) { (response) in
            switch response{
            case .success( let jsonResponse):
                
                /*guard let userToken = jsonResponse["otp"] as? String else {
                 completion(Constants.internalServerError, true)
                 return
                 }*/
                
                guard let msg = jsonResponse["message"] as? String else {
                    completion("We sent you an email.", false)
                    return
                }
                
                completion(msg,false)
            case .failure(_ , let message):
                completion(message,true)
            case .notConnectedToInternet:
                completion(Constants.internetNotWorking,true)
            }
        }
    }
    
    func forgotPassword(for code: String, pass: String, cPass: String, completion: @escaping (String, Bool) -> Void){
        let params : [String : Any] = [
            "otp": code,
            "password": pass,
            "password_confirmation": cPass
        ]
        NetworkManager.shared.request(withEndPoint: .forgotpassword, method: .post, headers: nil, params: params) { (response) in
            switch response{
            case .success( let jsonResponse):
                
                guard let msg = jsonResponse["message"] as? String else {
                    completion("Password was updated successfully.",false)
                    return
                }
                completion(msg,false)
            case .failure(_ , let message):
                completion(message,true)
            case .notConnectedToInternet:
                completion(Constants.internetNotWorking,true)
            }
        }
    }
    
    func updatePassword(for oldPassword: String, pass: String, completion: @escaping (String, Bool) -> Void){
        let params : [String : Any] = [
            "old_password": oldPassword,
            "new_passowrd": pass
        ]
        
        let header = NetworkManager.shared.getHeader()
        
        NetworkManager.shared.request(withEndPoint: .changePassword, method: .post, headers: header, params: params) { (response) in
            switch response{
            case .success( let jsonResponse):
                
                guard let msg = jsonResponse["message"] as? String else {
                    completion("Password was updated successfully.",false)
                    return
                }
                completion(msg,false)
            case .failure(_ , let message):
                completion(message,true)
            case .notConnectedToInternet:
                completion(Constants.internetNotWorking,true)
            }
        }
    }
    
    var accToken: String = ""
    func googleSignIn(accessToken: String, completion: @escaping (_ error: String?,_ isEmailVerified: Bool, [String: Any]) -> Void){
        self.accToken = String(format: "%@", accessToken)
        let param = [
            "device_type": Constants.deviceType,
            "login_type": LoginType.google.rawValue,
            "device_id": Helper.shared.deviceId,
            "device_token": PreferenceManager.shared.deviceToken,
            "access_token": accessToken,
            
        ] as [String : String]
        print("Gmail: \(param)")
        
        NetworkManager.shared.request(withEndPoint: .googleSignIn, method: .post, headers: [:], params: param) { (response) in
            
            switch response{
            case .success(let jsonResponse):
                
                let isEmailVerified = NSNumber(value: (jsonResponse[AppKeys.isEmailVerified.rawValue] as? Int ?? 1)).boolValue
                
                let responseDict = jsonResponse[AppKeys.details.rawValue] as? [String:Any] ?? [:]
                
                let userToken = jsonResponse[AppKeys.accessToken.rawValue] as? String ?? ""
                PreferenceManager.shared.authToken = userToken
                completion(nil, isEmailVerified,responseDict)
            case .failure(_, let message):
                print(message)
                completion(message,true,[:])
            case .notConnectedToInternet:
                print(Constants.internetNotWorking)
                completion(Constants.internetNotWorking,true,[:])
            }
        }
    }
    
    func facebookSignIn(accessToken: String, completion: @escaping (_ error: String?,_ isEmailVerified: Bool, [String: Any]) -> Void){

        let param = [
            "device_type": Constants.deviceType,
            "login_type": LoginType.facebook.rawValue,
            "device_id": Helper.shared.deviceId,
            "device_token": PreferenceManager.shared.deviceToken,
            "access_token": accessToken,
            
        ] as [String : Any]
        
        NetworkManager.shared.request(withEndPoint: .facebookSignIn, method: .post, headers: nil, params: param) { (response) in
            
            switch response{
            case .success(let jsonResponse):
                
                let isEmailVerified = NSNumber(value: (jsonResponse[AppKeys.isEmailVerified.rawValue] as? Int ?? 1)).boolValue
                
                let responseDict = jsonResponse[AppKeys.details.rawValue] as? [String:Any] ?? [:]
                
                let userToken = jsonResponse[AppKeys.accessToken.rawValue] as? String ?? ""
                PreferenceManager.shared.authToken = userToken
                completion(nil, isEmailVerified,responseDict)
            case .failure(_, let message):
                print(message)
                completion(message,true,[:])
            case .notConnectedToInternet:
                print(Constants.internetNotWorking)
                completion(Constants.internetNotWorking,true,[:])
            }
        }
    }
    
    func updateDeviceToken(deviceToken : String, completion: @escaping (String, Bool) -> Void){
        let header = NetworkManager.shared.getHeader()

        let param = [
            "device_token": deviceToken,
            "device_last_authentication": DateHelper.shared.currentUTCDateTime.timeIntervalSince1970,
            "app_version_last_authentication": Bundle.main.versionNumber,
            "device_type": "iOS"
        ] as [String : Any]
        
        NetworkManager.shared.request(withEndPoint: .updateToken, method: .post, headers: header, params: param) { (response) in
            
            switch response{
            case .success(let jsonResponse):
                guard let responseDict = jsonResponse["message"] as? String else {
                    completion(Constants.internalServerError, true)
                    return
                }
                completion(responseDict,false)
            case .failure(_, let message):
                print(message)
                completion(message, true)
            case .notConnectedToInternet:
                print(Constants.internetNotWorking)
                completion(Constants.internetNotWorking, true)
            }
        }
    }
}

