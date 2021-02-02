//
//  PastWorkoutsTVC.swift
//  Zygo
//
//  Created by Priya Gandhi on 29/01/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit

class PastWorkoutsTVC: UITableViewCell {
    @IBOutlet weak var viewOuter : UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        viewOuter.setupShadowViewAnimation()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
