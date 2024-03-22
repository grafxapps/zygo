//
//  HistoryViewController.swift
//  Zygo
//
//  Created by Priya Gandhi on 29/01/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class HistoryViewController: UIViewController {
    
    @IBOutlet weak var tblHistory : UITableView!
    
    var itemInfo = IndicatorInfo(title: "HISTORY")
    
    private let viewModel = CreateProfileViewModel()
    var superObj: ProfileViewController!
    var user = PreferenceManager.shared.user
    
    var isUpdated: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addObservers()
        self.registerTVC()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.superObj.hideChooseImage()
        self.isUpdated = false
        self.tblHistory.reloadData()
        self.viewModel.getUserHistory { [weak self] (isUpdated) in
            if isUpdated{
                self?.isUpdated = true
                self?.user = PreferenceManager.shared.user
                self?.tblHistory.reloadData()
            }
        }
    }
    
    
    //MARK:- Setup
    func registerTVC()  {
        tblHistory.estimatedRowHeight = 100.0
        tblHistory.separatorStyle = .none
        tblHistory.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        tblHistory.register(UINib.init(nibName: MetricsTVC.identifier, bundle: nil), forCellReuseIdentifier: MetricsTVC.identifier);
        tblHistory.register(UINib.init(nibName: HistoryInfoTVC.identifier, bundle: nil), forCellReuseIdentifier: HistoryInfoTVC.identifier);
        tblHistory.register(UINib.init(nibName: AchievementsTVC.identifier, bundle: nil), forCellReuseIdentifier: AchievementsTVC.identifier);
        tblHistory.register(UINib.init(nibName: PastWorkoutsTVC.identifier, bundle: nil), forCellReuseIdentifier: PastWorkoutsTVC.identifier);
    }
    
    func addObservers(){
        self.removeObservers()
        NotificationCenter.default.addObserver(self, selector: #selector(self.didSelectTab), name: .didSelectProfileTab, object: nil)
    }
    
    @objc func didSelectTab(){
        self.tblHistory.scroll(to: .top, animated: true)
    }
    
    func removeObservers(){
        NotificationCenter.default.removeObserver(self)
    }
    
}

extension HistoryViewController : UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }else{
            return self.viewModel.arrWorkoutLogs.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0{
            
            let cell : MetricsTVC = tableView.dequeueReusableCell(withIdentifier: MetricsTVC.identifier) as! MetricsTVC
            
            cell.updateSwitchBG()
            
            return cell
        }else{
            let cell : PastWorkoutsTVC = tableView.dequeueReusableCell(withIdentifier: PastWorkoutsTVC.identifier) as! PastWorkoutsTVC
            
            if indexPath.row == 0{
                cell.contentViewCenterConstraint.priority = UILayoutPriority(250.0)
                cell.constentTopConstraint.priority = UILayoutPriority(999.0)
            }else{
                cell.constentTopConstraint.priority = UILayoutPriority(250.0)
                cell.contentViewCenterConstraint.priority = UILayoutPriority(999.0)
            }
            cell.setupPastWorkouInfo(item: self.viewModel.arrWorkoutLogs[indexPath.row])
            cell.selectionStyle = .none
            return cell;
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0{
            return ScreenSize.SCREEN_HEIGHT * 0.5543
        }else{
            if indexPath.row == 0{
                return 90.0
            }
            
            return 57.0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if indexPath.section == 0{
            return
        }
        
        let item = self.viewModel.arrWorkoutLogs[indexPath.row]
        
        if item.WId == 0{ //Tempo Workout has no workout detail
            return
        }
        
        let playerVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WorkoutDetailViewController") as! WorkoutDetailViewController
        var wItem = WorkoutDTO([:])
        wItem.workoutName = item.workoutName
        wItem.workoutId = item.WId
        playerVC.workoutItem = wItem
        playerVC.workoutLog = item
        playerVC.hidesBottomBarWhenPushed = true
        Helper.shared.topNavigationController()?.pushViewController(playerVC, animated: true)
        
        
    }
}

extension HistoryViewController : IndicatorInfoProvider, AchievementsTVCDelegates{
    func didSelect(achievement: AchievementDTO) {
        let sideStoryBoard = UIStoryboard(name: "SideMenu", bundle: nil)
        let achiVC = sideStoryBoard.instantiateViewController(withIdentifier: "YourAchievementViewController") as! YourAchievementViewController
        achiVC.item = achievement
        self.navigationController?.pushViewController(achiVC, animated: true)
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}
