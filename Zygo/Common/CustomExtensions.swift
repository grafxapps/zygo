//
//  Extension.swift
//  Zygo
//
//  Created by Priya Gandhi on 23/01/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit
import SideMenuSwift

class CustomExtensions: NSObject {
    
}
extension UIFont{
    
    static func appRegular(with size: CGFloat) -> UIFont{
        return UIFont(name: "Poppins-Regular", size: size)!
    }
    
    static func appMedium(with size: CGFloat) -> UIFont{
        return UIFont(name: "Poppins-Medium", size: size)!
    }
    
    static func appMediumItalic(with size: CGFloat) -> UIFont{
        return UIFont(name: "Poppins-MediumItalic", size: size)!
    }
    
    static func appBold(with size: CGFloat) -> UIFont{
        return UIFont(name: "Poppins-Bold", size: size)!
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
        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows.filter({ $0.isKeyWindow }).first?.windowScene?.statusBarManager?.statusBarFrame.size ?? CGSize(width: 0.0, height: 0.0)
        } else {
            // Fallback on earlier versions
            return UIApplication.shared.statusBarFrame.size
        }
    }
    
    class func BottomSpace() -> CGFloat{
        return UIApplication.shared.windows.filter({ $0.isKeyWindow }).first?.safeAreaInsets.bottom ?? 0
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
    func toDisplayBirthday() -> String{
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "MMM d, yyyy"
        return dateFormat.string(from: self)
    }
    
    func toServerBirthday() -> String{
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd"
        return dateFormat.string(from: self)
    }
    
    func toFormat(format: String) -> String{
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = format
        dateFormat.locale = Locale.init(identifier: "en_US_POSIX")
        return dateFormat.string(from: self)
    }
    
    func toAge() -> String{
        let now = DateHelper.shared.currentLocalDateTime
        let birthday: Date = self
        let calendar = Calendar.current

        let ageComponents = calendar.dateComponents([.year], from: birthday, to: now)
        let age = ageComponents.year!
        return "\(age)"
    }
    
    
    func convertToFormat(_ format: String, isUTC: Bool = false) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale.init(identifier: "en_US_POSIX")
        if isUTC{
            formatter.timeZone = TimeZone(identifier: "UTC")
        }
        return formatter.string(from: self)
    }
    
    func toSubscriptionDate() -> String{
          return self.convertToFormat("yyyy-MM-dd HH:mm:ss", isUTC: true)
    }
    
    func dateDiff(to toDate: Date) -> String{
        let NowDate = toDate
        
        let myCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        let myComponents = myCalendar.components([.year, .month, .weekOfMonth,  .day, .hour, .minute, .second],from: self, to: NowDate, options: [])
        
        let year = Int(myComponents.year!)
        let month = Int(myComponents.month!)
        let weeks = Int(myComponents.weekOfMonth!)
        let days = Int(myComponents.day!)
        let hours = Int(myComponents.hour!)
        let min = Int(myComponents.minute!)
        let sec = Int(myComponents.second!)
        
        var timeAgo = ""
        
        if (sec > 0){
            if (sec > 1) {
                timeAgo = "\(sec) seconds ago"
            } else {
                timeAgo = "\(sec) second ago"
            }
        }
        
        if (min > 0){
            if (min > 1) {
                timeAgo = "\(min) minutes ago"
            } else {
                timeAgo = "\(min) minute ago"
            }
        }
        
        if(hours > 0){
            if (hours > 1) {
                timeAgo = "\(hours) hours ago"
            } else {
                timeAgo = "\(hours) hour ago"
            }
        }
        
        if (days > 0) {
            if (days > 1) {
                timeAgo = "\(days) days ago"
            } else {
                timeAgo = "\(days) day ago"
            }
        }
        
        if(weeks > 0){
            if (weeks > 1) {
                timeAgo = "\(weeks) weeks ago"
            } else {
                timeAgo = "\(weeks) week ago"
            }
        }
        
        if(month > 0){
            if (month > 1) {
                timeAgo = "\(month) months ago"
            } else {
                timeAgo = "\(month) month ago"
            }
        }
        
        if(year > 0){
            if (year > 1) {
                timeAgo = "\(year) years ago"
            } else {
                timeAgo = "\(year) year ago"
            }
        }
     
        if timeAgo.isEmpty{
            timeAgo = "just now"
        }
        
        return timeAgo
    }
}

