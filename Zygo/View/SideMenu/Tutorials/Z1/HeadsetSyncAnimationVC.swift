//
//  HeadsetSyncAnimationVC.swift
//  Zygo
//
//  Created by Som Parkash on 27/06/23.
//  Copyright © 2023 Somparkash. All rights reserved.
//

import UIKit

//MARK: -
class HeadsetSyncAnimationVC: UIViewController {
    
    @IBOutlet weak var headsetImageView: UIImageView!
    @IBOutlet weak var radioImageView: UIImageView!
    
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var headesetSyncDistance: UIImageView!
    
    //MARK: - UIViewcontroller LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupSyncAnimation()
    }
    
    
    //MARK: - Setups
    func setupUI(){
        self.lblInfo.alpha = 0
        self.headesetSyncDistance.alpha = 0
    }
    
    func setupSyncAnimation(){
        
        self.headsetImageView.rotate()
        self.headsetImageView.slideIn(from: .left, x: 0, y: -100, duration: 1.8) { (complete) in
            
        }
        
        self.lblInfo.alpha = 1.0
        self.lblInfo.slideIn(from: .right, x: ScreenSize.SCREEN_WIDTH, y: (ScreenSize.SCREEN_HEIGHT/2.0), duration: 1.8) { (complete) in
            NSObject.cancelPreviousPerformRequests(withTarget: self)
            self.perform(#selector(self.distanceLabelSlideIn), with: nil, afterDelay: 1.0)
        }
    }
    
    @objc func distanceLabelSlideIn(){
        self.headesetSyncDistance.alpha = 1.0
        self.headesetSyncDistance.slideIn(from: .left, x: 0, y: (ScreenSize.SCREEN_HEIGHT/2.0), duration: 1.25) { complete in
            
        }
    }
    
    //MARK: - UIButton Actions
    @IBAction func backAction(){
        self.navigationController?.popViewController(animated: true)
    }
    
}
