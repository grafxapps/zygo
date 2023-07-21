//
//  InstructorWorkoutTitleTVC.swift
//  Zygo
//
//  Created by Som on 28/06/21.
//  Copyright © 2021 Somparkash. All rights reserved.
//

import UIKit

class InstructorWorkoutTitleTVC: UITableViewCell {

    static let identifier = "InstructorWorkoutTitleTVC"
    
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