extension String {
    func trimm() -> String{
        return self.trimmingCharacters(in: .whitespaces)
    }
    
    func getImageURL() -> String{
        if self.contains("http") || self.contains("https"){
            return self
        }else{
            return Constants.imageBaseUrl + self
        }
    }
    
    func isDescriptionEmpty() -> Bool{
        if self.isEmpty || self.lowercased() == "<br>"{
            return true
        }
        
        return false
    }
    
    func toSubscriptionDate() -> Date{
        var utcExpiryDate = self
        if !self.contains(" +0000"){
            utcExpiryDate = self + " +0000"
        }
        
        return utcExpiryDate.convertToFormat("yyyy-MM-dd HH:mm:ss Z")
    }
    
    func convertToFormat(_ format: String) -> Date{
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale.init(identifier: "en_US_POSIX")
        return formatter.date(from: self) ?? DateHelper.shared.currentLocalDateTime
    }
}

extension Double{
    func toMS() -> String{
        let seconds = Int(self.truncatingRemainder(dividingBy: 60))
        let minutes = Int(self/60.0)
        
        let stSeconds = seconds > 9 ? "\(seconds)" : "0\(seconds)"
        
        return "\(minutes):\(stSeconds)"
    }
    func toHMS() -> String{
        
        let seconds = Int(self.truncatingRemainder(dividingBy: 60))
        let minutes = Int(self/60.0) % 60
        let hours = Int(self/3600)
        
        let stMinutes = minutes > 9 ? "\(minutes)" : "0\(minutes)"
        let stSeconds = seconds > 9 ? "\(seconds)" : "0\(seconds)"
        let stHours = hours > 9 ? "\(hours)" : "0\(hours)"
        
        if hours > 0{
            return "\(stHours):\(stMinutes):\(stSeconds)"
        }else{
            
            
            return "\(stMinutes):\(stSeconds)"
        }
        
    }
    
    func toHM() -> String{
        
        //let seconds = Int(self.truncatingRemainder(dividingBy: 60))
        let minutes = Int(self/60.0) % 60
        let hours = Int(self/3600)
        
        let stMinutes = minutes > 9 ? "\(minutes)" : "0\(minutes)"
        //let stSeconds = seconds > 9 ? "\(seconds)" : "0\(seconds)"
        let stHours = hours > 9 ? "\(hours)" : "0\(hours)"
        
        if hours > 0{
            return "\(stHours):\(stMinutes)"
        }else{
            return "00:\(stMinutes)"
        }
        
    }
    func toHMIfPossible() -> String{
        
        let seconds = Int(self.truncatingRemainder(dividingBy: 60))
        let minutes = Int(self/60.0) % 60
        let hours = Int(self/3600)
        
        let stMinutes = minutes > 9 ? "\(minutes)" : "0\(minutes)"
        //let stSeconds = seconds > 9 ? "\(seconds)" : "0\(seconds)"
        let stHours = hours > 9 ? "\(hours)" : "\(hours)"
        
        if hours > 0{
            return "\(stHours):\(stMinutes)"
        }else if minutes > 0{
            if minutes > 9{
                return "\(minutes).\(seconds)"
            }else{
                return "0\(minutes).\(seconds)"
            }
        } else{
            return "00.\(seconds)"
        }
        
    }
}

extension UIColor{
    
    static func appDisableGrayColor() -> UIColor{
        return UIColor.init(named: "AppDisableGrayColor")!
    }
    
    
    static func appBlueColor() -> UIColor{
        return UIColor.init(named: "AppBlueColor")!
    }
    
    static func appTitleDarkColor() -> UIColor{
        return UIColor.init(named: "AppTitleDarkColor")!
    }
    
    static func appLightGrey() -> UIColor{
        return UIColor.init(red: 237.0/255.0, green: 237.0/255.0, blue: 237.0/255.0, alpha: 1.0)
    }
    
    static func appPopularInfoColor() -> UIColor{
        return UIColor.init(named: "AppPopularInfoColor")!
    }
    
    static func appNewInfoColor() -> UIColor{
        return UIColor.init(named: "AppNewInfoColor")!
    }
    
    static func appNewBlackColor() -> UIColor{
        return UIColor.init(named: "AppNewBlackColor")!
    }
}


