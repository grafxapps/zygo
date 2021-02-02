//
//  SubscriptionViewController.swift
//  Zygo
//
//  Created by Priya Gandhi on 23/01/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class SubscriptionViewController: UIViewController {
   
    @IBOutlet weak var viewSubscription : UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
       // self.setupUI()
    }
    
    func setupUI()  {
        Helper.shared.setupViewLayer(sender: self.viewSubscription, isSsubScriptionView: true);
    }
}


