//
//  HallOfFameTVC.swift
//  Zygo
//
//  Created by Som Parkash on 26/11/23.
//  Copyright © 2023 Somparkash. All rights reserved.
//

import UIKit
import SDWebImage

class HallOfFameTVC: UITableViewCell {
    
    static let identifier = "HallOfFameTVC"
    
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblValue: UILabel!
    @IBOutlet weak var lblCreatedDate: UILabel!
    @IBOutlet weak var lblNumber: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var createdView: UIView!
    @IBOutlet weak var fameContentView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.profileImageView.layer.cornerRadius = 16.0
        self.profileImageView.layer.masksToBounds = true
        self.fameContentView.addShadow(location: .center)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func loadData(_ fameItem: HallOfFameModel, type: HallOfFameModel.FameType, time: HallOfFameModel.FameTime){
        self.lblUserName.text = fameItem.userName
        self.lblLocation.text = fameItem.location
        switch type{
        case .classes:
            if fameItem.totalClasses == 1{
                self.lblValue.text = "\(fameItem.totalClasses) Class"
            }else{
                self.lblValue.text = "\(fameItem.totalClasses) Classes"
            }
        case .distance:
            if fameItem.totalDistance == 1{
                self.lblValue.text = String(format: "%.1f mile", fameItem.totalDistance)
            }else{
                self.lblValue.text = String(format: "%.1f miles", fameItem.totalDistance)
            }
        }
        
        
        switch time{
        case .all:
            self.createdView.isHidden = false
        case .month:
            self.createdView.isHidden = true
        }
        
        self.lblCreatedDate.text = fameItem.createdDate?.convertToFormat("MMM yyyy")
        self.profileImageView.sd_setImage(with: URL(string: fameItem.profilePic), placeholderImage: UIImage(named: "icon_default"))
        
    }
    
}
