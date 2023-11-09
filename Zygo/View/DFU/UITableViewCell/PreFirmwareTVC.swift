//
//  PreFirmwareTVC.swift
//  Zygo
//
//  Created by Som Parkash on 15/12/22.
//  Copyright © 2022 Somparkash. All rights reserved.
//

import UIKit

class PreFirmwareTVC: UITableViewCell {

    static let identifier = "PreFirmwareTVC"
    
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var btnUpdate: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
