//
//  BarCVC.swift
//  Zygo
//
//  Created by Som on 05/03/22.
//  Copyright © 2022 Somparkash. All rights reserved.
//

import UIKit

class BarCVC: UICollectionViewCell {
    
    static let identifier = "BarCVC"
    
    @IBOutlet weak var barHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblBottom: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setupBar(at current: Double, max: Double, barFullHeight: Double){
        
        let barHeight = current * (barFullHeight/max)
        barHeightConstraint.constant = CGFloat(barHeight)
    }
}
