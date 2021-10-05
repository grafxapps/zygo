//
//  InstructorProfileTVC.swift
//  Zygo
//
//  Created by Som on 24/06/21.
//  Copyright © 2021 Somparkash. All rights reserved.
//

import UIKit

class InstructorProfileTVC: UITableViewCell {
    
    static let identifier = "InstructorProfileTVC"
    
    @IBOutlet weak var btnInsta: UIButton!
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
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
        self.lblName.text = "\(item.instructorFirstName) \(item.instructorLastName)"
        
        let newDescription = item.instructorBio.htmlToAttributedString
        newDescription?.addAttribute(.foregroundColor, value: self.lblDescription.textColor!, range: NSRange(location: 0, length: newDescription?.string.count ?? 0))
        
        self.lblDescription.attributedText = newDescription
        
        self.profileImageView.image = UIImage(named: "icon_default")
        if !item.instructorPic.isEmpty{
            self.profileImageView.sd_setImage(with: URL(string: item.instructorPic.getImageURL()), placeholderImage: UIImage(named: "icon_default"), options: .refreshCached, completed: nil)
        }
        
        self.btnInsta.isHidden = false
        if item.socialMedia.isEmpty{
            self.btnInsta.isHidden = true
        }
    }
}
