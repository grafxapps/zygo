//
//  WorkoutDetailViewController.swift
//  Zygo
//
//  Created by Priya Gandhi on 04/02/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit

class WorkoutDetailViewController: UIViewController {
    
    @IBOutlet weak var tblWorkout : UITableView!
    var arrSection : [WorkoutDetailSections] = [.detail, .rating, .equipment, .startWorkout, .workoutPlan]
    var workoutItem: WorkoutDTO?
    var viewModel = WorkoutsViewModel()
    
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.registerTVC()
        self.updateData()
        self.viewModel.getDownloadedWorkout(wId: workoutItem?.workoutId ?? 0 )
        var loading: Bool = true
        if self.viewModel.downloadedWorkout != nil{
            loading = false
        }
        
        if loading{
            self.tblWorkout.alpha = 0.0
        }
        
        self.viewModel.getWorkoutDetail(by: workoutItem?.workoutId ?? 0, isLoading: loading) { [weak self] workoutTemp in
            if workoutTemp != nil{
                self?.workoutItem = workoutTemp!
                self?.updateData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        ZygoWorkoutDownloadManager.shared.downloadComplete = { [weak self] in
            self?.viewModel.getDownloadedWorkout(wId: self?.workoutItem?.workoutId ?? 0)
            self?.tblWorkout.reloadData()
        }
    }
    
    
    //MARK:- Setup
    func updateData(){
        arrSection = [.detail, .rating]//.equipment, .startWorkout, .workoutPlan]
        if workoutItem?.workoutEquipments.count ?? 0 > 0{
            arrSection.append(.equipment)
        }
        arrSection.append(.startWorkout)
        if workoutItem?.workoutPlanLines.count ?? 0 > 0{
            arrSection.append(.workoutPlan)
        }
        self.tblWorkout.reloadData()
        
        
        UIView.animate(withDuration: 0.4) {
            self.tblWorkout.alpha = 1.0
        }
    }
    
    func registerTVC()  {
        tblWorkout.estimatedRowHeight = 100.0
        tblWorkout.register(UINib.init(nibName: WorkoutDetailInfoTVC.identifier, bundle: nil), forCellReuseIdentifier: WorkoutDetailInfoTVC.identifier);
        tblWorkout.register(UINib.init(nibName: WorkoutTypeTVC.identifier, bundle: nil), forCellReuseIdentifier: WorkoutTypeTVC.identifier);
        tblWorkout.register(UINib.init(nibName: EquipmentTVC.identifier, bundle: nil), forCellReuseIdentifier: EquipmentTVC.identifier);
        tblWorkout.register(UINib.init(nibName: StartWorkoutTVC.identifier, bundle: nil), forCellReuseIdentifier: StartWorkoutTVC.identifier);
        tblWorkout.register(UINib.init(nibName: WorkoutPlanTVC.identifier, bundle: nil), forCellReuseIdentifier: WorkoutPlanTVC.identifier);
        tblWorkout.register(UINib.init(nibName: WorkoutHeaderTVC.identifier, bundle: nil), forCellReuseIdentifier: WorkoutHeaderTVC.identifier);
        
    }
    
    //MARK: - UIButton Actions
    @IBAction func backAction(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func startWorkoutAction(_ sender: UIButton){

        let playerVC = self.storyboard?.instantiateViewController(withIdentifier: "WorkoutPlayerViewController") as! WorkoutPlayerViewController
        playerVC.workoutItem = workoutItem
        playerVC.localWorkout = self.viewModel.downloadedWorkout
        self.navigationController?.pushViewController(playerVC, animated: true)
    }
    
    @objc func downloadAction(_ sender: UIButton){
        if self.viewModel.downloadedWorkout != nil{
            let status = WorkoutDownloadStatus(rawValue: self.viewModel.downloadedWorkout!.workoutDownloadStatus) ?? .downloaded
            if status == .downloading{
                return
            }else if status == .downloaded{
                self.deleteDownloadedWorkout()
            }else{
                if workoutItem != nil{
                    ZygoWorkoutDownloadManager.shared.download(workout: workoutItem!)
                    self.viewModel.getDownloadedWorkout(wId: workoutItem!.workoutId)
                }
                
                self.tblWorkout.reloadData()
            }
        }else{
            if workoutItem != nil{
                ZygoWorkoutDownloadManager.shared.download(workout: workoutItem!)
                self.viewModel.getDownloadedWorkout(wId: workoutItem!.workoutId)
            }
            self.tblWorkout.reloadData()
        }
        
    }
    
    func deleteDownloadedWorkout(){
        Helper.shared.alertYesNoActions(title: nil, message: "Are you sure you want to delete this downloaded  class?", yesActionTitle: "Yes", noActionTitle: "No") { (isYes) in
            if isYes{
                DatabaseManager.shared.deleteWrokout(by: self.viewModel.downloadedWorkout?.workoutIdentifier ?? "")
                self.viewModel.downloadedWorkout = nil
                self.tblWorkout.reloadData()
            }
        }
    }
    
}
extension WorkoutDetailViewController : UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.arrSection.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        if self.arrSection[section] == .workoutPlan{
            return self.workoutItem?.workoutPlanLines.count ?? 0
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let sItem = self.arrSection[section]
        
        switch sItem {
        case .detail:
            let cell : WorkoutDetailInfoTVC = tableView.dequeueReusableCell(withIdentifier: WorkoutDetailInfoTVC.identifier) as! WorkoutDetailInfoTVC
            cell.selectionStyle = .none
            if workoutItem != nil{
                cell.setupDetailInfo(workoutItem!)
            }
            
            return cell;
        case .rating:
            let cell : WorkoutTypeTVC = tableView.dequeueReusableCell(withIdentifier: WorkoutTypeTVC.identifier) as! WorkoutTypeTVC
            cell.selectionStyle = .none
            if workoutItem != nil{
                cell.setupDetailInfo(workoutItem!)
            }
            cell.setupDefaultDownload()
            cell.btnDownload.addTarget(self, action: #selector(self.downloadAction(_:)), for: .touchUpInside)
            if let localWorkout = self.viewModel.downloadedWorkout{
                cell.setupDownloadStaus(stauts: WorkoutDownloadStatus(rawValue: localWorkout.workoutDownloadStatus) ?? .downloaded)
            }
            
            return cell;
        case .equipment:
            let cell : EquipmentTVC = tableView.dequeueReusableCell(withIdentifier: EquipmentTVC.identifier) as! EquipmentTVC
            cell.selectionStyle = .none
            cell.updateEquipments(arrEquipments: workoutItem?.workoutEquipments ?? [])
            return cell;
        case .startWorkout:
            let cell : StartWorkoutTVC = tableView.dequeueReusableCell(withIdentifier: StartWorkoutTVC.identifier) as! StartWorkoutTVC
            cell.selectionStyle = .none
            cell.btnStartWorkout.addTarget(self, action: #selector(self.startWorkoutAction(_:)), for: .touchUpInside)
            return cell;
        case .workoutPlan:
            let cell : WorkoutPlanTVC = tableView.dequeueReusableCell(withIdentifier: WorkoutPlanTVC.identifier) as! WorkoutPlanTVC
            if let item = self.workoutItem?.workoutPlanLines[indexPath.row]{
                cell.lblTitle.text = item.title
                cell.lblDuration.text = item.time
            }
            cell.selectionStyle = .none
            return cell;
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "WorkoutHeaderTVC") as! WorkoutHeaderTVC
        headerView.addSubview(headerCell)
        return headerView
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.arrSection[section] == .workoutPlan{
            return 70.0
        }else{
            return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let section = indexPath.section
        let sItem = self.arrSection[section]
        switch sItem {
        case .detail:
            return UITableView.automaticDimension
        case .rating:
            return 95.0
        case .equipment:
            return UITableView.automaticDimension
        case .startWorkout:
            return 90.0
        case .workoutPlan:
            return 66.0;
        }
    }
}


enum WorkoutDetailSections {
    case detail
    case rating
    case equipment
    case startWorkout
    case workoutPlan
}
