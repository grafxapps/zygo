//
//  WorkoutHeaderTVC.swift
//  Zygo
//
//  Created by Priya Gandhi on 06/02/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit

class WorkoutHeaderTVC: UITableViewCell {
    
    static let identifier = "WorkoutHeaderTVC"
    @IBOutlet weak var lblTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
