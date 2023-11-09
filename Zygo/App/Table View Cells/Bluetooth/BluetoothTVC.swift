//
//  BluetoothTVC.swift
//  Zygo
//
//  Created by Priya Gandhi on 02/02/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit

class BluetoothTVC: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    
    static let identifier: String = "BluetoothTVC"
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
