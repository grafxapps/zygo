//
//  SideMenuDemoTVC.swift
//  Zygo
//
//  Created by Som on 27/10/21.
//  Copyright © 2021 Somparkash. All rights reserved.
//

import UIKit

class SideMenuDemoTVC: UITableViewCell {
    
    static let identifier = "SideMenuDemoTVC"
    
    @IBOutlet weak var btnSubscribe: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
