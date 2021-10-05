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
    }
    
    func login(from viewcontroller: UIViewController){
        
        let config = GIDConfiguration(clientID: Constants.googleClientId, serverClientID: Constants.googleServerId)
        
        GIDSignIn.sharedInstance.signIn(with: config, presenting: viewcontroller) { (user, error) in
            if let error = error{
                if let del = self.delegate{
                    del.didFaildLogin(error: (error.localizedDescription))
                }
                return
            }
            
            if user != nil{
                if let del = self.delegate{
                    DispatchQueue.main.async {
                        del.didLogin(user: GoogleUserDTO(user!))
                    }
                }
            }else{
                if let del = self.delegate{
                    del.didFaildLogin(error: "Internal server error. Please try again.")
                }
            }
            
        }
    }
    
    func logout(){
        GIDSignIn.sharedInstance.signOut()
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
        self.fullName = user.profile?.name ?? ""
        self.givenName = user.profile?.givenName ?? ""
        self.familyName = user.profile?.familyName ?? ""
        self.email = user.profile?.email ?? ""
        self.accessToken = user.authentication.idToken ?? ""
        self.profileImage = user.profile?.imageURL(withDimension: 320)?.absoluteString ?? ""
    }
}
