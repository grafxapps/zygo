//
//  WorkoutPlanTVC.swift
//  Zygo
//
//  Created by Priya Gandhi on 04/02/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit

class WorkoutPlanTVC: UITableViewCell {

    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var lblDuration : UILabel!

    static let identifier = "WorkoutPlanTVC"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
