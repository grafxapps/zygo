//
//  WorkoutInfoTVC.swift
//  Zygo
//
//  Created by Priya Gandhi on 24/01/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit
import SDWebImage

class WorkoutInfoTVC: UITableViewCell {
    
    static let identifier = "WorkoutInfoTVC"
    
    @IBOutlet weak var lblWorkoutName: UILabel!
    @IBOutlet weak var lblInstructorName: UILabel!
    @IBOutlet weak var lblWorkoutType: UILabel!
    @IBOutlet weak var workoutImage: UIImageView!
    @IBOutlet weak var workoutCompletedIcon: UIImageView!
    
    @IBOutlet weak var lblDifficultyLevel: UILabel!
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var lblInfoTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.infoView.transform = CGAffineTransform(rotationAngle: -0.785398)
        //self.featuredView.layer.cornerRadius = 10.0
        //self.featuredView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setupWorkoutInfo(item: WorkoutDTO){
        //self.featuredView.isHidden = true
        self.infoView.isHidden = true
        
        self.lblWorkoutName.text = "\("\(String(format: "%.f", item.workoutDuration)) min") \(item.workoutName)"
        self.lblInstructorName.text = "\(item.instructor.instructorFirstName) \(item.instructor.instructorLastName)"
        
        self.lblWorkoutType.text = item.workoutType.workoutType
        //self.workoutImage.image = nil
        self.workoutImage.backgroundColor = .white
        if !item.thumbnailURL.isEmpty{
            /*self.workoutImage.af.setImage(withURL: URL(string: item.thumbnailURL.getImageURL())!, cacheKey: item.thumbnailURL.getImageURL(), placeholderImage: nil, progress: { (progress) in
                
            }, progressQueue: .main, imageTransition: .crossDissolve(0.4), runImageTransitionIfCached: false) { (response) in
                
            }*/
            self.workoutImage.sd_setImage(with: URL(string: item.thumbnailURL.getImageURL()), placeholderImage: nil, options: .progressiveLoad, completed: nil)
        }
        
        if item.difficultyLevel.title.lowercased() == "all levels"{
            self.lblDifficultyLevel.text = ""
        }else{
            self.lblDifficultyLevel.text = item.difficultyLevel.title
        }
        
        self.setupForLabels(item: item)
        
        self.workoutCompletedIcon.isHidden = true
        let completedWorkouts = PreferenceManager.shared.completedWorkouts
        if completedWorkouts.contains(item.workoutId){
            self.workoutCompletedIcon.isHidden = false
        }
        
        self.layoutIfNeeded()
    }
    
    func setupForLabels(item: WorkoutDTO){
        
        self.lblInfoTitle.text = ""
        self.infoView.isHidden = true
        
        if !item.introVideo.isEmpty || !item.closingVideo.isEmpty{
            self.infoView.isHidden = false
            self.infoView.backgroundColor = .appNewBlackColor()
            self.lblInfoTitle.text = "VIDEO"
            self.lblInfoTitle.textColor = .white
        }
        
        let currentDate = DateHelper.shared.currentLocalDateTime
        print("Current Date: \(currentDate)")
        if let previousDate = Calendar.current.date(byAdding: .day, value: -3, to: currentDate){
            print("Previous Date: \(previousDate)")
            let createdDate = item.createdAt
            if createdDate.compare(previousDate) == .orderedDescending{
                
                self.infoView.isHidden = false
                self.infoView.backgroundColor = .appNewInfoColor()
                self.lblInfoTitle.text = "NEW"
                self.lblInfoTitle.textColor = .white
            }
        }
        
        
        if item.isTrending{
            self.infoView.isHidden = false
            self.infoView.backgroundColor = .appPopularInfoColor()
            self.lblInfoTitle.text = "POPULAR"
            self.lblInfoTitle.textColor = .appNewInfoColor()
        }
        
        if item.isFeatured{
            self.infoView.isHidden = false
            self.infoView.backgroundColor = .appBlueColor()
            self.lblInfoTitle.text = "FEATURED"
            self.lblInfoTitle.textColor = .white
        }
        //item.createdAt
        
    }
    
}
