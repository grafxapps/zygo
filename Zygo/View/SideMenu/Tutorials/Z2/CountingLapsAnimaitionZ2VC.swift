//
//  CountingLapsAnimaitionZ2VC.swift
//  Zygo
//
//  Created by Som Parkash on 19/01/25.
//  Copyright © 2025 Somparkash. All rights reserved.
//

import UIKit
import SimpleAnimation
import AVFoundation

class CountingLapsAnimaitionZ2VC: UIViewController {
    
    //@IBOutlet weak var lblTurnOnTransmitter: UILabel!
    
    @IBOutlet weak var mainScroller: UIScrollView!
    //@IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var headsetImageView: UIImageView!
    @IBOutlet weak var headsetVerticalImageView: UIImageView!
    @IBOutlet weak var headsetVerticalLeftReferenceImageView: UIImageView!
    @IBOutlet weak var headsetVerticalBottomReferenceImageView: UIImageView!
    @IBOutlet weak var headsetVerticalHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblStartAWorkout: UILabel!
    @IBOutlet weak var lblVolumeUp: UILabel!
    @IBOutlet weak var lblHeadset: UILabel!
    @IBOutlet weak var lblWontCountLaps: UILabel!
    @IBOutlet weak var startCountingContinueView: UIView!
    
    @IBOutlet weak var headset2ImageView: UIImageView!
    @IBOutlet weak var headset2VerticalImageView: UIImageView!
    @IBOutlet weak var headset2VerticalHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblStart2AWorkout: UILabel!
    @IBOutlet weak var lblVolumeUp2: UILabel!
    @IBOutlet weak var lblHeadset2: UILabel!
    @IBOutlet weak var lblWontCountLaps2: UILabel!
    @IBOutlet weak var startCountingContinueView2: UIView!
    
    @IBOutlet weak var headset3ImageView: UIImageView!
    @IBOutlet weak var lblRestart: UILabel!
    @IBOutlet weak var lblPressAgain: UILabel!
    //@IBOutlet weak var lblPressAndHoldMinus: UILabel!
    //@IBOutlet weak var lblPressAndHoldMinusTopContraint: NSLayoutConstraint!
    @IBOutlet weak var lblPressAndHoldPlus: UILabel!
    @IBOutlet weak var headset3VerticalImageView: UIImageView!
    @IBOutlet weak var headset3VerticalHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var headset4VerticalImageView: UIImageView!
    @IBOutlet weak var headset4VerticalHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var headset4VerticalTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblContinue: UILabel!
    @IBOutlet weak var restartView: UIView!
    
    
    private var player: AVPlayer?
    
