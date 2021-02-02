//
//  CreateProfileViewModel.swift
//  Zygo
//
//  Created by Som on 29/01/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit

final class CreateProfileViewModel: NSObject {
    
    var arrGender: [Gender] = [.female, .male, .nonBinary, .transgender, .intersex, .type, .notToSay]
    var profileItem = CreateProfileDTO()
    
    private let userService = UserServices()
    
    func isValidate() -> Bool{
        if profileItem.name.isEmpty{
            Helper.shared.alert(title: Constants.appName, message: NSLocalizedString("Please enter your user name.", comment: ""))
            return false
        }else if profileItem.fname.isEmpty{
            Helper.shared.alert(title: Constants.appName, message: "Please enter your first name.")
            return false
        }else if profileItem.lname.isEmpty{
            Helper.shared.alert(title: Constants.appName, message: "Please enter your last name.")
            return false
        }else if profileItem.gender.isEmpty{
            Helper.shared.alert(title: Constants.appName, message: NSLocalizedString("Please select your gender.", comment: ""))
            return false
        }else if profileItem.birthday.isEmpty{
            Helper.shared.alert(title: Constants.appName, message: NSLocalizedString("Please select your birth date.", comment: ""))
            return false
        }else if profileItem.location.isEmpty{
            Helper.shared.alert(title: Constants.appName, message: NSLocalizedString("Please enter your address.", comment: ""))
            return false
        }
        
        return true
    }
    
    func createProfile(completion: @escaping (Bool) -> Void){
        Helper.shared.startLoading()
        userService.createProfile(user: self.profileItem) { [weak self] (error) in
            if self == nil{
                return
            }
            
            DispatchQueue.main.async {
                Helper.shared.stopLoading()
                if error != nil{
                    Helper.shared.alert(title: Constants.appName, message: error!)
                    completion(false)
                    return
                }
                
                Helper.shared.alert(title: Constants.appName, message: "Your profile created successfully.") {
                    completion(true)
                }
            }
        }
        
    }
    
}

enum Gender: String {
    
    case male = "Male"
    case female = "Female"
    case nonBinary = "Non-binary"
    case transgender = "Transgender"
    case intersex = "Intersex"
    case type = "Let me type..."
    case notToSay = "I prefer not to say"
    
}


struct CreateProfileDTO {
    var name: String = ""
    var fname: String = ""
    var lname: String = ""
    var gender: String = ""
    var birthday : String = ""
    var location : String = ""
    var image: UIImage?
}
