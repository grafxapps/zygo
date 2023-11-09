//
//  FirmwareStatusTVC.swift
//  Zygo
//
//  Created by Som Parkash on 22/12/22.
//  Copyright © 2022 Somparkash. All rights reserved.
//

import UIKit

class FirmwareStatusTVC: UITableViewCell {
    
    static let identifier = "FirmwareStatusTVC"
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var progress: UIActivityIndicatorView!
    @IBOutlet weak var stausImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
