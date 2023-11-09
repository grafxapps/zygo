//
//  SettingsViewController.swift
//  Zygo
//
//  Created by Priya Gandhi on 29/01/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var tblSettings : UITableView!
    
    var arrNotificationTitles : [String] = [];
    var arrAccountTitles : [String] = [];
    var arrDevicesTitles : [String] = [];
    var arrSections: [String] = []
    var arrTrackingTitles: [String] = []
    
    //MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        registerTVC()
        arrNotificationTitles = ["Nudges", "Events near me", "Zygo Community"]
        arrTrackingTitles = ["Distance Tracking", "Tempo Tracking"]
        
        if Helper.shared.isSocialLogin(){
            if Helper.shared.isDemoMode{
                arrAccountTitles = ["Subscribe", "Logout"]
            }else{
                arrAccountTitles = ["Manage Subscription", "Logout"]
            }
        }else{
            if Helper.shared.isDemoMode{
                arrAccountTitles = ["Subscribe", "Reset password", "Logout"]
            }else{
                arrAccountTitles = ["Manage Subscription", "Reset password", "Logout"]
            }
        }
        
        arrDevicesTitles = ["Pairing"]
        arrSections = ["Notifications", "Tracking", "Your Account", "Devices"]
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    //MARK:- Setup
    func registerTVC()  {
        tblSettings.separatorStyle = .none
        tblSettings.register(UINib.init(nibName: NotificationSettingsTVC.identifier, bundle: nil), forCellReuseIdentifier: NotificationSettingsTVC.identifier)
        tblSettings.register(UINib.init(nibName: OtherSettingsTVC.identifier, bundle: nil), forCellReuseIdentifier: OtherSettingsTVC.identifier)
        tblSettings.register(UINib(nibName: SettingsHV.identifier, bundle: nil), forHeaderFooterViewReuseIdentifier: SettingsHV.identifier)
        
    }
    
    //MARK: - UIButton Actions
    @IBAction func backAction(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func switchChanged(sender : UISwitch){
        print(sender.tag)
        var title : String = ""
        var status : Int = 0
        if sender.isOn{
            status = 1
        }else{
            status = 0
        }
        
        var notiInfo = PreferenceManager.shared.notificationInfo
        
        if sender.tag == 0{
            notiInfo.nudgeNotifications = NSNumber(value: status).boolValue
            title = "nudge_notifications"
        }else if sender.tag == 1{
            notiInfo.eventNotifications = NSNumber(value: status).boolValue
            title = "event_notifications"
        }else{
            notiInfo.promoNotifications = NSNumber(value: status).boolValue
            title = "promo_notifications"
        }
        
        Helper.shared.startLoading()
        Helper.shared.log(event: .UPDATENOTIFICATIONSETTINGS, params: [:])
        UserServices().updateNotificationSettings(type: title, status: status) { [weak self] (error) in
            DispatchQueue.main.async {
                
                Helper.shared.stopLoading()
                
                if error != nil{
                    Helper.shared.alert(title: Constants.appName, message: error!)
                    return
                }
                
                PreferenceManager.shared.notificationInfo = notiInfo
                self?.tblSettings.reloadData()
            }
        }
    }
    
    @objc func trackingSwitchChanged(sender : UISwitch){
        print(sender.tag)
        var title : String = ""
        var status : Int = 0
        if sender.isOn{
            status = 1
        }else{
            status = 0
        }
        
        var notiInfo = PreferenceManager.shared.trackingInfo
        
        if sender.tag == 0{
            notiInfo.isDistanceTracking = NSNumber(value: status).boolValue
            title = "distance_tracking_on"
        }else if sender.tag == 1{
            notiInfo.isTempoTracking = NSNumber(value: status).boolValue
            title = "tempo_tracking_on"
        }
        
        Helper.shared.startLoading()
        Helper.shared.log(event: .UPDATETRACKINGSETTINGS, params: [:])
        UserServices().updateTrackingSettings(type: title, status: status) { [weak self] (error) in
            DispatchQueue.main.async {
                
                Helper.shared.stopLoading()
                
                if error != nil{
                    Helper.shared.alert(title: Constants.appName, message: error!)
                    return
                }
                
                PreferenceManager.shared.trackingInfo = notiInfo
                self?.tblSettings.reloadData()
            }
        }
    }
    
}

