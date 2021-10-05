//
//  InstructorTVC.swift
//  Zygo
//
//  Created by Som on 10/08/21.
//  Copyright © 2021 Somparkash. All rights reserved.
//

import UIKit

class InstructorTVC: UITableViewCell {
    
    static let identifier = "InstructorTVC"
    
    @IBOutlet weak var lblFName: UILabel!
    @IBOutlet weak var lblLName: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setupInfo(_ item: WorkoutInstructorDTO){
        self.lblFName.text = item.instructorFirstName
        self.lblLName.text = item.instructorLastName
        
        self.profileImageView.image = UIImage(named: "icon_default")
        if !item.instructorPic.isEmpty{
            self.profileImageView.sd_setImage(with: URL(string: item.instructorPic.getImageURL()), placeholderImage: UIImage(named: "icon_default"), options: .refreshCached, completed: nil)
        }
        
    }
}
