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
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblWorkoutDate: UILabel!
    @IBOutlet weak var lblWorkoutType: UILabel!
    @IBOutlet weak var lblInstructorName: UILabel!
    
    @IBOutlet weak var constentTopConstraint: NSLayoutConstraint!
    
    
    static let identifier = "PastWorkoutsTVC"

    override func awakeFromNib() {
        super.awakeFromNib()
        viewOuter.setupShadowViewAnimation()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupPastWorkouInfo(item: WorkoutLogDTO){
        self.lblName.text = "\(item.workoutDuration) min \(item.workoutName)"
        self.lblWorkoutDate.text = item.dateOfWorkout.toDisplayBirthday()
        self.lblWorkoutType.text = item.workoutTypeTitle
        self.lblInstructorName.text = item.instructorName
    }
    
}
