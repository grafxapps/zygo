//
//  HistoryInfoTVC.swift
//  Zygo
//
//  Created by Priya Gandhi on 29/01/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit

class HistoryInfoTVC: UITableViewCell {
    
    @IBOutlet weak var classCountView: UIView!
    @IBOutlet weak var hoursView: UIView!
    
    @IBOutlet weak var lblClassCount: UILabel!
    @IBOutlet weak var lblHoursInWater: UILabel!
    
    static let identifier = "HistoryInfoTVC"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        classCountView.layer.borderWidth = 2.0
        classCountView.layer.borderColor = UIColor.appBlueColor().cgColor
        classCountView.layer.cornerRadius = 20.0
        classCountView.layer.masksToBounds = true
        
        hoursView.layer.borderWidth = 2.0
        hoursView.layer.borderColor = UIColor.appBlueColor().cgColor
        hoursView.layer.cornerRadius = 20.0
        hoursView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
