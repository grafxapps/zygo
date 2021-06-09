//
//  SideMenuViewModel.swift
//  Zygo
//
//  Created by Som on 05/02/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit

final class SideMenuViewModel: NSObject {
    
    var arrMenu : [SideMenu] = [.settings, .shopZygo, .aboutZygo, .privacyPolicy, .termsService]
    
}

enum SideMenu: String {
    case profile = "Profile"
    case tempoTrainer = "Tempo Trainer"
    case settings = "Settings"
    case shopZygo = "Shop Zygo"
    case aboutZygo = "About Zygo"
    case privacyPolicy = "Privacy Policy"
    case termsService = "Terms Service"
}
