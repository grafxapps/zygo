//
//  SideMenuViewModel.swift
//  Zygo
//
//  Created by Som on 05/02/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit

final class SideMenuViewModel: NSObject {
    
    var arrMenu : [SideMenu] = [.settings, .instructors, .shopZygo, .aboutZygo, .help ,.privacyPolicy, .termsService]
    
}

enum SideMenu: String {
    case profile = "Profile"
    case tempoTrainer = "Tempo Trainer"
    case settings = "Settings"
    case instructors = "Instructors"
    case shopZygo = "Shop Zygo"
    case aboutZygo = "About Zygo"
    case help = "Help"
    case privacyPolicy = "Privacy Policy"
    case termsService = "Terms of Service"
    case demoSubscribe = "Demo Subscribe"
}
