//
//  LikeCVC.swift
//  Zygo
//
//  Created by Priya Gandhi on 13/02/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit

class LikeCVC: UICollectionViewCell {
    
    @IBOutlet weak var btnTitle : UIButton!
    static let identifier = "LikeCVC"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.btnTitle.layer.cornerRadius = 5.0
        self.btnTitle.layer.masksToBounds = true
        // Initialization code
    }

}
