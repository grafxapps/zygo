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
    
    func login(from viewcontroller: UIViewController, completion: @escaping (String?, FBUserDTO?) -> Void){
        let fbLoginManager : LoginManager = LoginManager()
        fbLoginManager.logIn(permissions: ["public_profile","email"], from: viewcontroller) { (result, error) -> Void in
            if error != nil {
                completion(error!.localizedDescription, nil)
                viewcontroller.dismiss(animated: true, completion: nil)
            } else if result!.isCancelled {
                completion("Cancelled", nil)
                viewcontroller.dismiss(animated: true, completion: nil)
            } else {
                GraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(normal), email"]).start(completionHandler: { (connection, result, error) -> Void in
                    if (error == nil){
                        let fbDetails = result as! [String:Any]
                    
                        completion(nil,FBUserDTO(fbDetails))
                    }
                })
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
