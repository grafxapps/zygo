//
//  SideMenuViewModel.swift
//  Zygo
//
//  Created by Som on 05/02/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit

final class SideMenuViewModel: NSObject {
    
    var arrMenu : [SideMenu] = [.settings, .firmwareUpdate, .walkieTalkie, .hallOfFame, .deviceSetup, .customerSupport, .instructors]
    
}

enum SideMenu: String {
    case profile = "Profile"
    case tempoTrainer = "Tempo Trainer"
    case settings = "Settings"
    case firmwareUpdate = "Firmware Updates"
    case instructors = "Instructors"
    case shopZygo = "Shop Zygo"
    case aboutZygo = "About Zygo"
    case deviceSetup = "Device Setup"
    case privacyPolicy = "Privacy Policy"
    case termsService = "Terms of Service"
    case demoSubscribe = "Demo Subscribe"
    case customerSupport = "Customer Support"
    case referFriend = "Refer A Friend"
    case walkieTalkie = "Walkie Talkie"
    case hallOfFame = "Hall of Fame"
}