    //MARK: - UIViewcontroller LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.resetUI()
        self.setupLabel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setupStartAWorkoutAnimation()
    }
    
    //MARK: - Setups
    func resetUI(){
        self.headsetImageView.alpha = 0
        self.headsetVerticalImageView.alpha = 0
        self.lblStartAWorkout.alpha = 0
        self.lblVolumeUp.alpha = 0
        self.lblHeadset.alpha = 0
        self.lblWontCountLaps.alpha = 0
        self.startCountingContinueView.alpha = 0
        
        self.headset2ImageView.alpha = 0
        self.headset2VerticalImageView.alpha = 0
        self.lblStart2AWorkout.alpha = 0
        self.lblVolumeUp2.alpha = 0
        self.lblHeadset2.alpha = 0
        self.lblWontCountLaps2.alpha = 0
        self.startCountingContinueView2.alpha = 0
        
        self.lblRestart.alpha = 0
        self.lblPressAgain.alpha = 0
        //self.lblPressAndHoldMinus.alpha = 0
        self.lblPressAndHoldPlus.alpha = 0
        self.headset3VerticalImageView.alpha = 0
        self.headset4VerticalImageView.alpha = 0
        self.lblContinue.alpha = 0
        self.restartView.alpha = 0
        
        self.headset4VerticalTopConstraint.priority = UILayoutPriority(250.0)
        self.headset4VerticalHeightConstraint.constant = 0
        self.headset3VerticalHeightConstraint.constant = 0
        self.headset2VerticalHeightConstraint.constant = 0
        self.headsetVerticalHeightConstraint.constant = 0
        //self.lblPressAndHoldMinusTopContraint.constant = 5
        
        self.view.layoutIfNeeded()
    }
    
    func setupStartAWorkoutAnimation(){
        
        UIView.animate(withDuration: 1) {
            self.headsetImageView.alpha = 1.0
            self.lblStartAWorkout.alpha = 1.0
        } completion: { (complete) in
            
            UIView.animate(withDuration: 1) {
                self.lblVolumeUp.alpha = 1.0
                
                self.headsetVerticalImageView.alpha = 1.0

                self.headsetVerticalHeightConstraint.constant = self.headsetVerticalImageView.frame.size.height
                self.view.layoutIfNeeded()
                
            } completion: { (complete) in
                
                self.play(sound: .on)
                UIView.animate(withDuration: 1) {
                    self.lblHeadset.alpha = 1.0
                    
                } completion: { (complete) in
                    
                    UIView.animate(withDuration: 1) {
                        self.lblWontCountLaps.alpha = 1.0
                        
                    } completion: { (complete) in
                        
                        self.startCountingContinueView.slideIn(from: .left, duration: 1.8) { (complete) in
                            
                        }
                    }
                }
            }
        }
    }
    
    func setupCompleteAWorkoutAnimation(){
        
        UIView.animate(withDuration: 1) {
            self.headset2ImageView.alpha = 1.0
            self.lblStart2AWorkout.alpha = 1.0
        } completion: { (complete) in
            
            UIView.animate(withDuration: 1) {
                self.lblVolumeUp2.alpha = 1.0
                
                self.headset2VerticalImageView.alpha = 1.0

                self.headset2VerticalHeightConstraint.constant = self.headsetVerticalImageView.frame.size.height
                self.view.layoutIfNeeded()
                
            } completion: { (complete) in
                
                self.play(sound: .off)
                
                UIView.animate(withDuration: 1) {
                    self.lblHeadset2.alpha = 1.0
                    
                } completion: { (complete) in
                    
                    UIView.animate(withDuration: 1) {
                        self.lblWontCountLaps2.alpha = 1.0
                        
                    } completion: { (complete) in
                        
                        self.startCountingContinueView2.slideIn(from: .left, duration: 1.8) { (complete) in
                            
                        }
                    }
                }
            }
        }
    }
        
    func setupRestartAnimation(){
        UIView.animate(withDuration: 1) {
            self.headset3ImageView.alpha = 1.0
            self.lblRestart.alpha = 1.0
        } completion: { (complete) in
            
            UIView.animate(withDuration: 2.0) {
                self.lblPressAgain.alpha = 1.0
                self.headset3VerticalImageView.alpha = 1.0
                
                self.headset3VerticalHeightConstraint.constant = self.headsetVerticalLeftReferenceImageView.frame.size.height
                self.view.layoutIfNeeded()
            } completion: { compelte in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
                    UIView.animate(withDuration: 1.5) {
                        
                        self.headset3VerticalImageView.alpha = 0.0
                        
                        self.lblPressAndHoldPlus.alpha = 1.0
                        self.headset4VerticalImageView.alpha = 1.0
                        
                        self.headset4VerticalHeightConstraint.constant = self.headsetVerticalBottomReferenceImageView.frame.size.height
                        //self.headset4VerticalTopConstraint.priority = UILayoutPriority(999)
                        self.view.layoutIfNeeded()
                        
                    } completion: { (complete) in
                        
                        UIView.animate(withDuration: 1) {
                            
                            self.lblContinue.alpha = 1.0
                            
                        } completion: { (complete) in
                            
                            self.restartView.slideIn(from: .left, duration: 1.8) { (complete) in
                                
                            }
                            
                        }
                        
                        /*UIView.animate(withDuration: 2) {
                         //self.headset4VerticalImageView.alpha = 0.0
                         //self.lblPressAndHoldMinus.alpha = 0.0
                         
                         //self.lblPressAndHoldPlus.alpha = 1.0
                         //self.lblPressAndHoldMinusTopContraint.constant = -(self.lblPressAndHoldMinus.frame.size.height + 5.0)
                         self.view.layoutIfNeeded()
                         
                         } completion: { (complete) in
                         
                         }*/
                        
                        /*UIView.animate(withDuration: 2.0) {
                         
                         self.headset3VerticalImageView.alpha = 1.0
                         
                         self.headset3VerticalHeightConstraint.constant = self.headsetVerticalImageView.frame.size.height
                         self.view.layoutIfNeeded()
                         
                         } completion: { (complete) in
                         
                         UIView.animate(withDuration: 1) {
                         
                         self.lblContinue.alpha = 1.0
                         
                         } completion: { (complete) in
                         
                         self.restartView.slideIn(from: .left, duration: 1.8) { (complete) in
                         
                         }
                         
                         }
                         
                         }*/
                        
                    }
                }
                
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
        //sself.lblTurnOnTransmitter.attributedText = fullString
        
    }
    
    
    
    //MARK: - UIButton Actions
    @IBAction func backAction(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func workoutStartAction(_ sender: UIButton){
        let x = 1 * Int(mainScroller.frame.size.width)
        mainScroller.setContentOffset(CGPoint(x: x, y: 0), animated: false)
    }
    
    @IBAction func workoutCompleteAction(_ sender: UIButton){
        let x = 2 * Int(mainScroller.frame.size.width)
        mainScroller.setContentOffset(CGPoint(x: x, y: 0), animated: false)
    }
    
    @IBAction func repeatAction(_ sender: UIButton){
        self.resetUI()
        let x = 0 * Int(mainScroller.frame.size.width)
        mainScroller.setContentOffset(CGPoint(x: x, y: 0), animated: false)
        self.setupStartAWorkoutAnimation()
    }
    
    
    @IBAction func pageControlValueChange(_ sender: UIPageControl){
        let x = sender.currentPage * Int(mainScroller.frame.size.width)
        mainScroller.setContentOffset(CGPoint(x: x, y: 0), animated: false)
    }
    
}

extension CountingLapsAnimaitionZ2VC: UIScrollViewDelegate{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let index = mainScroller.contentOffset.x/mainScroller.frame.size.width
        //self.pageControl.currentPage = Int(index)
        
        if index == 1{
            if self.lblStart2AWorkout.alpha == 0{
                self.setupCompleteAWorkoutAnimation()
            }
        }
        
        if index == 2{
            if self.lblRestart.alpha == 0{
                self.setupRestartAnimation()
            }
        }
        
    }
    
}

//MARK: - Player
extension CountingLapsAnimaitionZ2VC{
    func play(sound: CountingLapsSound){
        
        guard let path = Bundle.main.url(forResource: sound.rawValue, withExtension: "wav") else{
            return
        }
         
        self.player = AVPlayer.init(url: path)
        self.player?.play()
    }
}
