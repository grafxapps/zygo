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
    @IBOutlet weak var instructorIndicatorView : UIView!
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblWorkoutDate: UILabel!
    @IBOutlet weak var lblWorkoutType: UILabel!
    @IBOutlet weak var lblInstructorName: UILabel!
    @IBOutlet weak var lblDistance: UILabel!
    
    @IBOutlet weak var constentTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentViewCenterConstraint: NSLayoutConstraint!
    
    
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
        if (Int(item.workoutDuration) ?? 0) > 0{
            self.lblName.text = "\(item.workoutDuration) min \(item.workoutName)"
        }else{
            self.lblName.text = "\(item.workoutName)"
        }
        
        self.lblWorkoutDate.text = item.dateOfWorkout.toDisplayBirthday()
        self.lblWorkoutType.text = item.workoutTypeTitle
        self.lblInstructorName.text = item.instructorName
        
        if item.instructorName.isEmpty || item.instructorName == "NULL"{
            self.lblInstructorName.text = ""
            self.instructorIndicatorView.isHidden = true
            self.lblWorkoutType.text = ""
        }else{
            self.instructorIndicatorView.isHidden = false
        }
        
        
        if item.distance >= 1{
            
            let unitP = PreferenceManager.shared.poolUnitInfo
            
            if unitP.unitPref == .metric{
                let distance = Helper.shared.distanceConvert(to: .meters, from: .yards, distance: item.distance)
                self.lblDistance.text = String(format: "%.0f meters", distance)
            }else{
                self.lblDistance.text = String(format: "%.0f yards", item.distance)
            }
        }else{
            self.lblDistance.text = ""
        }
        
    }
    
}
