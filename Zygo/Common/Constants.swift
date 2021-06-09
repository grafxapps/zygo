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
    
    //TODO: Check
    //Development v2
    //static let baseUrl = "http://dev.zygohq.com"
    //static let imageBaseUrl = "http://dev.zygohq.com"
    
    //Live mirror
    //static let baseUrl = "https://mirror.zygohq.com"
    //static let imageBaseUrl = "https://mirror.zygohq.com"
    
    //Live
    static let baseUrl = "https://zygohq.com"
    static let imageBaseUrl = "https://zygohq.com"
    
    
    static let deviceType = "ios"
        
    static let privacyPolicy =  "https://zygohq.com/privacy-app-view"
    static let termsOfService = "https://zygohq.com/terms-app-view"
    static let about = "https://shopzygo.com/pages/technology"//"https://zygohq.com/about-app-view"
    static let shop = "https://shopzygo.com/collections/shop"
    static let cancelSubscription = "https://apps.apple.com/account/subscriptions"
    
    static let googleClientId: String = "519312259857-k44ddcd1gkh5q2ocd5s68dts3tpqhbfr.apps.googleusercontent.com"
    static let googleServerId: String = "519312259857-99ltid9etpuboqm8vvqu1ndsloirm9o5.apps.googleusercontent.com"
    
    static let appLink: String = "https://apps.apple.com/us/app/zygo/id1564866603"
    
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
    case changePassword = "/api/change-password"
    case appleSignIn = "/api/auth/apple-login"
    case getProfile = "/api/get-profile"
    
    case updateProfile = "/api/update-profile"
    case getWorkouts = "/api/get-workouts"
    case getWorkoutById = "/api/get-workout-by-id"
    case getWorkoutFilters = "/api/get-workout-filter"
    case completeWorkout = "/api/workout-complete"
    case workoutFeedback = "/api/workout-feedback"
    
    case userHistory = "/api/user-history"
    
    case getWorkoutsSeries = "/api/get-series"
    
    case subscriptionPayment = "/api/apple-subscription-payment"
    case cancelSubscription = "/api/cancel-apple-subscription"
    
    case updateToken = "/api/update-device-token"
    case notificationSetting = "/api/notification-setting"
    
    case forceUpgrade = "/api/force-upgrade"
}

enum AppKeys : String {
    case data = "data"
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


extension Bundle {

    var appName: String {
        return infoDictionary?["CFBundleName"] as! String
    }

    var bundleId: String {
        return bundleIdentifier!
    }

    var versionNumber: String {
        return infoDictionary?["CFBundleShortVersionString"] as! String
    }

    var buildNumber: String {
        return infoDictionary?["CFBundleVersion"] as! String
    }

}
