//
//  WorkoutTypeTVC.swift
//  Zygo
//
//  Created by Priya Gandhi on 04/02/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit

class WorkoutTypeTVC: UITableViewCell {
    
    static let identifier = "WorkoutTypeTVC"
    
    @IBOutlet weak var lblDifficulty : UILabel!
    @IBOutlet weak var lblRating : UILabel!
    @IBOutlet weak var lblRecentlyAdded : UILabel!
    
    @IBOutlet weak var downloadIcon : UIImageView!
    @IBOutlet weak var lblDownloadTitle : UILabel!
    @IBOutlet weak var btnDownload : UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setupDetailInfo(_ item: WorkoutDTO){
        
        let totalCounts = Double(item.thumbsUpCount+item.thumbsDownCount)
        //let difficultyCount = item.difficultyRatingsCount
        /*if difficultyCount < 2{
            self.lblRating.isHidden = true
            self.lblDifficulty.isHidden = true
            self.lblRecentlyAdded.isHidden = false
        }else*/ if totalCounts < 2{
            self.lblRating.isHidden = true
            self.lblDifficulty.isHidden = true
            self.lblRecentlyAdded.isHidden = false
        }else{
            self.lblRecentlyAdded.isHidden = true
            self.lblRating.isHidden = false
            self.lblDifficulty.isHidden = false
            
            let thumbsCount = Double(item.thumbsUpCount)/totalCounts * 100.0
            
            if thumbsCount != .nan{
                self.lblRating.text = "\(String(format: "%.0f", thumbsCount))%"
            }else{
                self.lblRating.text = "0.0%"
            }
            
            let rating = Double(item.difficultyRatingsTotal)/Double(item.difficultyRatingsCount)
            if rating.isNaN{
                let strRating = String(format: "%.1f", 0)
                let attString = NSMutableAttributedString(string: "\(strRating)/10")
                attString.addAttributes([
                    .font : UIFont.appMedium(with: 13),
                    .foregroundColor: UIColor.appTitleDarkColor()
                ], range: .init(location: 0, length: attString.string.count))
                attString.addAttributes([
                    .font : UIFont.appMedium(with: 27)
                ], range: .init(location: 0, length: strRating.count))
                self.lblDifficulty.attributedText = attString
            }else{
                let strRating = String(format: "%.1f", rating)
                let attString = NSMutableAttributedString(string: "\(strRating)/10")
                attString.addAttributes([
                    .font : UIFont.appMedium(with: 13),
                    .foregroundColor: UIColor.appTitleDarkColor()
                ], range: .init(location: 0, length: attString.string.count))
                attString.addAttributes([
                    .font : UIFont.appMedium(with: 27)
                ], range: .init(location: 0, length: strRating.count))
                self.lblDifficulty.attributedText = attString
            }
            
            
        }
    }
    
    func setupDefaultDownload(){
        self.lblDownloadTitle.text = "Download"
        self.downloadIcon.image = UIImage(named: "icon_download_tabbar")
    }
    
    func setupDownloadStaus(stauts: WorkoutDownloadStatus){
        switch stauts {
        case .downloaded:
            self.lblDownloadTitle.text = "Downloaded"
            self.downloadIcon.image = UIImage(named: "icon_downloaded")
        case .downloading:
            self.lblDownloadTitle.text = "Downloading"
            self.downloadIcon.image = UIImage(named: "icon_downloading")
        case .paused:
            self.lblDownloadTitle.text = "Paused"
            self.downloadIcon.image = UIImage(named: "icon_downloading")
        case .cancelled:
            self.lblDownloadTitle.text = "Download"
            self.downloadIcon.image = UIImage(named: "icon_download_tabbar")
        }
        
    }
    
}
