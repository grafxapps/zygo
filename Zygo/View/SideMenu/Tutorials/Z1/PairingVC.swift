//
//  PairingVC.swift
//  Zygo
//
//  Created by Som on 21/10/21.
//  Copyright © 2021 Somparkash. All rights reserved.
//

import UIKit
import SimpleAnimation

class PairingVC: UIViewController {
    
    @IBOutlet weak var mainScroller: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var bluetoothImageView: UIImageView!
    @IBOutlet weak var lblBluetooth: UILabel!
    
    @IBOutlet weak var greenIndicatorView: UIImageView!
    @IBOutlet weak var lbl1: UILabel!
    @IBOutlet weak var lbl2: UILabel!
    
    private var isBack: Bool = false
    
    //MARK: - UIViewcontroller LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lbl1.alpha = 0
        self.lbl2.alpha = 0
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.animateBluetooth()
    }
    
    //MARK: - Setups
    func animateBluetooth(){
        
        self.lblBluetooth.alpha = 0.0
        self.bluetoothImageView.alpha = 0.0
        
        self.bluetoothImageView.alpha = 1.0
        
        self.bluetoothImageView.slideIn(from: .left, duration: 1.5) { (complete) in
            
            self.lblBluetooth.alpha = 0.0
            self.lblBluetooth.slideIn(from: .right, duration: 1.5) { (complete) in
                
            }
        }
        
    }
    
    func animateSecondPage(){
        self.lbl1.alpha = 0
        self.lbl2.alpha = 0
        self.isBack = false
        self.animateGreenIndicator()
        
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        self.perform(#selector(self.lbl1SlideIn), with: nil, afterDelay: 0.4)
    }
    
    @objc func lbl1SlideIn(){
        self.lbl1.alpha = 1
        self.lbl1.slideIn(from: .bottom, duration: 1.5) { (complete) in
            NSObject.cancelPreviousPerformRequests(withTarget: self)
            self.perform(#selector(self.lbl2SlideIn), with: nil, afterDelay: 1)
            
        }
    }
    
    @objc func lbl2SlideIn(){
        self.lbl2.alpha = 1
        self.isBack = true
        self.greenIndicatorView.alpha = 1.0
        self.lbl2.slideIn(from: .bottom, duration: 1.5) { (complete) in
            
        }
    }
    
    func animateGreenIndicator(){
        UIView.animate(withDuration: 1) {
            if self.greenIndicatorView.alpha == 0{
                self.greenIndicatorView.alpha = 1.0
            }else{
                self.greenIndicatorView.alpha = 0.0
            }
        } completion: { (complete) in
            if !self.isBack{
                self.animateGreenIndicator()
            }
            
        }
    }
    
    //MARK: - UIButton Actions
    @IBAction func backAction(_ sender: UIButton){
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        self.isBack = true
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func pageControlValueChange(_ sender: UIPageControl){
        let x = sender.currentPage * Int(mainScroller.frame.size.width)
        mainScroller.setContentOffset(CGPoint(x: x, y: 0), animated: true)
    }
    
}

extension PairingVC: UIScrollViewDelegate{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let index = mainScroller.contentOffset.x/mainScroller.frame.size.width
        self.pageControl.currentPage = Int(index)
        if index == 1{
            if self.lbl1.alpha != 1{
                self.animateSecondPage()
            }
        }else{
            //self.lbl1.alpha = 0
            //self.lbl2.alpha = 0
            //self.isBack = true
        }
        
    }
    
}
