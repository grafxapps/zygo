//
//  NetworkManager.swift
//  Zygo
//
//  Created by Priya Gandhi on 23/01/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit
import Alamofire

enum ServiceResponse {
    case success(response: [String : Any])
    case failure(statusCode: HTTPStatusCode, message: String)
    case notConnectedToInternet
}

final class NetworkManager : NSObject{
    
    static let shared = NetworkManager()
    private override init() {
    }
    
    private var awsAccKey: String = ""
    private var aswSecKey: String = ""
    private var aswBucketKey: String = ""
    
    var dataRequestArray: [DataRequest] = []
    var sessionManager: [String : Alamofire.Session] = [:]
    
    func getHeader() -> [String : String]{
        return ["Authorization" : PreferenceManager.shared.authToken]
    }
    
    func request(withEndPoint endPoint: APIEndPoint, method: Alamofire.HTTPMethod = .get, headers: [String:String]? = [:], params: [String : Any] = [:], isPreviousRequestCancel: Bool = true, completion: @escaping (ServiceResponse) -> Void){
        
        let url = Constants.baseUrl + endPoint.rawValue
        self.request(withUrl: url,method: method, headers: headers, body: params, isPreviousRequestCancel: isPreviousRequestCancel, completion: completion)
    }
    
    func request(withEndPoint endPoint: String, method: Alamofire.HTTPMethod = .get, headers: [String:String]? = [:], params: [String : Any] = [:], isPreviousRequestCancel : Bool, completion: @escaping (ServiceResponse) -> Void){
        
        let url = Constants.baseUrl + endPoint
        self.request(withUrl: url, method: method, headers: headers, body: params,isPreviousRequestCancel: isPreviousRequestCancel, completion: completion)
    }
    
    func request(withUrl url: String, method: Alamofire.HTTPMethod , headers: [String:String]? = [:], params: [String : Any] = [:], isPreviousRequestCancel: Bool = true, completion: @escaping (ServiceResponse) -> Void){
        self.request(withUrl: url,method: method, headers: headers, body: params, isPreviousRequestCancel: isPreviousRequestCancel , completion: completion)
    }
    
    func cancelRequestURL(url: URL){
        //print("Previous Cancelled")
        if self.dataRequestArray.count > 0{
            
            let arrRequests = self.dataRequestArray.filter({ $0.request?.url == url })
            for dataRequest in arrRequests {
                dataRequest.cancel()
            }
            
            self.dataRequestArray.removeAll(where: { $0.request?.url == url })
        }
        
        if self.sessionManager.count > 0{
            self.sessionManager.removeValue(forKey: url.absoluteString)
        }
    }
    
    func request(withUrl url: String ,method: Alamofire.HTTPMethod , headers: [String:String]? = [:], body: [String: Any], isPreviousRequestCancel: Bool, completion: @escaping (ServiceResponse) -> Void){
        print("Hit Request: \(url)")
        var mURL = URLComponents(string: url)!
        if isPreviousRequestCancel{
            self.cancelRequestURL(url: URL(string: url)!)
        }
        
        //Append Query param
        if method == .get{
            let keys = body.keys
            if keys.count > 0{
                var queryItems: [URLQueryItem] = []
                for key in keys{
                    queryItems.append(URLQueryItem(name: key, value: "\(body[key] ?? "")"))
                }
                
                mURL.queryItems = queryItems
            }
        }
        
        var request = URLRequest(url: mURL.url!)
        print("Actual URL: \(mURL.url)")
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        //request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        //mutableURLRequest.cachePolicy = NSURLRequest.CachePolicy.returnCacheDataElseLoad
        
        if headers != nil{
            for key in headers!.keys{
                request.setValue(headers![key], forHTTPHeaderField: key)
            }
        }
        
        if method == .post{
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        }
        /*var newHeader : HTTPHeaders = [:]
         if headers != nil{
         for key in headers!.keys{
         newHeader[key] = headers![key]
         }
         }
         
         newHeader["Content-Type"] = "application/x-www-form-urlencoded"*/
        //newHeader["Content-Type"] = "application/json"
        //Alamofire.request(URL(string: url)!, method: method, parameters: body, encoding: URLEncoding.default, headers: newHeader)
        
        let dataRequest = AF.request(request).responseString { (response) in
            if self.dataRequestArray.count > 0{
                self.dataRequestArray.removeAll(where: { $0.request?.url == response.request?.url })
            }
            
            if self.sessionManager.count > 0{
                self.sessionManager.removeValue(forKey: url)
            }
            
            self.serializeResponse(response: response, completion: completion)
            
        }
        
        dataRequestArray.append(dataRequest)
    }
    
    func uploadImage(withUrl url: String, method: Alamofire.HTTPMethod = .get, headers: [String:String]? = [:], params: [String : String] = [:], imageData: Data?, imageName: String, completion: @escaping (ServiceResponse) -> Void){
        
        AF.upload(multipartFormData: { multipartFormData in
            
            if imageData != nil{
                multipartFormData.append(imageData!, withName: imageName, fileName: "ZygoUser\(Int(Date().timeIntervalSince1970)).png", mimeType: "image/jpg")
            }
            
            for (key, value) in params {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            } //Optional for extra parameters
        },
                  to:url, method: .post, headers: HTTPHeaders(headers ?? [:])).responseString{ (response) in
                    self.serializeResponse(response: response, completion: completion)
                    self.sessionManager.removeValue(forKey: url)
        }
    }
    
    
    func googleLogin(parameters: [String: Any]){
        let headers = [
          "content-type": "application/json",
          "cache-control": "no-cache"
        ]

        do{
            
        let postData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)

        let request = NSMutableURLRequest(url: NSURL(string: Constants.baseUrl + APIEndPoint.googleSignIn.rawValue)! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
          if (error != nil) {
            print(error)
          } else {
            let httpResponse = response as? HTTPURLResponse
            print(httpResponse)
          }
        })

