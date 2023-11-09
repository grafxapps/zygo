//
//  DownloadsTVC.swift
//  Zygo
//
//  Created by Priya Gandhi on 24/01/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit

class DownloadsTVC: UITableViewCell {
    
    @IBOutlet weak var lblDownloadStatus: UILabel!
    @IBOutlet weak var btnDownload: UIButton!
    @IBOutlet weak var downloadView: UIView!
    
    @IBOutlet weak var lblWorkoutName: UILabel!
    @IBOutlet weak var lblInstructorName: UILabel!
    @IBOutlet weak var lblWorkoutType: UILabel!
    @IBOutlet weak var workoutImage: UIImageView!
    
    @IBOutlet weak var lblDifficultyLevel: UILabel!
    
    @IBOutlet weak var infoView: UIView!
    
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var btnDelete: UIButton!
    
    private var leftSwipe: UISwipeGestureRecognizer?
    private var rightSwipe: UISwipeGestureRecognizer?
    
    @IBOutlet weak var lblInfoTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setupGestures()
        
        self.infoView.transform = CGAffineTransform(rotationAngle: -0.785398)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupWorkoutInfo(item: WorkoutDTO){
        self.lblWorkoutName.text = "\(String(format: "%.f", item.workoutDuration)) min \(item.workoutName)"
        self.lblInstructorName.text = "\(item.instructor.instructorFirstName) \(item.instructor.instructorLastName)"
        
        self.lblWorkoutType.text = item.workoutType.workoutType
        
        self.workoutImage.image = nil
        self.workoutImage.backgroundColor = .white
        if !item.thumbnailURL.isEmpty{
            self.workoutImage.sd_setImage(with: URL(string: item.thumbnailURL.getImageURL()), placeholderImage: nil, options: .refreshCached, completed: nil)
        }
        
        if item.difficultyLevel.title.lowercased() == "all levels"{
            self.lblDifficultyLevel.text = ""
        }else{
            self.lblDifficultyLevel.text = item.difficultyLevel.title
        }
        
        self.setupForLabels(item: item)
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
        if let previousDate = Calendar.current.date(byAdding: .day, value: -3, to: currentDate){
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
    
    func setupGestures(){
        workoutImage.isUserInteractionEnabled = true
        leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.leftGestureAction(_:)))
        leftSwipe?.direction = .left
        workoutImage.addGestureRecognizer(leftSwipe!)
        
        rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.rightGesrureAction(_:)))
        rightSwipe?.direction = .right
        workoutImage.addGestureRecognizer(rightSwipe!)
        
    }
    
    func showDeleteView(){
        UIView.animate(withDuration: 0.2) {
            self.imageViewLeadingConstraint.constant = -60
            self.imageViewTrailingConstraint.constant = 60
            self.layoutIfNeeded()
        }
        
    }
    
    func isDeleteViewHidden() -> Bool{
        if self.imageViewLeadingConstraint.constant == 0{
            return true
        }
        
        return false
    }
    
    func hideDeleteView(){
        UIView.animate(withDuration: 0.2) {
            self.imageViewLeadingConstraint.constant = 0
            self.imageViewTrailingConstraint.constant = 0
            self.layoutIfNeeded()
        }
    }
    
    //MARK: - Gesture Actions
    @objc func leftGestureAction(_ gesture: UISwipeGestureRecognizer){
        self.showDeleteView()
    }
    
    @objc func rightGesrureAction(_ gesture: UISwipeGestureRecognizer){
        self.hideDeleteView()
    }
    
}
