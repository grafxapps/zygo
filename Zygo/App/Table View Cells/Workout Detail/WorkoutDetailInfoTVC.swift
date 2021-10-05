//
//  WorkoutDetailInfoTVC.swift
//  Zygo
//
//  Created by Priya Gandhi on 04/02/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit

class WorkoutDetailInfoTVC: UITableViewCell {
    
    static let identifier = "WorkoutDetailInfoTVC"
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var instructorImageView: UICircleImageView!
    @IBOutlet weak var lblInstructorName: UILabel!
    @IBOutlet weak var lblDesc: UITextView!
    @IBOutlet weak var lblLevel: UILabel!
    @IBOutlet weak var levelView: UIView!
    @IBOutlet weak var btnInstructor: UIButton!

    @IBOutlet weak var descriptionHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupDetailInfo(_ item: WorkoutDTO){
        
        self.lblTitle.text = "\("\(String(format: "%.f", item.workoutDuration)) min") \(item.workoutName)"
        self.lblInstructorName.text = "\(item.instructor.instructorFirstName) \(item.instructor.instructorLastName)"
            
        self.instructorImageView.image = UIImage(named: "icon_default")
        if !item.instructor.instructorPic.isEmpty{
            self.instructorImageView.sd_setImage(with: URL(string: item.instructor.instructorPic.getImageURL()), placeholderImage: UIImage(named: "icon_default"), options: .refreshCached, completed: nil)
            
        }
        
        if item.difficultyLevel.title.lowercased() == "all levels"{
            self.lblLevel.text = ""
            self.levelView.isHidden = true
        }else{
            self.lblLevel.text = item.difficultyLevel.title
            self.levelView.isHidden = false
        }
        
        let newDescription = item.workoutDescription.htmlToAttributedString
        newDescription?.addAttribute(.foregroundColor, value: self.lblDesc.textColor!, range: NSRange(location: 0, length: newDescription?.string.count ?? 0))
        
        self.lblDesc.attributedText = newDescription
        if item.workoutDescription.isDescriptionEmpty(){
            self.descriptionHeightConstraint.priority = .defaultHigh
            self.descriptionHeightConstraint.constant = 0.0
        }
        self.lblDesc.layoutIfNeeded()
        self.contentView.layoutIfNeeded()
        self.layoutIfNeeded()
    }
    
}
