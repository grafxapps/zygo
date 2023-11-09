//
//  PlaylistViewMoreTVC.swift
//  Zygo
//
//  Created by Som on 08/07/21.
//  Copyright © 2021 Somparkash. All rights reserved.
//

import UIKit

class PlaylistViewMoreTVC: UITableViewCell {

    static let identifier = "PlaylistViewMoreTVC"
    
    @IBOutlet weak var btnViewMore: UIButton!
    @IBOutlet weak var viewMoreContentView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
