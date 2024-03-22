//
//  OnboardingVC.swift
//  Zygo
//
//  Created by Som Parkash on 16/02/24.
//  Copyright © 2024 Somparkash. All rights reserved.
//

import UIKit

//MARK: -
class OnboardingVC: UIViewController {
    
    @IBOutlet weak var mainContentView: UIView!
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var mainScroller: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var btnJointNow: UIButton!
    @IBOutlet weak var btnExit: UIButton!
    @IBOutlet weak var btnCross: UIButton!
    
    @IBOutlet weak var headerTabContentView: UIView!
    @IBOutlet weak var bottomTabContentView: UIView!
    
    @IBOutlet weak var arrowClassesPositionConstraint: NSLayoutConstraint!
    @IBOutlet weak var arrowSeriesPositionConstraint: NSLayoutConstraint!
    @IBOutlet weak var arrowFilterPositionConstraint: NSLayoutConstraint!
    @IBOutlet weak var arrowDownloadsPositionConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var arrowPacingPositionConstraint: NSLayoutConstraint!
    @IBOutlet weak var arrowMetricsPositionConstraint: NSLayoutConstraint!
    @IBOutlet weak var arrowBatteryositionConstraint: NSLayoutConstraint!
    @IBOutlet weak var arrowProfilePositionConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var arrowMenuPositionConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var arrowTopPositionBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var arrowTopPositionTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var arrowTopPositionMenuConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var mainScrollerHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var tab1ImageView: UIImageView!
    @IBOutlet weak var tab1Title: UILabel!
    
    @IBOutlet weak var tab2ImageView: UIImageView!
    @IBOutlet weak var tab2Title: UILabel!
    
    @IBOutlet weak var tab3ImageView: UIImageView!
    @IBOutlet weak var tab3Title: UILabel!
    
    @IBOutlet weak var tab4ImageView: UIImageView!
    @IBOutlet weak var tab4Title: UILabel!
    
    @IBOutlet weak var tab5ImageView: UIImageView!
    @IBOutlet weak var tab5Title: UILabel!

    @IBOutlet weak var tab6ImageView: UIImageView!
    @IBOutlet weak var tab6Title: UILabel!
    
    @IBOutlet weak var tab7ImageView: UIImageView!
    @IBOutlet weak var tab7Title: UILabel!
    
    @IBOutlet weak var tab8ImageView: UIImageView!
    @IBOutlet weak var tab8Title: UILabel!
    
    private var selectedIndex: Int = 0
    private var lastSelectedIndex: Int = 0
    
    private var bgImages: [UIImage?] = [
        UIImage(named: "Onboarding/Bkgnd - Classes"),
        UIImage(named: "Onboarding/Bkgnd - Series"),
        UIImage(named: "Onboarding/Bkgnd - Filter"),
        UIImage(named: "Onboarding/Bkgnd - Downloads"),
        UIImage(named: "Onboarding/Bkgnd - Pacer"),
        //UIImage(named: "Onboarding/Bkgnd - Metrics"),
        UIImage(named: "Onboarding/Bkgnd - Battery"),
        UIImage(named: "Onboarding/Bkgnd - Profile")
    ]
 