        dataTask.resume()
        }catch{
            print("Params error")
        }
    }
    
    func serializeResponse(response: Alamofire.AFDataResponse<String>,  completion: @escaping (ServiceResponse) -> Void) {
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            
            guard let strongSelf = self else { return }
            
            let serverErrorMessage = "Internal server error. Please try again."
            
            var json: Any?
            guard let urlResponse = response.response else {
                
                switch response.result{
                case .success(_ ):
                    //Because Response nil
                    strongSelf.failure(statusCode: 0, message: serverErrorMessage, completion: completion)
                    break
                case .failure(let aferror):
                    if let errp = aferror.asAFError, errp.isExplicitlyCancelledError{
                        strongSelf.failure(statusCode: HTTPStatusCode.Cancelled.rawValue, message: serverErrorMessage, completion: completion)
                    }else if let error = aferror.underlyingError as NSError?, error.code == NSURLErrorNotConnectedToInternet {
                        strongSelf.notConnectedToInternet(completion: completion)
                    } else if let error = aferror.underlyingError as NSError?{
                        strongSelf.failure(statusCode: error.code, message: serverErrorMessage, completion: completion)
                    }else{
                        strongSelf.failure(statusCode: 0, message: serverErrorMessage, completion: completion)
                    }
                    break
                }
                
                return
            }
            
            
            switch response.result{
            case .success(let sucessResponse):
                
                if let data = sucessResponse.data(using: String.Encoding.utf8) {
                    do {
                        json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:AnyObject]
                    } catch {
                        strongSelf.failure(statusCode: urlResponse.statusCode, message: serverErrorMessage, completion: completion)
                        print("API ERROR: \(urlResponse.statusCode)")
                        
                        return
                    }
                }
                
                print(json ?? "Nil Response")
                
                guard let jsonResponse = json as? [String : Any] else {
                    strongSelf.failure(statusCode: urlResponse.statusCode, message: serverErrorMessage, completion: completion)
                    return
                }
                
                
                if (jsonResponse[AppKeys.status.rawValue] as? Int) != 1 {
                    strongSelf.failure(statusCode: urlResponse.statusCode, message: jsonResponse[AppKeys.message.rawValue] as? String ?? serverErrorMessage, completion: completion)
                    return
                }
                
                strongSelf.success(result:jsonResponse , headers: urlResponse.allHeaderFields, completion: completion)
                
                
                break
            case .failure(let aferror):
                
                if let error = aferror.underlyingError as NSError?, error.code == NSURLErrorNotConnectedToInternet {
                    strongSelf.notConnectedToInternet(completion: completion)
                } else if let error = aferror.underlyingError as NSError?{
                    strongSelf.failure(statusCode: error.code, message: serverErrorMessage, completion: completion)
                }else{
                    strongSelf.failure(statusCode: 0, message: serverErrorMessage, completion: completion)
                }
                break
            }
            
        }
    }
    
    func cancelAllRequests () {
        for dataRequest in self.dataRequestArray {
            dataRequest.cancel()
        }
        self.dataRequestArray.removeAll()
    }
    
    func notConnectedToInternet (completion:@escaping (ServiceResponse) -> Void) {
        completion(.notConnectedToInternet)
    }
    
    func failure (statusCode: Int, message: String, completion:@escaping (ServiceResponse) -> Void) {
        if let status = HTTPStatusCode.init(rawValue: statusCode){
            completion(.failure(statusCode: status, message: message))
            return
        }
        
        completion(.failure(statusCode: .InternalServerError, message: message))
    }
    
    func success (result: [String : Any]?, headers: [AnyHashable: Any], completion:@escaping (ServiceResponse) -> Void) {
        completion(.success(response: result!))
    }
    
    func generateRandomStringWithLength(length: Int) -> String {
        let randomString: NSMutableString = NSMutableString(capacity: length)
        let letters: NSMutableString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var i: Int = 0
        
        while i < length {
            let randomIndex: Int = Int(arc4random_uniform(UInt32(letters.length)))
            randomString.append("\(Character( UnicodeScalar( letters.character(at: randomIndex))!))")
            i += 1
        }
        return String(randomString)
    }
    
}

extension Array: ParameterEncoding {
    
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
        return request
    }
}

extension Data {
    
    var format: String {
        let array = [UInt8](self)
        let ext: String
        switch (array[0]) {
        case 0xFF:
            ext = "jpg"
        case 0x89:
            ext = "png"
        case 0x47:
            ext = "gif"
        case 0x49, 0x4D :
            ext = "tiff"
        default:
            ext = "unknown"
        }
        return ext
    }
    
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
    case workoutFeedback = "/api/workout-feedback-v4"//"/api/workout-feedback-v2"
    
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
    
    case trackingSettings = "/api/settings"
    case graph = "/api/workout-graph"
    case graphYearly = "/api/workout-graph-yearly"
    
    case deleteAccount = "/api/delete-account"
    case contactUsDetail = "/api/contact-details"
    
    case getFirmwareFiles = "/api/get-firmware-detail"
    case getHallOfFame = "/api/hall-of-fame"
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
