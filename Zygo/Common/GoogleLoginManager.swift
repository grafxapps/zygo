//
//  GoogleLoginManager.swift
//  Zygo
//
//  Created by Priya Gandhi on 24/01/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit
import GoogleSignIn

protocol GoogleLoginManagerDelegate {
    func didLogin(user: GoogleUserDTO)
    func didFaildLogin(error: String)
}
class GoogleLoginManager: NSObject {
    
    static let shared = GoogleLoginManager()
    
    var delegate: GoogleLoginManagerDelegate?
    
    private override init() {
        super.init()
        GIDSignIn.sharedInstance().delegate = self
        
    }
    
    func login(from viewcontroller: UIViewController){
        
        GIDSignIn.sharedInstance()?.presentingViewController = viewcontroller
        
        guard let signIn = GIDSignIn.sharedInstance() else { return }
        if (signIn.hasPreviousSignIn()) {
            signIn.restorePreviousSignIn()
        }
        else{
            GIDSignIn.sharedInstance()?.signIn()
        }
        
    }
    
    func logout(){
        GIDSignIn.sharedInstance()?.signOut()
    }
    
}
extension GoogleLoginManager: GIDSignInDelegate{
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("The user has not signed in before or they have since signed out.")
            } else {
                print("\(error.localizedDescription)")
            }
            
            if let del = self.delegate{
                del.didFaildLogin(error: (error.localizedDescription))
            }
            
            return
        }
        
        if let del = self.delegate{
            del.didLogin(user: GoogleUserDTO(user))
        }
    }
}

struct GoogleUserDTO {
    var userId: String = ""
    var fullName: String = ""
    var givenName: String = ""
    var familyName: String = ""
    var email: String = ""
    var profileImage: String = ""
    var accessToken: String = ""

    
    init(_ user: GIDGoogleUser) {
        self.userId = user.userID ?? ""
        self.fullName = user.profile.name ?? ""
        self.givenName = user.profile.givenName ?? ""
        self.familyName = user.profile.familyName ?? ""
        self.email = user.profile.email ?? ""
        self.accessToken = user.authentication.idToken ?? ""
        self.profileImage = user.profile.imageURL(withDimension: 320)?.absoluteString ?? ""
    }
}