    //MARK: - UIViewcontroller LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.selectTabUI()
    }
    
    //MARK: - Setups
    func setupUI(){
        
        Helper.shared.stopLoading()
        
        self.headerTabContentView.addShadow(location: .bottom)
        self.bottomTabContentView.addShadow(location: .top)
        
        self.mainContentView.layer.cornerRadius = 10.0
        self.mainContentView.layer.borderWidth = 1.0
        self.mainContentView.layer.borderColor = UIColor.appNewBlackColor().cgColor
        
        self.btnJointNow.layer.cornerRadius = 10.0
        self.btnExit.layer.cornerRadius = 10.0
    }
    
    private func deselectAll(){
        tab1ImageView.image = UIImage(named: "icon_classes_tabbar")
        tab1Title.textColor = UIColor.appTitleDarkColor()
        
        tab2ImageView.image = UIImage(named: "icon_series_tabbar")
        tab2Title.textColor = UIColor.appTitleDarkColor()
        
        tab3ImageView.image = UIImage(named: "icon_filter_tabbar")
        tab3Title.textColor = UIColor.appTitleDarkColor()
        
        tab4ImageView.image = UIImage(named: "icon_download_tabbar")
        tab4Title.textColor = UIColor.appTitleDarkColor()
        
        tab5ImageView.image = UIImage(named: "icon_tempotrainer_tabbar")
        tab5Title.textColor = UIColor.appTitleDarkColor()
        
        tab6ImageView.image = UIImage(named: "icon_metrics_tabbar")
        tab6Title.textColor = UIColor.appTitleDarkColor()
        
        tab7ImageView.image = UIImage(named: "icon_battery_tabbar")
        tab7Title.textColor = UIColor.appTitleDarkColor()
        
        tab8ImageView.image = UIImage(named: "icon_profile_tabbar")
        tab8Title.textColor = UIColor.appTitleDarkColor()
        
    }
    
    private func selectTabUI(){
        
        self.deselectAll()
        if self.selectedIndex == 0{
            self.tab1ImageView.image = UIImage(named: "icon_classes_tabbar_selected")
            self.tab1Title.textColor = UIColor.appBlueColor()
        }else if self.selectedIndex == 1{
            self.tab2ImageView.image = UIImage(named: "icon_series_tabbar_selected")
            self.tab2Title.textColor = UIColor.appBlueColor()
        }else if self.selectedIndex == 2{
            self.tab3ImageView.image = UIImage(named: "icon_filter_tabbar_selected")
            self.tab3Title.textColor = UIColor.appBlueColor()
        }else if self.selectedIndex == 3{
            self.tab4ImageView.image = UIImage(named: "icon_download_tabbar_selected")
            self.tab4Title.textColor = UIColor.appBlueColor()
        }else if self.selectedIndex == 4{
            self.tab5ImageView.image = UIImage(named: "icon_tempotrainer_tabbar_selected")
            self.tab5Title.textColor = UIColor.appBlueColor()
        }/*else if self.selectedIndex == 5{
            self.tab6ImageView.image = UIImage(named: "icon_metrics_tabbar_selected")
            self.tab6Title.textColor = UIColor.appBlueColor()
        }*/else if self.selectedIndex == 5{
            self.tab7ImageView.image = UIImage(named: "icon_battery_tabbar_selected")
            self.tab7Title.textColor = UIColor.appBlueColor()
        }else if self.selectedIndex == 6{
            self.tab8ImageView.image = UIImage(named: "icon_profile_tabbar_selected")
            self.tab8Title.textColor = UIColor.appBlueColor()
        }
        self.tab8ImageView.layoutIfNeeded()
        self.tab8Title.layoutIfNeeded()
        
    }
    
    //MARK: - UIButton Actions
    @IBAction func closeAction(_ sender: UIButton){
        self.dismiss(animated: true) {
            
        }
    }
    
    @IBAction func joinNowAction(_ sender: UIButton){
        self.dismiss(animated: false) {
            let storyBoard = UIStoryboard(name: "Registration", bundle: nil)
            let navigationController = storyBoard.instantiateViewController(withIdentifier: "SubscriptionViewController") as! SubscriptionViewController
            navigationController.isFromDemoMode = true
            Helper.shared.topNavigationController()?.pushViewController(navigationController, animated: true)
        }
    }
    
    @IBAction func exitAction(_ sender: UIButton){
        self.dismiss(animated: true) {
            
        }
    }
    
    //MARK: -

}

//MARK: - Scroll View Delegates
extension OnboardingVC: UIScrollViewDelegate{
    
    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        print("scrollViewDidChangeAdjustedContentInset: \(scrollView.contentOffset.x)")
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewDidScroll: \(scrollView.contentOffset.x)")
        let index = mainScroller.contentOffset.x/mainScroller.frame.size.width
        self.selectedIndex = Int(index)
        self.pageControl.currentPage = Int(index)
        if Int(index) < self.bgImages.count {
            self.bgImageView.image = self.bgImages[Int(index)]
        }
        
