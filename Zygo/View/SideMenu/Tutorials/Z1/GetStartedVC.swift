//
//  GetStartedVC.swift
//  Zygo
//
//  Created by Som on 21/10/21.
//  Copyright © 2021 Somparkash. All rights reserved.
//

import UIKit
import SimpleAnimation

//MARK: -
class GetStartedVC: UIViewController {
    
    @IBOutlet weak var lblTurnOnTransmitter: UILabel!
    
    @IBOutlet weak var mainScroller: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var headsetImageView: UIImageView!
    @IBOutlet weak var headsetVerticalImageView: UIImageView!
    
    @IBOutlet weak var lblVolumeUp: UILabel!
    @IBOutlet weak var lblHeadset: UILabel!
    
    @IBOutlet weak var transmitterImageView: UIImageView!
    @IBOutlet weak var transmitterVerticalImageView: UIImageView!
    
    @IBOutlet weak var lblOnOff: UILabel!
    @IBOutlet weak var lblTransmitter: UILabel!
    
    @IBOutlet weak var headsetOffVerticalImageView: UIImageView!
    
    @IBOutlet weak var lblDownOff: UILabel!
    @IBOutlet weak var lblHeadsetOff: UILabel!
    
    //MARK: - UIViewcontroller LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.headsetImageView.alpha = 0
        self.headsetVerticalImageView.alpha = 0
        self.lblVolumeUp.alpha = 0
        self.lblHeadset.alpha = 0
        
        self.transmitterImageView.alpha = 1
        self.transmitterVerticalImageView.alpha = 0
        
        self.lblOnOff.alpha = 0
        self.lblTransmitter.alpha = 0
        
        
        self.headsetOffVerticalImageView.alpha = 0
        self.lblDownOff.alpha = 0
        self.lblHeadsetOff.alpha = 0
        
        self.setupLabel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setupHeadsetAnimation()
    }
    
    //MARK: - Setups
    func setupHeadsetAnimation(){
        
        UIView.animate(withDuration: 1) {
            self.headsetImageView.alpha = 1.0
        } completion: { (complete) in
            
            self.lblVolumeUp.alpha = 1.0
            self.lblVolumeUp.slideIn(from: .right, x: ScreenSize.SCREEN_WIDTH, y: (ScreenSize.SCREEN_HEIGHT/2.0) - ((self.headsetVerticalImageView.frame.size.height/2) * 2), duration: 1.8) { (complete) in
                
            }
            
            self.headsetVerticalImageView.alpha = 1.0
            self.headsetVerticalImageView.slideIn(from: .left, x: 0, y: (ScreenSize.SCREEN_HEIGHT/2.0) - ((self.headsetVerticalImageView.frame.size.height/2) * 3), duration: 2) { (complete) in
                
                self.lblHeadset.alpha = 1.0
                self.lblHeadset.slideIn(from: .right, x: ScreenSize.SCREEN_WIDTH, y: (ScreenSize.SCREEN_HEIGHT - 100), duration: 1.8) { (complete) in
                    
                }
                
            }
            
        }
    }
    
    func setupTransmitterAnimation(){
        
        
        self.transmitterVerticalImageView.rotate()
        
        self.transmitterVerticalImageView.alpha = 1.0
        self.transmitterVerticalImageView.slideIn(from: .left, x: 0, y: (ScreenSize.SCREEN_HEIGHT/2.0) - ((self.transmitterVerticalImageView.frame.size.height/2) * 3), duration: 2) { (complete) in
        }
        
        self.lblOnOff.alpha = 1.0
        self.lblOnOff.slideIn(from: .right, x: ScreenSize.SCREEN_WIDTH, y: (ScreenSize.SCREEN_HEIGHT/2.0) - ((self.headsetVerticalImageView.frame.size.height/2) * 2), duration: 1.8) { (complete) in
            
            
            self.lblTransmitter.alpha = 1.0
            self.lblTransmitter.slideIn(from: .bottom, duration: 1.8) { (complete) in
                
            }
            
        }
    }
    
    func setupHeadsetOffAnimation(){
        
        self.headsetOffVerticalImageView.alpha = 1.0
        self.headsetOffVerticalImageView.slideIn(from: .none, x: ScreenSize.SCREEN_WIDTH, y: (ScreenSize.SCREEN_HEIGHT/3.0) - (self.headsetOffVerticalImageView.frame.size.height * 4), duration: 2) { (complete) in
        }
        
        self.lblDownOff.alpha = 1.0
        self.lblDownOff.slideIn(from: .right, x: ScreenSize.SCREEN_WIDTH, y: (ScreenSize.SCREEN_HEIGHT/2.0) - ((self.headsetOffVerticalImageView.frame.size.height/2) * 2), duration: 1.8) { (complete) in
            
            
            self.lblHeadsetOff.alpha = 1.0
            self.lblHeadsetOff.slideIn(from: .bottom, duration: 1.8) { (complete) in
                
            }
            
        }
    }
    
    func setupLabel(){
        
        let fullString = NSMutableAttributedString(string: "Place the transmitter next to the headset and turn it on by holding ")
        
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(named: "icon_power_button")
        imageAttachment.bounds = CGRect(x: 0, y: -3, width: 14.25, height: 18)
        
        let imageString = NSAttributedString(attachment: imageAttachment)
        
        fullString.append(imageString)
        fullString.append(NSAttributedString(string: " for 3 seconds."))
        
        //fullString.addAttribute(.font, value: UIFont.appMedium(with: 18.0), range: NSRange(location: 0, length: fullString.length))
        self.lblTurnOnTransmitter.attributedText = fullString
        
    }
    
    
    
    //MARK: - UIButton Actions
    @IBAction func backAction(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func pageControlValueChange(_ sender: UIPageControl){
        let x = sender.currentPage * Int(mainScroller.frame.size.width)
        mainScroller.setContentOffset(CGPoint(x: x, y: 0), animated: true)
    }
    
}

extension GetStartedVC: UIScrollViewDelegate{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let index = mainScroller.contentOffset.x/mainScroller.frame.size.width
        self.pageControl.currentPage = Int(index)
        
        if index == 1{
            if self.lblTransmitter.alpha == 0{
                self.setupTransmitterAnimation()
            }
        }
        
        if index == 2{
            if self.lblHeadsetOff.alpha == 0{
                self.setupHeadsetOffAnimation()
            }
        }
        
    }
    
}