extension String{
    
    func isEmailValid() -> Bool{
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
    
    func isValidPasswordLength() -> Bool{
        return self.count >= 8
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
    
    func size(withMaxWidth width: CGFloat, maxheight: CGFloat, font: UIFont) -> CGSize {
        
        let attributes = [NSAttributedString.Key.font: font]
        
        let attributedText = NSAttributedString(string: self, attributes: attributes)
        let constraintRect = CGSize(width: width, height: maxheight)
        let rect = attributedText.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).integral
        
        return rect.size
    }
    
    func toDate() -> Date{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: self)!
    }
    
    func toDateFormat(format: String) -> Date?{
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale.init(identifier: "en_US_POSIX")
        return formatter.date(from: self)
    }
    
    func toUTCDateFormat(format: String) -> Date?{
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.locale = Locale.init(identifier: "en_US_POSIX")
        return formatter.date(from: self)
    }
    
    func fromServerBirthday() -> Date?{
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd"
        dateFormat.locale = Locale.init(identifier: "en_US_POSIX")
        return dateFormat.date(from: self)
    }
    
    func fromDisplayBirthday() -> Date?{
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "MMM d, yyyy"
        dateFormat.locale = Locale.init(identifier: "en_US_POSIX")
        return dateFormat.date(from: self)
    }
    
    func toCreatedDate() -> Date{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.000000Z"
        formatter.locale = Locale.init(identifier: "en_US_POSIX")
        return formatter.date(from: self) ?? DateHelper.shared.currentLocalDateTime
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

extension NSCharacterSet {
    func isCharInSet(char: Character) -> Bool {
        var found = true
        for ch in String(char).utf16 {
            if !characterIsMember(ch) { found = false }
        }
        return found
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

class UICircleView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let radius: CGFloat = self.bounds.size.width / 2.0
        
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
}

class UICircleShadowView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let radius: CGFloat = self.bounds.size.width / 2.0
        
        self.layer.cornerRadius = radius
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowOpacity = 0.4
        self.layer.shadowRadius = 3.0
        //self.layer.masksToBounds = true
    }
}

class UISeparatorShadowView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //let radius: CGFloat = self.bounds.size.width / 2.0
        
        //self.layer.cornerRadius = radius
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowOpacity = 0.4
        self.layer.shadowRadius = 3.0
        //self.layer.masksToBounds = true
    }
}

class UIInstructorCircleImageView: UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let radius: CGFloat = self.bounds.size.width / 2.0
        
        self.layer.cornerRadius = radius
        self.layer.borderWidth = 2.0
        self.layer.borderColor = UIColor.appBlueColor().cgColor
        self.layer.masksToBounds = true
    }
}

extension UIView {
    func setupShadowViewAnimation(shadowRadius: CGFloat = 3.0,
                                  shadowOpacity: Float = 0.4,
                                  shadowColor: CGColor = UIColor.lightGray.cgColor,
                                  shadowOffset: CGSize = CGSize.zero) {
        layer.masksToBounds = false
        layer.shadowColor = shadowColor
        layer.shadowOffset = shadowOffset
        layer.shadowRadius = shadowRadius
        layer.shadowOpacity = shadowOpacity
    }
    
    func hideShadow(){
        layer.shadowOpacity = 0
    }
    
    func showShadow(shadowOpacity: Float = 0.4){
        layer.shadowOpacity = shadowOpacity
    }
    
}

class NavigationController: UINavigationController {
    
    open override var childForStatusBarHidden: UIViewController? {
        return self.topViewController
    }
    
    open override var childForStatusBarStyle: UIViewController? {
        return self.topViewController
    }
}

public extension UIViewController {
    
    /// Access the nearest ancestor view controller hierarchy that is a side menu controller.
    var sideMenuController: SideMenuController? {
        return findSideMenuController(from: self)
    }
    
    fileprivate func findSideMenuController(from viewController: UIViewController) -> SideMenuController? {
        var sourceViewController: UIViewController? = viewController
        repeat {
            sourceViewController = sourceViewController?.parent
            if let sideMenuController = sourceViewController as? SideMenuController {
                return sideMenuController
            }
        } while (sourceViewController != nil)
        return nil
    }
}

