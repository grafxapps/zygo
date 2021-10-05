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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addObservers()
        self.registerTVC()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.superObj.hideChooseImage()
        self.viewModel.getUserHistory { [weak self] (isUpdated) in
            if isUpdated{
                self?.user = PreferenceManager.shared.user
                self?.tblHistory.reloadData()
            }
        }
    }
    
    deinit {
        self.removeObservers()
    }
    
    //MARK:- Setup
    func registerTVC()  {
        tblHistory.estimatedRowHeight = 100.0
        tblHistory.separatorStyle = .none
        tblHistory.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0)
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
        return self.viewModel.arrHistory.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let item = self.viewModel.arrHistory[section]
        switch item {
        case .classCount:
            return 1
        case .Achievements:
            return 1
        case .WorkoutLogs:
            return self.viewModel.arrWorkoutLogs.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = self.viewModel.arrHistory[indexPath.section]
        switch item {
        case .classCount:
            let cell : HistoryInfoTVC = tableView.dequeueReusableCell(withIdentifier: HistoryInfoTVC.identifier) as! HistoryInfoTVC
            cell.lblHoursInWater.text = self.user.timeInWater.toHM()
            cell.lblClassCount.text = "\(self.user.workoutCount)"
            cell.selectionStyle = .none
            return cell;
        case .Achievements:
            let cell : AchievementsTVC = tableView.dequeueReusableCell(withIdentifier: AchievementsTVC.identifier) as! AchievementsTVC
            cell.delegate = self
            cell.setupAchievements(self.viewModel.arrAchievements)
            cell.selectionStyle = .none
            return cell;
        case .WorkoutLogs:
            let cell : PastWorkoutsTVC = tableView.dequeueReusableCell(withIdentifier: PastWorkoutsTVC.identifier) as! PastWorkoutsTVC
            cell.constentTopConstraint.constant = 5.0
            if indexPath.row == 0{
                cell.constentTopConstraint.constant = 45.0
            }
            cell.setupPastWorkouInfo(item: self.viewModel.arrWorkoutLogs[indexPath.row])
            cell.selectionStyle = .none
            return cell;
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let item = self.viewModel.arrHistory[indexPath.section]
        switch item {
        case .classCount:
            return 100.0
        case .Achievements:
            return UITableView.automaticDimension
        case .WorkoutLogs:
            
            if indexPath.row == 0{
                return 92.0
            }
            
            return 52.0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let itemH = self.viewModel.arrHistory[indexPath.section]
        if itemH != .WorkoutLogs{
            return
        }
        
        
        let playerVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WorkoutDetailViewController") as! WorkoutDetailViewController
        let item = self.viewModel.arrWorkoutLogs[indexPath.row]
        var wItem = WorkoutDTO([:])
        wItem.workoutName = item.workoutName
        wItem.workoutId = item.WId
        playerVC.workoutItem = wItem
        playerVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(playerVC, animated: true)
        
        
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
