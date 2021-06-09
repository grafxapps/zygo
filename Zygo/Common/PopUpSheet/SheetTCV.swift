//
//  SheetTCV.swift
//  Zygo
//
//  Created by Som on 01/02/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit

class SheetTCV: UITableViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var btnSelect: UIButton!

    static let identifier: String = "SheetTCV"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