extension String {
    var htmlToAttributedString: NSMutableAttributedString? {
        let modifiedFont = String(format:"<span style=\"font-family: 'Poppins-Regular', 'HelveticaNeue'; font-size: 13\">%@</span>", self)
        
        guard let data = modifiedFont.data(using: .utf8) else { return nil }
        do {
            
            let attString = try NSAttributedString(data: data, options: [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding:String.Encoding.utf8.rawValue
            ], documentAttributes: nil)
            let mutableString = NSMutableAttributedString(attributedString: attString)
            //mutableString.addAttribute(.font, value: UIFont.appRegular(with: 13.0), range: NSRange(location: 0, length: attString.string.count))
            return mutableString
        } catch {
            return nil
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}

extension Dictionary {
    var toJsonString: String {
        guard let theJSONData = try? JSONSerialization.data(withJSONObject: self,
                                                            options: [.prettyPrinted]) else {
            return ""
        }
        
        return String(data: theJSONData, encoding: .ascii) ?? ""
    }
}

extension String{
    func toDictionary() -> [String: Any] {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ?? [:]
            } catch {
                print(error.localizedDescription)
            }
        }
        return [:]
    }
    
}

extension Notification.Name{
    static let fetchWorkouts = Notification.Name.init("Notifications_Fetch_Workouts")
    static let UpdateCompletedWorkouts = Notification.Name.init("Notifications_Name")
    static let removeObservers = Notification.Name.init("Notifications_Remove_Observers")
    
    static let didSelectClassesTab = Notification.Name.init("Notifications_Did_Select_Classes_Tab")
    static let didSelectSeriesTab = Notification.Name.init("Notifications_Did_Select_Series_Tab")
    static let didSelectDownloadsTab = Notification.Name.init("Notifications_Did_Select_Downloads_Tab")
    static let didSelectPacingTab = Notification.Name.init("Notifications_Did_Select_Pacing_Tab")
    static let didSelectProfileTab = Notification.Name.init("Notifications_Did_Select_Profile_Tab")
    static let didHideMenu = Notification.Name.init("Notifications_Did_Hide_Side_Menu")
}

extension UITableView {

    public func reloadData(_ completion: @escaping ()->()) {
        UIView.animate(withDuration: 0, animations: {
            self.reloadData()
        }, completion:{ _ in
            completion()
        })
    }

    func scroll(to: scrollsTo, animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            let numberOfSections = self.numberOfSections
            let numberOfRows = self.numberOfRows(inSection: numberOfSections-1)
            switch to{
            case .top:
                if numberOfRows > 0 {
                     let indexPath = IndexPath(row: 0, section: 0)
                     self.scrollToRow(at: indexPath, at: .top, animated: animated)
                }
                break
            case .bottom:
                if numberOfRows > 0 {
                    let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
                    self.scrollToRow(at: indexPath, at: .bottom, animated: animated)
                }
                break
            }
        }
    }

    enum scrollsTo {
        case top,bottom
    }
}

enum NotificationTypes: String{
    case workout = "workout"
    case none = ""
}

extension UIImage {
    func rotate(radians: CGFloat) -> UIImage {
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
            .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0,
                                 y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            draw(in: CGRect(x: -origin.y, y: -origin.x,
                            width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return rotatedImage ?? self
        }

        return self
    }
}

extension UIImageView{
    func rotate() {
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.fromValue = NSNumber(value: -(.pi/4.0))
        rotation.toValue = NSNumber(value: 0)
        rotation.duration = 1.25
        rotation.isCumulative = false
        rotation.repeatCount = 1
        self.layer.add(rotation, forKey: "rotationAnimation")
    }
}

extension UIView {
    func addShadow(location: VerticalLocation, color: UIColor = .black, opacity: Float = 0.2, radius: CGFloat = 3.0) {
        switch location {
        case .bottom:
            addShadow(offset: CGSize(width: 0, height: 2), color: color, opacity: opacity, radius: radius)
        case .top:
            addShadow(offset: CGSize(width: 0, height: -2), color: color, opacity: opacity, radius: radius)
        case .center:
            addShadow(offset: CGSize(width: 0, height: 0), color: color, opacity: opacity, radius: radius)
        }
    }
    
    
    func addShadow(offset: CGSize, color: UIColor = .black, opacity: Float = 0.3, radius: CGFloat = 5.0) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = offset
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
    }
    
