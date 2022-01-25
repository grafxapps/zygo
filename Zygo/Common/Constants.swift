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
    //static let baseUrl = "https://dev.zygohq.com"
    //static let imageBaseUrl = "https://dev.zygohq.com"
    //static let baseUrl = "https://dev.mirror.zygohq.com"
    //static let imageBaseUrl = "https://dev.mirror.zygohq.com"
    
    //Live mirror
    //static let baseUrl = "https://mirror.zygohq.com"
    //static let imageBaseUrl = "https://mirror.zygohq.com"
    
    //Live
    static let baseUrl = "https://zygohq.com"
    static let imageBaseUrl = "https://zygohq.com"
    
    //Change this
    static let branchKey = "key_live_gi2tjo1v3wnXldXjFkmrXgocxzhIHcj4"
        //"key_test_ma2Ded1vYvnZed8aynxVbabaEtmLQkCk"
    static let KLAVIYOPUBLICAPIKEY = "P2bQKn"
    
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
    static let ACCEPTABLE_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
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
    case workoutFeedback = "/api/workout-feedback-v2"
    
    case userHistory = "/api/user-history"
    
    case getWorkoutsSeries = "/api/get-series"
    
    case subscriptionPayment = "/api/apple-subscription-payment-v2"
    case cancelSubscription = "/api/cancel-apple-subscription"
    case cancelOtherSubscription = "/api/cancel-subscription"
    
    case updateToken = "/api/update-device-token"
    case notificationSetting = "/api/notification-setting"
    
    case forceUpgrade = "/api/force-upgrade"
    
    case getinstructor = "/api/get-instructor-by-id"
    case getInstructorsList = "/api/get-instructor-list"
    
    case ratingPopupDate = "/api/ratepopup-date"
    
    case homeCountry = "/api/update-user-home-contry"
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
    case PRIVACYPOLICY = "PRIVACY_POLICY"
    case SHOPZYGO = "Shop_zygo"
    case INSTRUCTOR = "Instructors"
    case MANAGESUBSCRIPTION = "Manage_subscription"
    case SUBSCRIPTION = "subscription"
    case LOGOUT = "logout"
    case RESETPASSWORD = "Reset_password"
    case UPDATENOTIFICATIONSETTINGS = "Update_notifcation_setting"
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
