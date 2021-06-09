//
//  ShadowView.swift
//  LVLFi Hub
//
//  Created by Som on 25/07/19.
//  Copyright © 2019 Som. All rights reserved.
//

import UIKit

class ShadowSmallView: UIView {
    
    var contentView : UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    override func layoutSubviews() {
        self.xibSetup()
        super.layoutSubviews()
    }
    
    func xibSetup() {
        //Manage the Shadow view layers
        layer.masksToBounds = false
        
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOpacity = 0.4
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 3.0
       
        let radius: CGFloat = self.bounds.size.width / 2.0
        layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: radius).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = true ? UIScreen.main.scale : 1
        
        
    }
}
