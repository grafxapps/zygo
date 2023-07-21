//
//  FacebookManager.swift
//  Zygo
//
//  Created by Priya Gandhi on 24/01/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
class FacebookManager: NSObject {
    static let shared = FacebookManager()
    
    func login(from viewcontroller: UIViewController, completion: @escaping (String?, String) -> Void){
        let fbLoginManager : LoginManager = LoginManager()
        fbLoginManager.logIn(permissions: [ .publicProfile, .email ], viewController: viewcontroller) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
                viewcontroller.dismiss(animated: true) {
                    completion(error.localizedDescription, "")
                }
            case .cancelled:
                print("User cancelled login.")
                viewcontroller.dismiss(animated: true) {
                    completion("User cancelled login.", "")
                }
            case .success(_ , _, let accessToken):
                viewcontroller.dismiss(animated: true) {
                    completion(nil,accessToken.tokenString)
                }
                break
            }
        }
        
    }
    
    func logout(){
        LoginManager().logOut()
    }
}
struct FBUserDTO {
    var userId: String = ""
    var name: String = ""
    var email: String = ""
    var profileImage: String = ""
    
    init(_ user: [String:Any]) {
        
        self.name = user["name"] as? String ?? ""
        self.email = user["email"] as? String ?? ""
        self.userId = user["id"] as? String ?? ""
        
        if  let resData = user["picture"]{
            if  let resPic = (resData as AnyObject).value(forKey: "data"){
                self.profileImage = (resPic as AnyObject).value(forKey: "url") as? String ?? ""
            }
        }
    }
}
