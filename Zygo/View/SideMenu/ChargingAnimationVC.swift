//
//  ChargingAnimationVC.swift
//  Zygo
//
//  Created by Som on 08/01/22.
//  Copyright © 2022 Somparkash. All rights reserved.
//

import UIKit

//MARK: -
class ChargingAnimationVC: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lbl1: UILabel!
    @IBOutlet weak var lbl2: UILabel!
    @IBOutlet weak var lbl3: UILabel!
    @IBOutlet weak var lbl4: UILabel!
    
    @IBOutlet weak var yelloIndicatorView: UIImageView!
    
    private var isBack: Bool = false
    
    //MARK: - UIViewController LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideAllContent()
        self.startAnimation()
    }
    
    
    //MARK: - Setups
    func hideAllContent(){
        self.imageView.alpha = 0.0
        self.lbl1.alpha = 0.0
        self.lbl2.alpha = 0.0
        self.lbl3.alpha = 0.0
        self.lbl4.alpha = 0.0
    }
    
    func startAnimation(){
        
        UIView.animate(withDuration: 2) {
            self.imageView.alpha = 1.0
        } completion: { (complete) in
            self.animateYello()
            
            UIView.animate(withDuration: 2) {
                self.lbl1.alpha = 1.0
            } completion: { (complete) in
            
                UIView.animate(withDuration: 2) {
                    self.lbl2.alpha = 1.0
                } completion: { (complete) in
                 
                    UIView.animate(withDuration: 2) {
                        self.lbl3.alpha = 1.0
                    } completion: { (complete) in
                    
                        UIView.animate(withDuration: 2) {
                            self.lbl4.alpha = 1.0
                        } completion: { (complete) in
                            
                        }
                    }
                    
                }
                
            }

        }
    }
    
    func animateYello(){
        UIView.animate(withDuration: 3) {
            if self.yelloIndicatorView.alpha == 0{
                self.yelloIndicatorView.alpha = 1.0
            }else{
                self.yelloIndicatorView.alpha = 0.0
            }
        } completion: { (complete) in
            if !self.isBack{
                self.animateYello()
            }
            
        }
    }
    
    
    //MARK: - UIButton Actions
    @IBAction func backAction(_ sender: UIButton){
        self.isBack = true
        self.view.layer.removeAllAnimations()
        self.navigationController?.popViewController(animated: true)
    }
    
    
}