extension SettingsViewController : UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return arrNotificationTitles.count
        }else if section == 1{
            return arrTrackingTitles.count
        }else if section == 2{
            return arrAccountTitles.count
        }else{
            return arrDevicesTitles.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: SettingsHV.identifier) as! SettingsHV
        headerView.lblTitle.text = arrSections[section]
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell : NotificationSettingsTVC = tableView.dequeueReusableCell(withIdentifier: NotificationSettingsTVC.identifier) as! NotificationSettingsTVC
            cell.lblTitle.text = arrNotificationTitles[indexPath.row];
            
            let notiInfo = PreferenceManager.shared.notificationInfo
            if indexPath.row == 0{//Nudges
                cell.switchNoti.isOn = notiInfo.nudgeNotifications
            }else if indexPath.row == 1{//Events
                cell.switchNoti.isOn = notiInfo.eventNotifications
            }else{//Community
                cell.switchNoti.isOn = notiInfo.promoNotifications
            }
            
            cell.switchNoti.tag = indexPath.row
            cell.switchNoti.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
            
            cell.selectionStyle = .none
            return cell;
        }else if indexPath.section == 1{
            let cell : NotificationSettingsTVC = tableView.dequeueReusableCell(withIdentifier: NotificationSettingsTVC.identifier) as! NotificationSettingsTVC
            cell.lblTitle.text = arrTrackingTitles[indexPath.row];
            
            let notiInfo = PreferenceManager.shared.trackingInfo
            if indexPath.row == 0{//Distance Tracking
                cell.switchNoti.isOn = notiInfo.isDistanceTracking
            }else{//tempo
                cell.switchNoti.isOn = notiInfo.isTempoTracking
            }
            
            cell.switchNoti.tag = indexPath.row
            cell.switchNoti.addTarget(self, action: #selector(trackingSwitchChanged), for: .valueChanged)
            
            cell.selectionStyle = .none
            return cell;
        }else{
            let cell : OtherSettingsTVC = tableView.dequeueReusableCell(withIdentifier: OtherSettingsTVC.identifier) as! OtherSettingsTVC
            cell.selectionStyle = .none
            if indexPath.section == 1{
                cell.lblTitle.text = arrTrackingTitles[indexPath.row]
            }else if indexPath.section == 2{
                cell.lblTitle.text = arrAccountTitles[indexPath.row];
            }else{
                cell.lblTitle.text = arrDevicesTitles[indexPath.row];
                
            }
            return cell;
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65.0;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 2{
            if Helper.shared.isSocialLogin(){
                if indexPath.row == 0{
                    //if SubscriptionManager.shared.isValidSubscription(){
                    if Helper.shared.isDemoMode{
                        Helper.shared.log(event: .SUBSCRIPTION, params: [:])
                        Helper.shared.pushToSubscriptionScreen(from: self)
                    }else{
                        Helper.shared.log(event: .MANAGESUBSCRIPTION, params: [:])
                        let storyB = UIStoryboard(name: "Registration", bundle: nil)
                        let subVC = storyB.instantiateViewController(withIdentifier: "SubscriptionCancelVC") as! SubscriptionCancelVC
                        self.navigationController?.pushViewController(subVC, animated: true)
                    }
                    /*}else{
                        let storyB = UIStoryboard(name: "Registration", bundle: nil)
                        let subVC = storyB.instantiateViewController(withIdentifier: "SubscriptionViewController") as! SubscriptionViewController
                        self.navigationController?.pushViewController(subVC, animated: true)
                    }*/
                }else{
                    Helper.shared.log(event: .LOGOUT, params: [:])
                    Helper.shared.logout()
                }
            }else{
                if indexPath.row == 0{
                    if Helper.shared.isDemoMode{
                        Helper.shared.log(event: .SUBSCRIPTION, params: [:])
                        Helper.shared.pushToSubscriptionScreen(from: self)
                    }else{
                        Helper.shared.log(event: .MANAGESUBSCRIPTION, params: [:])
                        let storyB = UIStoryboard(name: "Registration", bundle: nil)
                        let subVC = storyB.instantiateViewController(withIdentifier: "SubscriptionCancelVC") as! SubscriptionCancelVC
                        self.navigationController?.pushViewController(subVC, animated: true)
                    }
                    //if SubscriptionManager.shared.isValidSubscription(){
                        
                    /*}else{
                        let storyB = UIStoryboard(name: "Registration", bundle: nil)
                        let subVC = storyB.instantiateViewController(withIdentifier: "SubscriptionViewController") as! SubscriptionViewController
                        self.navigationController?.pushViewController(subVC, animated: true)
                    }*/
                }else if indexPath.row == 1{
                    Helper.shared.log(event: .RESETPASSWORD, params: [:])
                    let changePVC = self.storyboard?.instantiateViewController(withIdentifier: "ChangePasswordVC") as! ChangePasswordVC
                    self.navigationController?.pushViewController(changePVC, animated: true)
                }else{
                    Helper.shared.log(event: .LOGOUT, params: [:])
                    Helper.shared.logout()
                }
            }
            
        }else if indexPath.section == 3{
            if indexPath.row == 0{
                /*guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else{
                    return
                }
                
                Helper.shared.openUrl(url: settingsUrl)*/
                let btVC = self.storyboard?.instantiateViewController(withIdentifier: "BluetoothViewController") as! BluetoothViewController
                self.navigationController?.pushViewController(btVC, animated: true)
            }
        }
        
        
        
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

enum LoginType: String {
    case none = ""
    case google = "google"
    case facebook = "facebook"
    case apple = "apple"
}

enum SubscriptionType: String{
    case Stripe = "stripe"
    case Google = "google"
    case Apple = "apple_pay"
}
