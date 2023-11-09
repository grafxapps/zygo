//
//  WokoutFeedbackInfoTVC.swift
//  Zygo
//
//  Created by Som on 26/03/22.
//  Copyright © 2022 Somparkash. All rights reserved.
//

import UIKit

class WokoutFeedbackInfoTVC: UITableViewCell {
    
    static let identifier = "WokoutFeedbackInfoTVC"
    
    @IBOutlet weak var lblWorkoutName: UILabel!
    @IBOutlet weak var lblInstructorName: UILabel!
    @IBOutlet weak var lblWorkoutType: UILabel!
    @IBOutlet weak var workoutImage: UIImageView!
    
    @IBOutlet weak var lblDifficultyLevel: UILabel!
    
    @IBOutlet weak var lblFeedbackInfoTitles: UILabel!
    @IBOutlet weak var lblFeedbackInfoValues: UILabel!
    
    @IBOutlet weak var workoutInfoView: UIView!
    @IBOutlet weak var feedbackInfoView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        workoutInfoView.layer.cornerRadius = 10.0
        workoutInfoView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        feedbackInfoView.layer.cornerRadius = 10.0
        feedbackInfoView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupWorkoutInfo(item: WorkoutDTO, logItem: WorkoutLogDTO){
        
        self.lblWorkoutName.text = "\("\(String(format: "%.f", item.workoutDuration)) min") \(item.workoutName)"
        self.lblInstructorName.text = "\(item.instructor.instructorFirstName) \(item.instructor.instructorLastName)"
        
        self.lblWorkoutType.text = item.workoutType.workoutType
        //self.workoutImage.image = nil
        self.workoutImage.backgroundColor = .white
        if !item.thumbnailURL.isEmpty{

            self.workoutImage.sd_setImage(with: URL(string: item.thumbnailURL.getImageURL()), placeholderImage: nil, options: .progressiveLoad, completed: nil)
        }
        
        if item.difficultyLevel.title.lowercased() == "all levels"{
            self.lblDifficultyLevel.text = ""
        }else{
            self.lblDifficultyLevel.text = item.difficultyLevel.title
        }
        
        
        var titles: String = ""
        var values: String = ""
        if logItem.timeInWater > 0{
            titles = "Time in water\n"
            let min = Int(logItem.timeInWater/60)
            let sec = Int(logItem.timeInWater.remainder(dividingBy: 60))
            if min < 1{
                values = "\(sec) sec\n"
            }else{
                if sec > 0{
                    values = "\(min) min \(sec) sec\n"
                }else{
                    values = "\(min) min\n"
                }
                
            }
        }
        
        
        if logItem.laps > 0{
            titles += "Laps\n"
            values += "\(logItem.laps)\n"
        }
        
        if logItem.poolLength > 0{
            titles += "Pool length\n"
            values += "\(logItem.poolLength) \(logItem.poolLengthUnit)\n"
        }
        
        if logItem.distance > 0{
            var totalDistance: Double = 0
            var strUnit = ""
            let poolInfo = PreferenceManager.shared.poolUnitInfo
            if poolInfo.unitPref == .metric{
                //Meter
                if logItem.distance < 1094{
                    totalDistance = Helper.shared.distanceConvert(to: .meters ,from: .yards, distance: logItem.distance)
                    strUnit = "meters"
                    
                    if totalDistance >= 1{
                        titles += "Distance\n"
                        values += String(format: "%.0f \(strUnit)\n", totalDistance)
                    }
                }else{
                    totalDistance = Helper.shared.distanceConvert(to: .kilometers ,from: .yards, distance: logItem.distance)
                    strUnit = "km"
                    
                    if totalDistance > 0{
                        titles += "Distance\n"
                        values += String(format: "%.1f \(strUnit)\n", totalDistance)
                    }
                }
                
            }else{
                if logItem.distance < 1760{
                    //Yards
                    totalDistance = Helper.shared.distanceConvert(to: .yards ,from: .yards, distance: logItem.distance)
                    strUnit = "yards"
                    if totalDistance >= 1{
                        titles += "Distance\n"
                        values += String(format: "%.0f \(strUnit)\n", totalDistance)
                    }
                    
                }else{
                    //miles
                    totalDistance = Helper.shared.distanceConvert(to: .miles ,from: .yards, distance: logItem.distance)
                    strUnit = "miles"
                    
                    if totalDistance > 0{
                        titles += "Distance\n"
                        values += String(format: "%.1f \(strUnit)\n", totalDistance)
                    }
                }
                
            }
        }
        
        if logItem.strokeValue > 0{
            titles += "Stroke rate\n"
            values += "\(logItem.strokeValue)/minute\n"
        }
        
        if !logItem.city.isEmpty{
            titles += "Location\n"
            values += "\(logItem.city)\n"
        }
        
        titles += "Date"
        values += "\(logItem.dateOfWorkout.toFormat(format: "MMM d, yyyy"))"
        
        self.lblFeedbackInfoTitles.text = titles
        self.lblFeedbackInfoValues.text = values
        
        
        self.layoutIfNeeded()
    }
    

    
}
