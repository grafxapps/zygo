//
//  Constants.swift
//  Zygo
//
//  Created by Priya Gandhi on 23/01/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit

let environment: AppEnvironment = .production

class Constants: NSObject {
    
    static let appName = "Zygo"
    static let loaderSize = CGSize.init(width: 30, height: 30)
    
    //TODO: Check
    static var baseUrl: String{
        switch environment {
        case .production:
            return "https://zygohq.com"
        case .staging:
            return "https://mirror.zygohq.com"
        }
    }
    
    static var imageBaseUrl: String{
        switch environment {
        case .production:
            return "https://zygohq.com"
        case .staging:
            return "https://mirror.zygohq.com"
        }
    }
    
    static var BLEBatchID: String{
        switch environment {
        case .production:
            return "1"
        case .staging:
            return "3"
        }
    }
    
    static var BLEZ2BatchID: String{
        switch environment {
        case .production:
            return "3"
        case .staging:
            return "7"
        }
    }
    
    static let branchKey = "key_live_gi2tjo1v3wnXldXjFkmrXgocxzhIHcj4"
    static let KLAVIYOPUBLICAPIKEY = "P2bQKn"
    
    static let deviceType = "ios"
        
    static let privacyPolicy =  "https://zygohq.com/privacy-app-view"
    static let termsOfService = "https://zygohq.com/terms-app-view"
    static let faq = "https://shopzygo.com/pages/faq"
    static let about = "https://shopzygo.com/pages/technology"
    static let shop = "https://shopzygo.com/collections/shop"
    static let cancelSubscription = "https://apps.apple.com/account/subscriptions"
    
    static let googleClientId: String = "519312259857-k44ddcd1gkh5q2ocd5s68dts3tpqhbfr.apps.googleusercontent.com"
    static let googleServerId: String = "519312259857-99ltid9etpuboqm8vvqu1ndsloirm9o5.apps.googleusercontent.com"
    
    static let appLink: String = "https://apps.apple.com/us/app/zygo/id1564866603"
    
    static let internetNotWorking = "Please check your internet connection."
    static let internalServerError = "Internal server error. Please try again."
    static let ACCEPTABLE_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
}

struct ScreenSize {
    static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

enum AppKeys : String {
    case data = "data"
    case details = "details"
    case message = "message"
    case accessToken = "access_token"
    case isEmailVerified = "is_email_verified"
    case status = "status"
}

enum EventName: String{
    
    case FBLOGIN = "Fb_login"
    case APPLELOGIN = "Apple_login"
    case SIGNIN = "Signin"
    case GOOGLELOGIN = "Google_login"
    case FBSIGNUP = "Fb_signup"
    case GOOGLESIGNUP = "Google__signup"
    case SIGNUP = "Signup"
    case FORGOTPASSWORD = "Forgot_password"
    case CREATEPROFILE = "Create_profile"
    case CHOOSEIMAGE = "Choose_image"
    case RESENDRESETCODE = "Resend_reset_code"
    case TABWORKOUTS = "Tab_workouts"
    case TABSERIES = "Tab_series"
    case TABDOWNLOADS = "Tab_downloads"
    case TABPACING = "Tab_Pacing"
    case TABPROFILE = "Tab_profile"
    case DOWNLOADWORKOUT = "Download_workout"
    case WORKOUTSTART = "Workout_start"
    case WORKOUTCANCEL = "Workout_cancel"
    case INSTRUCTORPROFILE = "Instructor_profile"
    case ENDWORKOUT = "End_workout"
    case WORKOUTFEEDBACK = "Workout_feedback"
    case TEMPOTRAINERSTART = "Tempo_trainer_Start"
    case TEMPOTRAINERSTOP = "Tempo_trainer_Stop"
    case SAVEPROFILE = "Save_profile"
    case ABOUTUS = "About_us"
    case TERMOFSERVICE = "Term_of_service"
    case FAQ = "faq"
    case CONTACTUS = "Contact_Us"
    case PRIVACYPOLICY = "PRIVACY_POLICY"
    case SHOPZYGO = "Shop_zygo"
    case INSTRUCTOR = "Instructors"
    case CUSTOMERSUPPORT = "Customer_Support"
    case MANAGESUBSCRIPTION = "Manage_subscription"
    case SUBSCRIPTION = "subscription"
    case LOGOUT = "logout"
    case RESETPASSWORD = "Reset_password"
    case UPDATENOTIFICATIONSETTINGS = "Update_notifcation_setting"
    case UPDATETRACKINGSETTINGS = "Update_tracking_setting"
    case CANCELSTRIPESUBSCRIPTION = "Cancel_stripe_subscription"
    case CANCELSUBSCRIPTION = "Cancel_subscription"
    case SHAREWORKOUT = "Share_workout"
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

enum AppEnvironment{
    case production
    case staging
}