    func addTopShadow(shadowColor : UIColor, shadowOpacity : Float,shadowRadius : Float,offset:CGSize){
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOffset = offset
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowRadius = CGFloat(shadowRadius)
        self.clipsToBounds = false
    }
    
    /* Usage Example
     * bgView.addBottomRoundedEdge(desiredCurve: 1.5)
     */
    func addBottomRoundedEdge(desiredCurve: CGFloat?) {
        let offset: CGFloat = self.frame.width / desiredCurve!
        let bounds: CGRect = self.bounds
        
        let rectBounds: CGRect = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.size.width, height: bounds.size.height / 2)
        let rectPath: UIBezierPath = UIBezierPath(rect: rectBounds)
        let ovalBounds: CGRect = CGRect(x: bounds.origin.x - offset / 2, y: bounds.origin.y, width: bounds.size.width + offset, height: bounds.size.height)
        let ovalPath: UIBezierPath = UIBezierPath(ovalIn: ovalBounds)
        rectPath.append(ovalPath)
        
        // Create the shape layer and set its path
        let maskLayer: CAShapeLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = rectPath.cgPath
        
        // Set the newly created shape layer as the mask for the view's layer
        self.layer.mask = maskLayer
    }
}

enum VerticalLocation: String {
    case bottom
    case top
    case center
}

extension UInt32 {
    var data: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<UInt32>.size)
    }
}

extension UInt64 {
    var data: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<UInt64>.size)
    }
}

extension UInt8 {
    var data: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<UInt8>.size)
    }
}

extension UInt16 {
    var data: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<UInt16>.size)
    }
}

extension UInt {
    var data: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<UInt>.size)
    }
}

extension Data {
   
    var hexString: String {
        var array: [UInt8] = []
        
        #if swift(>=5.0)
        withUnsafeBytes { array.append(contentsOf: $0) }
        #else
        withUnsafeBytes { array.append(contentsOf: getByteArray($0)) }
        #endif
        
        return array.reduce("") { (result, byte) -> String in
            result + String(format: "%02x", byte)
        }
    }

    private func getByteArray(_ pointer: UnsafePointer<UInt8>) -> [UInt8] {
        let buffer = UnsafeBufferPointer<UInt8>(start: pointer, count: count)
        return [UInt8](buffer)
    }
    
}

extension String {
    
    /// Create `Data` from hexadecimal string representation
    ///
    /// This creates a `Data` object from hex string. Note, if the string has any spaces or non-hex characters (e.g. starts with '<' and with a '>'), those are ignored and only hex characters are processed.
    ///
    /// - returns: Data represented by this hexadecimal string.
    
    var hexadecimal: Data? {
        var data = Data(capacity: count / 2)
        
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, range: NSRange(startIndex..., in: self)) { match, _, _ in
            let byteString = (self as NSString).substring(with: match!.range)
            let num = UInt8(byteString, radix: 16)!
            data.append(num)
        }
        
        guard data.count > 0 else { return nil }
        
        return data
    }
    
}

extension Data {

    init<T>(fromArray values: [T]) {
        self = values.withUnsafeBytes { Data($0) }
    }

    func toArray<T>(type: T.Type) -> [T] where T: ExpressibleByIntegerLiteral {
        var array = Array<T>(repeating: 0, count: self.count/MemoryLayout<T>.stride)
        _ = array.withUnsafeMutableBytes { copyBytes(to: $0) }
        return array
    }
}

extension Data {

    init<T>(from value: T) {
        self = Swift.withUnsafeBytes(of: value) { Data($0) }
    }

    func to<T>(type: T.Type) -> T? where T: ExpressibleByIntegerLiteral {
        var value: T = 0
        guard count >= MemoryLayout.size(ofValue: value) else { return nil }
        _ = Swift.withUnsafeMutableBytes(of: &value, { copyBytes(to: $0)} )
        return value
    }
    
    func swapUInt32Data() -> Data {
        var mdata = self // make a mutable copy
        let count = self.count / MemoryLayout<UInt32>.size
        mdata.withUnsafeMutableBytes { (i16ptr: UnsafeMutablePointer<UInt32>) in
            for i in 0..<count {
                i16ptr[i] = UInt32(bigEndian: i16ptr[i].byteSwapped)
            }
        }
        return mdata
    }
}
