//
//  Extension.swift
//  Zygo
//
//  Created by Priya Gandhi on 23/01/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit

class CustomExtensions: NSObject {
    
}
extension UIFont{
    
    static func appRegular(with size: CGFloat) -> UIFont{
        return UIFont(name: "Poppins-Regular", size: size)!
    }
    
    static func appMedium(with size: CGFloat) -> UIFont{
        return UIFont(name: "Poppins-Medium", size: size)!
    }
}
extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
    
    class func statuBarFrame() -> CGSize{
        return UIApplication.shared.windows.filter({ $0.isKeyWindow }).first?.windowScene?.statusBarManager?.statusBarFrame.size ?? CGSize(width: 0.0, height: 0.0)
    }
}
extension Date{
    func toUserProfile() -> String{
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy.MM.dd"
        //dateFormat.timeZone = TimeZone(abbreviation: "GMT-4")
        return dateFormat.string(from: self)
    }
    
    func toDisplayProfile() -> String{
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "d MMM yyyy"
        return dateFormat.string(from: self)
    }
    
    func toDisplayUserProfile() -> String{
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd"
        return dateFormat.string(from: self)
    }
    
    func toServerBirthday() -> String{
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd"
        return dateFormat.string(from: self)
    }
}
extension String {
    func trimm() -> String{
        return self.trimmingCharacters(in: .whitespaces)
    }
}

extension UIColor{
    
    static func appBlueColor() -> UIColor{
        return UIColor.init(named: "AppBlueColor")!
    }
    
    static func appLightGrey() -> UIColor{
        return UIColor.init(red: 237.0/255.0, green: 237.0/255.0, blue: 237.0/255.0, alpha: 1.0)
    }
    
}


extension String{
    
    func isEmailValid() -> Bool{
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
    
    func isValidPasswordLength() -> Bool{
        return self.count >= 6
    }
    
    func isPasswordValid() -> Bool{
        let passwordRegEx = "^(?=.*[a-z])(?=.*[A-Z]).{8,}$"
        let passwordPred = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        return passwordPred.evaluate(with: self)
    }
    
    func trim() -> String{
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func convertToJsonArray() -> [Any]{
        do{
            if let data = self.data(using: .utf8){
                let jsonArray = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                return jsonArray as? [Any] ?? []
            }
        }catch{
            return []
        }
        
        return []
    }
    
    func convertToJsonDict() -> [String : Any]{
        do{
            if let data = self.data(using: .utf8){
                let jsonDict = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                return jsonDict as? [String : Any] ?? [:]
            }
        }catch{
            return [:]
        }
        return [:]
    }
    
    func htmlDecoding() -> String{
        
        guard let data = self.data(using: .utf8) else {
            return self
        }
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
            return self
        }
        
        let decodedString = attributedString.string
        return decodedString
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
    
    func toDate() -> Date{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: self)!
    }
    
    func formattedNumber() -> String {
        let cleanPhoneNumber = self.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let mask = "XXX-XXX-XXXX"
        
        var result = ""
        var index = cleanPhoneNumber.startIndex
        for ch in mask where index < cleanPhoneNumber.endIndex {
            if ch == "X" {
                result.append(cleanPhoneNumber[index])
                index = cleanPhoneNumber.index(after: index)
            } else {
                result.append(ch)
            }
        }
        return result
    }
    
    func formattedSSN() -> String {
        let cleanPhoneNumber = self.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let mask = "XXX-XX-XXXX"
        
        var result = ""
        var index = cleanPhoneNumber.startIndex
        for ch in mask where index < cleanPhoneNumber.endIndex {
            if ch == "X" {
                result.append(cleanPhoneNumber[index])
                index = cleanPhoneNumber.index(after: index)
            } else {
                result.append(ch)
            }
        }
        return result
    }
}


class UICircleImageView: UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let radius: CGFloat = self.bounds.size.width / 2.0
        
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
}
extension UIView {
    func setupShadowViewAnimation(shadowRadius: CGFloat = 3.0,
                                  shadowOpacity: Float = 0.5,
                                  shadowColor: CGColor = UIColor.black.cgColor,
                                  shadowOffset: CGSize = CGSize.zero) {
        layer.masksToBounds = false
        layer.shadowColor = shadowColor
        layer.shadowOffset = shadowOffset
        layer.shadowRadius = shadowRadius
        layer.shadowOpacity = shadowOpacity
    }
}
