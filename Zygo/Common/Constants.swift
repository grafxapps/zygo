//
//  Constants.swift
//  Zygo
//
//  Created by Priya Gandhi on 23/01/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit

class Constants: NSObject {
    
    static let appName = "Zygo"
    static let loaderSize = CGSize.init(width: 30, height: 30)
    
    static let baseUrl = "http://34.238.115.129"
    static let imageBaseUrl = "http://34.238.115.129/public"
    static let deviceType = "ios"
    
    static let internetNotWorking = "Please check your internet connection."
    static let internalServerError = "Internal server error. Please try again."
    
    
}
struct ScreenSize {
    static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}
enum APIEndPoint : String {
    
    case signUp = "/api/auth/user-register"
    case signIn = "/api/auth/user-login"
    case googleSignIn = "/api/auth/google-login"
    case facebookSignIn = "/api/auth/facebook-login"

    case resendVerificationEmail = "/api/auth/resend-verification-email"
    case verifyEmail = "/api/auth/password/create"
    case forgotpassword = "/api/auth/password/reset"
    
    case updateProfile = "/api/update-profile"
}

enum AppKeys : String {
    case details = "details"
    case message = "message"
    case accessToken = "access_token"
    case isEmailVerified = "is_email_verified"
    case status = "status"
}

enum HTTPStatusCode : Int {
    case Ok = 200
    case Created = 201
    case BadRequest = 400
    case Unauthorized = 401
    case Forbidden = 403
    case NotFound = 404
    case RequestTimeOut = 408
    case InternalServerError = 500
    case BadGateway = 502
    case ServiceUnavailable = 503
    case Cancelled = -999
}

