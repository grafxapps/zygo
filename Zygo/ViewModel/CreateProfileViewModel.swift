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
    var arrHistory: [History] = [.classCount, .Achievements, .WorkoutLogs]
    
    var profileItem = CreateProfileDTO()
    var arrWorkoutLogs: [WorkoutLogDTO] = []
    var arrAchievements: [AchievementDTO] = []
    
    private let userService = UserServices()
    
    func isValidate() -> Bool{
        if profileItem.email.isEmpty{
            Helper.shared.alert(title: Constants.appName, message: "Please enter your email address.")
            return false
        }else if !profileItem.email.isEmailValid(){
            Helper.shared.alert(title: Constants.appName, message: "Please enter a valid email address.")
            return false
        }
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
    
    func createProfile(completion: @escaping (Bool, String) -> Void){
        Helper.shared.startLoading()
        userService.createProfile(user: self.profileItem) { [weak self] (error, profileImage) in
            if self == nil{
                return
            }
            
            DispatchQueue.main.async {
                Helper.shared.stopLoading()
                if error != nil{
                    Helper.shared.alert(title: Constants.appName, message: error!)
                    completion(false, "")
                    return
                }
                
                completion(true, profileImage)
            }
        }
        
    }
    
    func updateProfile(completion: @escaping (Bool, String) -> Void){
        Helper.shared.startLoading()
        userService.createProfile(user: self.profileItem) { [weak self] (error, profileImage) in
            if self == nil{
                return
            }
            
            DispatchQueue.main.async {
                Helper.shared.stopLoading()
                if error != nil{
                    Helper.shared.alert(title: Constants.appName, message: error!)
                    completion(false, "")
                    return
                }
                
                //Helper.shared.alert(title: Constants.appName, message: "Your profile updated successfully.") {
                    completion(true, profileImage)
                //}
            }
        }
    }
    
    func getUserHistory(completion: @escaping (Bool) -> Void){
        
        userService.getUserHistory { [weak self] (error, arrWorkoutLogs, arrAchievements) in
            if self == nil{
                return
            }
            
            DispatchQueue.main.async {
                Helper.shared.stopLoading()
                if error != nil{
                    //Helper.shared.alert(title: Constants.appName, message: error!)
                    completion(false)
                    return
                }
                
                self?.arrAchievements.removeAll(keepingCapacity: true)
                self?.arrWorkoutLogs.removeAll(keepingCapacity: true)
                self?.arrAchievements.append(contentsOf: arrAchievements)
                self?.arrWorkoutLogs.append(contentsOf: arrWorkoutLogs)
                self?.arrHistory.removeAll()
                self?.arrHistory.append(.classCount)
                if arrAchievements.count > 0{
                    self?.arrHistory.append(.Achievements)
                }
                
                if arrWorkoutLogs.count > 0{
                    self?.arrHistory.append(.WorkoutLogs)
                }
                
                completion(true)
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

enum History{
    case classCount
    case Achievements
    case WorkoutLogs
}


struct CreateProfileDTO {
    var email: String = ""
    var name: String = ""
    var fname: String = ""
    var lname: String = ""
    var gender: String = ""
    var birthday : String = ""
    var birthdayDisplay : String = ""
    var location : String = ""
    var image: UIImage?
}
