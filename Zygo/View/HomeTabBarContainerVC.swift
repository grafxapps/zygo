//
//  HomeTabBarContainerVC.swift
//  Zygo
//
//  Created by Som on 03/09/22.
//  Copyright © 2022 Somparkash. All rights reserved.
//

import UIKit

//MARK: -
class HomeTabBarContainerVC: UIViewController {
    
    @IBOutlet weak var headerTabContentView: UIView!
    @IBOutlet weak var bottomTabContentView: UIView!
    
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
    
    //MARK: - UIViewcontroller LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        headerTabContentView.addShadow(location: .bottom)
        bottomTabContentView.addShadow(location: .top)
        
        BluetoothManager.shared.wakeUpBLE()
        
        self.selectTabUI()
        
        //BLEConnectionManager.shared.startAutoConnectScanning()
        if AppDelegate.app.isSignupCompleted{
            let vc = OnboardingVC(nibName: "OnboardingVC", bundle: nil)
            vc.modalPresentationStyle = .overCurrentContext
            self.present(vc, animated: true)
        }
    }
    
    //MARK: - Setups
    func moveToTab(_ index: Int){
        
        guard let tabBar = self.children.first as? HomeTabBar else{
            return
        }
        
        let tabBarController = tabBar as UITabBarController
        //This is only for profile changes save popup. If user select yes on that popup then we need to proceed with tab bar select automatically
        PreferenceManager.shared.selectedTabBarIndexFromProfile = index
        
        if tabBar.tabBarController(tabBarController, shouldSelect: tabBar.viewControllers![index]){
            self.deselectAll()
            if !AppDelegate.app.isProfileTabOpened{
                tabBar.selectedIndex = 7
                if let item = tabBar.tabBar.items!.last{
                    tabBar.tabBar(tabBar.tabBar, didSelect: item)
                    AppDelegate.app.isProfileTabOpened = true
                }
            }
            
            self.selectedIndex = index
            tabBar.selectedIndex = index
            
            var item: UITabBarItem?
            if index < tabBar.tabBar.items!.count{
                item = tabBar.tabBar.items![index]
            }else{
                item = tabBar.tabBar.items!.last
            }
            
            tabBar.tabBar(tabBar.tabBar, didSelect: item!)
            self.selectTabUI()
        }
    }
    
    func deselectAll(){
        
        tab1ImageView.image = UIImage(named: "icon_classes_tabbar")
        tab1Title.textColor = UIColor.appBlueColor()
        tab1Title.alpha = 0.33
        
        tab2ImageView.image = UIImage(named: "icon_series_tabbar")
        tab2Title.textColor = UIColor.appBlueColor()
        tab2Title.alpha = 0.33
        
        tab3ImageView.image = UIImage(named: "icon_filter_tabbar")
        tab3Title.textColor = UIColor.appBlueColor()
        tab3Title.alpha = 0.33
        
        tab4ImageView.image = UIImage(named: "icon_download_tabbar")
        tab4Title.textColor = UIColor.appBlueColor()
        tab4Title.alpha = 0.33
        
        tab5ImageView.image = UIImage(named: "icon_tempotrainer_tabbar")
        tab5Title.textColor = UIColor.appBlueColor()
        tab5Title.alpha = 0.33
        
        tab6ImageView.image = UIImage(named: "icon_metrics_tabbar")
        tab6Title.textColor = UIColor.appBlueColor()
        tab6Title.alpha = 0.33
        
        tab7ImageView.image = UIImage(named: "icon_battery_tabbar")
        tab7Title.textColor = UIColor.appBlueColor()
        tab7Title.alpha = 0.33
        
        tab8ImageView.image = UIImage(named: "icon_profile_tabbar")
        tab8Title.textColor = UIColor.appBlueColor()
        tab8Title.alpha = 0.33
        
    }
    
    func selectTabUI(){
        if selectedIndex == 0{
            tab1ImageView.image = UIImage(named: "icon_classes_tabbar_selected")
            tab1Title.textColor = UIColor.appBlueColor()
            tab1Title.alpha = 1.0
        }else if selectedIndex == 1{
            tab2ImageView.image = UIImage(named: "icon_series_tabbar_selected")
            tab2Title.textColor = UIColor.appBlueColor()
            tab2Title.alpha = 1.0
        }else if selectedIndex == 2{
            tab3ImageView.image = UIImage(named: "icon_filter_tabbar_selected")
            tab3Title.textColor = UIColor.appBlueColor()
            tab3Title.alpha = 1.0
        }else if selectedIndex == 3{
            tab4ImageView.image = UIImage(named: "icon_download_tabbar_selected")
            tab4Title.textColor = UIColor.appBlueColor()
            tab4Title.alpha = 1.0
        }else if selectedIndex == 4{
            tab5ImageView.image = UIImage(named: "icon_tempotrainer_tabbar_selected")
            tab5Title.textColor = UIColor.appBlueColor()
            tab5Title.alpha = 1.0
        }else if selectedIndex == 5{
            tab6ImageView.image = UIImage(named: "icon_metrics_tabbar_selected")
            tab6Title.textColor = UIColor.appBlueColor()
            tab6Title.alpha = 1.0
        }else if selectedIndex == 6{
            tab7ImageView.image = UIImage(named: "icon_battery_tabbar_selected")
            tab7Title.textColor = UIColor.appBlueColor()
            tab7Title.alpha = 1.0
        }else if selectedIndex == 7{
            tab8ImageView.image = UIImage(named: "icon_profile_tabbar_selected")
            tab8Title.textColor = UIColor.appBlueColor()
            tab8Title.alpha = 1.0
        }
        
    }
    
    
    //MARK: - UIButton Actions
    @IBAction func homeAction(_ sender: UIButton){
        sideMenuController?.revealMenu()
    }
    
    @IBAction func classesTabAction(_ sender: UIButton){
        moveToTab(0)
    }
    
    @IBAction func seriesTabAction(_ sender: UIButton){
        moveToTab(1)
    }
    
    @IBAction func filtersTabAction(_ sender: UIButton){
        moveToTab(2)
    }
    
    @IBAction func downloadsTabAction(_ sender: UIButton){
        moveToTab(3)
    }
    
    @IBAction func pacingTabAction(_ sender: UIButton){
        moveToTab(4)
    }
    
    @IBAction func metricsTabAction(_ sender: UIButton){
        moveToTab(5)
    }
    
    @IBAction func batteryTabAction(_ sender: UIButton){
        moveToTab(6)
    }
    
    @IBAction func profileTabAction(_ sender: UIButton){
        moveToTab(7)
    }
    
    
    //MARK: -
}
