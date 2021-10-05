//
//  InstructorVideoTVC.swift
//  Zygo
//
//  Created by Som on 28/06/21.
//  Copyright © 2021 Somparkash. All rights reserved.
//

import UIKit

class InstructorVideoTVC: UITableViewCell {
    
    static let identifier = "InstructorVideoTVC"
    
    @IBOutlet weak var btnBigPlay: UIButton!
    @IBOutlet weak var videoContentView: UIView!
    @IBOutlet weak var videoImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
