//
//  ProfileViewController.swift
//  Zygo
//
//  Created by Priya Gandhi on 31/01/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class ProfileViewController: ButtonBarPagerTabStripViewController {
    var infoVC: InfoViewController!
    var historyVC: HistoryViewController!

    override func viewDidLoad() {
        infoVC = self.storyboard?.instantiateViewController(withIdentifier: "InfoViewController") as? InfoViewController
        historyVC = self.storyboard?.instantiateViewController(withIdentifier: "HistoryViewController") as? HistoryViewController

        self.setupTabBars()
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    
    func setupTabBars(){
           settings.style.buttonBarBackgroundColor = .white
           settings.style.buttonBarItemBackgroundColor = .white//UIColor(named: "PurpleColor")!
           settings.style.selectedBarBackgroundColor = UIColor(named: "AppBlueColor")!
           settings.style.buttonBarItemFont = UIFont(name: "Poppins-Medium", size: 18.0)!
           settings.style.selectedBarHeight = 4.0
           settings.style.buttonBarMinimumLineSpacing = 0
           settings.style.buttonBarItemTitleColor = .black
           settings.style.buttonBarItemsShouldFillAvailableWidth = true
           
           settings.style.buttonBarLeftContentInset = 0
           settings.style.buttonBarRightContentInset = 0
           
           changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
               guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = UIColor.black
               newCell?.label.textColor = UIColor(named: "AppBlueColor")!
           }
       }
       
    // MARK: - PagerTabStripDataSource
      override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
          return [infoVC, historyVC]
      }
}
