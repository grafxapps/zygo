//
//  UserServices.swift
//  Zygo
//
//  Created by Som on 29/01/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit

final class UserServices: NSObject {

    func createProfile(user: CreateProfileDTO, completion: @escaping (String?) -> Void){
        let param = [
            "user_first_name": user.fname,
            "user_last_name": user.lname,
            "user_display_name": user.name,
            "user_gender": user.gender,
            "user_birthday": user.birthday,
            "profile_location": user.location,
        ] as [String : String]
        
        let imageData = user.image?.jpegData(compressionQuality: 0.2)
        let header = NetworkManager.shared.getHeader()
        let url = Constants.baseUrl + APIEndPoint.updateProfile.rawValue
        
        NetworkManager.shared.uploadImage(withUrl: url, method: .post, headers: header, params: param, imageData: imageData, imageName: "user_profile_pic") { (response) in
            
            switch response{
            case .success(_ ):
                completion(nil)
            case .failure(_, let message):
                completion(message)
            case .notConnectedToInternet:
                completion(Constants.internetNotWorking)
            }
        }
    }
}