        UIView.animate(withDuration: 0.5) {
            switch Int(index){
            case 0:
                print("0")
                self.btnCross.isHidden = false
                self.arrowImageView.isHidden = false
                if self.lastSelectedIndex >= 4{
                    self.arrowImageView.transform = self.arrowImageView.transform.rotated(by: CGFloat(Double.pi)) //180 degree
                }
                self.arrowClassesPositionConstraint.priority = UILayoutPriority(999)
                self.arrowSeriesPositionConstraint.priority = UILayoutPriority(250)
                self.arrowFilterPositionConstraint.priority = UILayoutPriority(250)
                self.arrowDownloadsPositionConstraint.priority = UILayoutPriority(250)
                
                self.arrowPacingPositionConstraint.priority = UILayoutPriority(250)
                self.arrowMetricsPositionConstraint.priority = UILayoutPriority(250)
                self.arrowBatteryositionConstraint.priority = UILayoutPriority(250)
                self.arrowProfilePositionConstraint.priority = UILayoutPriority(250)
                
                self.arrowMenuPositionConstraint.priority = UILayoutPriority(250)
                
                self.arrowTopPositionBottomConstraint.priority = UILayoutPriority(999)
                self.arrowTopPositionTopConstraint.priority = UILayoutPriority(250)
                self.arrowTopPositionMenuConstraint.priority = UILayoutPriority(250)
                
                self.mainScrollerHeightConstraint.constant = 300
                
                self.lastSelectedIndex = self.selectedIndex
            case 1:
                print("1")
                self.btnCross.isHidden = false
                self.arrowImageView.isHidden = false
                if self.lastSelectedIndex >= 4{
                    self.arrowImageView.transform = self.arrowImageView.transform.rotated(by: CGFloat(Double.pi)) //180 degree
                }
                self.arrowClassesPositionConstraint.priority = UILayoutPriority(250)
                self.arrowSeriesPositionConstraint.priority = UILayoutPriority(999)
                self.arrowFilterPositionConstraint.priority = UILayoutPriority(250)
                self.arrowDownloadsPositionConstraint.priority = UILayoutPriority(250)
                
                self.arrowPacingPositionConstraint.priority = UILayoutPriority(250)
                self.arrowMetricsPositionConstraint.priority = UILayoutPriority(250)
                self.arrowBatteryositionConstraint.priority = UILayoutPriority(250)
                self.arrowProfilePositionConstraint.priority = UILayoutPriority(250)
                
                self.arrowMenuPositionConstraint.priority = UILayoutPriority(250)
                
                self.arrowTopPositionBottomConstraint.priority = UILayoutPriority(999)
                self.arrowTopPositionTopConstraint.priority = UILayoutPriority(250)
                self.arrowTopPositionMenuConstraint.priority = UILayoutPriority(250)
                self.mainScrollerHeightConstraint.constant = 300
                self.lastSelectedIndex = self.selectedIndex
            case 2:
                print("2")
                self.btnCross.isHidden = false
                self.arrowImageView.isHidden = false
                if self.lastSelectedIndex >= 4{
                    self.arrowImageView.transform = self.arrowImageView.transform.rotated(by: CGFloat(Double.pi)) //180 degree
                }
                
                self.arrowClassesPositionConstraint.priority = UILayoutPriority(250)
                self.arrowSeriesPositionConstraint.priority = UILayoutPriority(250)
                self.arrowFilterPositionConstraint.priority = UILayoutPriority(999)
                self.arrowDownloadsPositionConstraint.priority = UILayoutPriority(250)
                
                self.arrowPacingPositionConstraint.priority = UILayoutPriority(250)
                self.arrowMetricsPositionConstraint.priority = UILayoutPriority(250)
                self.arrowBatteryositionConstraint.priority = UILayoutPriority(250)
                self.arrowProfilePositionConstraint.priority = UILayoutPriority(250)
                
                self.arrowMenuPositionConstraint.priority = UILayoutPriority(250)
                
                self.arrowTopPositionBottomConstraint.priority = UILayoutPriority(999)
                self.arrowTopPositionTopConstraint.priority = UILayoutPriority(250)
                self.arrowTopPositionMenuConstraint.priority = UILayoutPriority(250)
                self.mainScrollerHeightConstraint.constant = 300
                self.lastSelectedIndex = self.selectedIndex
            case 3:
                print("3")
                self.btnCross.isHidden = false
                self.arrowImageView.isHidden = false
                if self.lastSelectedIndex >= 4{
                    self.arrowImageView.transform = self.arrowImageView.transform.rotated(by: CGFloat(Double.pi)) //180 degree
                }
                
                self.arrowClassesPositionConstraint.priority = UILayoutPriority(250)
                self.arrowSeriesPositionConstraint.priority = UILayoutPriority(250)
                self.arrowFilterPositionConstraint.priority = UILayoutPriority(250)
                self.arrowDownloadsPositionConstraint.priority = UILayoutPriority(999)
                
                self.arrowPacingPositionConstraint.priority = UILayoutPriority(250)
                self.arrowMetricsPositionConstraint.priority = UILayoutPriority(250)
                self.arrowBatteryositionConstraint.priority = UILayoutPriority(250)
                self.arrowProfilePositionConstraint.priority = UILayoutPriority(250)
                
                self.arrowMenuPositionConstraint.priority = UILayoutPriority(250)
                
                self.arrowTopPositionBottomConstraint.priority = UILayoutPriority(999)
                self.arrowTopPositionTopConstraint.priority = UILayoutPriority(250)
                self.arrowTopPositionMenuConstraint.priority = UILayoutPriority(250)
                self.mainScrollerHeightConstraint.constant = 300
                self.lastSelectedIndex = self.selectedIndex
            case 4:
                print("4")
                self.btnCross.isHidden = false
                self.arrowImageView.isHidden = false
                if self.lastSelectedIndex <= 3{
                    self.arrowImageView.transform = self.arrowImageView.transform.rotated(by: CGFloat(Double.pi)) //180 degree
                }
                self.arrowClassesPositionConstraint.priority = UILayoutPriority(250)
                self.arrowSeriesPositionConstraint.priority = UILayoutPriority(250)
                self.arrowFilterPositionConstraint.priority = UILayoutPriority(250)
                self.arrowDownloadsPositionConstraint.priority = UILayoutPriority(250)
                
                self.arrowPacingPositionConstraint.priority = UILayoutPriority(999)
                self.arrowMetricsPositionConstraint.priority = UILayoutPriority(250)
                self.arrowBatteryositionConstraint.priority = UILayoutPriority(250)
                self.arrowProfilePositionConstraint.priority = UILayoutPriority(250)
                
                self.arrowMenuPositionConstraint.priority = UILayoutPriority(250)
                
                self.arrowTopPositionBottomConstraint.priority = UILayoutPriority(250)
                self.arrowTopPositionTopConstraint.priority = UILayoutPriority(999)
                self.arrowTopPositionMenuConstraint.priority = UILayoutPriority(250)
                self.mainScrollerHeightConstraint.constant = 300
                self.lastSelectedIndex = self.selectedIndex
            /*case 5:
                print("5")
                self.btnCross.isHidden = false
                self.arrowImageView.isHidden = false
                if self.lastSelectedIndex <= 3{
                    self.arrowImageView.transform = self.arrowImageView.transform.rotated(by: CGFloat(Double.pi)) //180 degree
                }
                self.arrowClassesPositionConstraint.priority = UILayoutPriority(250)
                self.arrowSeriesPositionConstraint.priority = UILayoutPriority(250)
                self.arrowFilterPositionConstraint.priority = UILayoutPriority(250)
                self.arrowDownloadsPositionConstraint.priority = UILayoutPriority(250)
             
             self.arrowPacingPositionConstraint.priority = UILayoutPriority(250)
             self.arrowMetricsPositionConstraint.priority = UILayoutPriority(999)
             self.arrowBatteryositionConstraint.priority = UILayoutPriority(250)
             self.arrowProfilePositionConstraint.priority = UILayoutPriority(250)
             
                self.arrowMenuPositionConstraint.priority = UILayoutPriority(250)
                
                self.arrowTopPositionBottomConstraint.priority = UILayoutPriority(250)
                self.arrowTopPositionTopConstraint.priority = UILayoutPriority(999)
                self.arrowTopPositionMenuConstraint.priority = UILayoutPriority(250)
                self.mainScrollerHeightConstraint.constant = 300
                self.lastSelectedIndex = self.selectedIndex*/
            case 5:
                print("6")
                self.btnCross.isHidden = false
                self.arrowImageView.isHidden = false
                if self.lastSelectedIndex <= 3{
                    self.arrowImageView.transform = self.arrowImageView.transform.rotated(by: CGFloat(Double.pi)) //180 degree
                }
                self.arrowClassesPositionConstraint.priority = UILayoutPriority(250)
                self.arrowSeriesPositionConstraint.priority = UILayoutPriority(250)
                self.arrowFilterPositionConstraint.priority = UILayoutPriority(250)
                self.arrowDownloadsPositionConstraint.priority = UILayoutPriority(250)
                
                self.arrowPacingPositionConstraint.priority = UILayoutPriority(250)
                self.arrowMetricsPositionConstraint.priority = UILayoutPriority(250)
                self.arrowBatteryositionConstraint.priority = UILayoutPriority(999)
                self.arrowProfilePositionConstraint.priority = UILayoutPriority(250)
                
                self.arrowMenuPositionConstraint.priority = UILayoutPriority(250)
                
                self.arrowTopPositionBottomConstraint.priority = UILayoutPriority(250)
                self.arrowTopPositionTopConstraint.priority = UILayoutPriority(999)
                self.arrowTopPositionMenuConstraint.priority = UILayoutPriority(250)
                self.mainScrollerHeightConstraint.constant = 300
                self.lastSelectedIndex = self.selectedIndex
            case 6:
                print("7")
                self.btnCross.isHidden = false
                self.arrowImageView.isHidden = false
                if self.lastSelectedIndex <= 3{
                    self.arrowImageView.transform = self.arrowImageView.transform.rotated(by: CGFloat(Double.pi)) //180 degree
                }
                self.arrowClassesPositionConstraint.priority = UILayoutPriority(250)
                self.arrowSeriesPositionConstraint.priority = UILayoutPriority(250)
                self.arrowFilterPositionConstraint.priority = UILayoutPriority(250)
                self.arrowDownloadsPositionConstraint.priority = UILayoutPriority(250)
                
                self.arrowPacingPositionConstraint.priority = UILayoutPriority(250)
                self.arrowMetricsPositionConstraint.priority = UILayoutPriority(250)
                self.arrowBatteryositionConstraint.priority = UILayoutPriority(250)
                self.arrowProfilePositionConstraint.priority = UILayoutPriority(999)
                
                self.arrowMenuPositionConstraint.priority = UILayoutPriority(250)
                
                self.arrowTopPositionBottomConstraint.priority = UILayoutPriority(250)
                self.arrowTopPositionTopConstraint.priority = UILayoutPriority(999)
                self.arrowTopPositionMenuConstraint.priority = UILayoutPriority(250)
                self.mainScrollerHeightConstraint.constant = 300
                self.lastSelectedIndex = self.selectedIndex
            case 7:
                print("8")
                self.btnCross.isHidden = false
                self.arrowImageView.isHidden = false
                if self.lastSelectedIndex <= 3{
                    self.arrowImageView.transform = self.arrowImageView.transform.rotated(by: CGFloat(Double.pi)) //180 degree
                }
                self.arrowClassesPositionConstraint.priority = UILayoutPriority(250)
                self.arrowSeriesPositionConstraint.priority = UILayoutPriority(250)
                self.arrowFilterPositionConstraint.priority = UILayoutPriority(250)
                self.arrowDownloadsPositionConstraint.priority = UILayoutPriority(250)
                
                self.arrowPacingPositionConstraint.priority = UILayoutPriority(250)
                self.arrowMetricsPositionConstraint.priority = UILayoutPriority(250)
                self.arrowBatteryositionConstraint.priority = UILayoutPriority(250)
                self.arrowProfilePositionConstraint.priority = UILayoutPriority(250)
                
                self.arrowMenuPositionConstraint.priority = UILayoutPriority(999)
                
                self.arrowTopPositionBottomConstraint.priority = UILayoutPriority(250)
                self.arrowTopPositionTopConstraint.priority = UILayoutPriority(250)
                self.arrowTopPositionMenuConstraint.priority = UILayoutPriority(999)
                self.mainScrollerHeightConstraint.constant = 300
                self.lastSelectedIndex = self.selectedIndex
            case 8:
                print("8")
                if self.lastSelectedIndex <= 3{
                    self.arrowImageView.transform = self.arrowImageView.transform.rotated(by: CGFloat(Double.pi)) //180 degree
                }
                self.arrowClassesPositionConstraint.priority = UILayoutPriority(250)
                self.arrowSeriesPositionConstraint.priority = UILayoutPriority(250)
                self.arrowFilterPositionConstraint.priority = UILayoutPriority(250)
                self.arrowDownloadsPositionConstraint.priority = UILayoutPriority(250)
                
                self.arrowPacingPositionConstraint.priority = UILayoutPriority(250)
                self.arrowMetricsPositionConstraint.priority = UILayoutPriority(250)
                self.arrowBatteryositionConstraint.priority = UILayoutPriority(250)
                self.arrowProfilePositionConstraint.priority = UILayoutPriority(250)
                
                self.arrowMenuPositionConstraint.priority = UILayoutPriority(999)
                
                self.arrowTopPositionBottomConstraint.priority = UILayoutPriority(250)
                self.arrowTopPositionTopConstraint.priority = UILayoutPriority(250)
                self.arrowTopPositionMenuConstraint.priority = UILayoutPriority(999)
                self.mainScrollerHeightConstraint.constant = 500
                self.btnCross.isHidden = true
                self.arrowImageView.isHidden = true
                self.lastSelectedIndex = self.selectedIndex
            default:
                print("default")
                
            }
            
            self.view.layoutIfNeeded()
        } completion: { complete in
            self.lastSelectedIndex = self.selectedIndex
            self.selectTabUI()
        }
        
    }
    
    //func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
    
    //func scrollViewDidScroll(_ scrollView: UIScrollView)
}
