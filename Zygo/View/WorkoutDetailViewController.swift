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
    var isFromInstructor: Bool = false
    var isFromBranch: Bool = false
    var workoutLog: WorkoutLogDTO?
    private var isViewMore: Bool = false
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
        
        ZygoWorkoutDownloadManager.shared.downloadComplete = { [weak self] isDownloaded in
            self?.viewModel.getDownloadedWorkout(wId: self?.workoutItem?.workoutId ?? 0)
            self?.tblWorkout.reloadData()
        }
    }
    
    
    //MARK:- Setup
    func updateData(){
        if workoutLog != nil{
            arrSection = [.feedback]//.equipment, .startWorkout, .workoutPlan]
        }else{
            arrSection = [.detail, .rating]//.equipment, .startWorkout, .workoutPlan]
        }
        
        if workoutItem?.workoutEquipments.count ?? 0 > 0{
            arrSection.append(.equipment)
        }
        
        if workoutItem?.playlist.count ?? 0 > 0{
            arrSection.append(.playlist)
        }
        
        //arrSection.append(.startWorkout)
        if workoutItem?.workoutPlanLines.count ?? 0 > 0{
            arrSection.append(.workoutPlan)
        }
        
        self.tblWorkout.reloadData()
        
        
        UIView.animate(withDuration: 0.4) {
            self.tblWorkout.alpha = 1.0
        }
    }
    
    func registerTVC()  {
        tblWorkout.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        tblWorkout.estimatedRowHeight = 100.0
        
        tblWorkout.register(UINib.init(nibName: WokoutFeedbackInfoTVC.identifier, bundle: nil), forCellReuseIdentifier: WokoutFeedbackInfoTVC.identifier);
        tblWorkout.register(UINib.init(nibName: WorkoutDetailInfoTVC.identifier, bundle: nil), forCellReuseIdentifier: WorkoutDetailInfoTVC.identifier);
        tblWorkout.register(UINib.init(nibName: WorkoutTypeTVC.identifier, bundle: nil), forCellReuseIdentifier: WorkoutTypeTVC.identifier);
        tblWorkout.register(UINib.init(nibName: EquipmentTVC.identifier, bundle: nil), forCellReuseIdentifier: EquipmentTVC.identifier);
        tblWorkout.register(UINib.init(nibName: StartWorkoutTVC.identifier, bundle: nil), forCellReuseIdentifier: StartWorkoutTVC.identifier);
        tblWorkout.register(UINib.init(nibName: WorkoutPlanTVC.identifier, bundle: nil), forCellReuseIdentifier: WorkoutPlanTVC.identifier);
        tblWorkout.register(UINib.init(nibName: WorkoutHeaderTVC.identifier, bundle: nil), forCellReuseIdentifier: WorkoutHeaderTVC.identifier);
        tblWorkout.register(UINib.init(nibName: PlaylistTVC.identifier, bundle: nil), forCellReuseIdentifier: PlaylistTVC.identifier);
        tblWorkout.register(UINib.init(nibName: PlaylistInfoTVC.identifier, bundle: nil), forCellReuseIdentifier: PlaylistInfoTVC.identifier)
        tblWorkout.register(UINib.init(nibName: PlaylistViewMoreTVC.identifier, bundle: nil), forCellReuseIdentifier: PlaylistViewMoreTVC.identifier)
        
    }
    
    //MARK: - UIButton Actions
    @IBAction func syncAction(){
        let vc = RequestDataVC(nibName: "RequestDataVC", bundle: nil)
        vc.workoutItem = self.workoutItem
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func backAction(_ sender: UIButton){
        if self.isFromBranch{
            self.dismiss(animated: true, completion: nil)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    @objc @IBAction func startWorkoutAction(_ sender: UIButton){
        Helper.shared.log(event: .WORKOUTSTART, params: [:])
        let playerVC = self.storyboard?.instantiateViewController(withIdentifier: "WorkoutPlayerViewController") as! WorkoutPlayerViewController
        playerVC.workoutItem = workoutItem
        playerVC.localWorkout = self.viewModel.downloadedWorkout
        self.navigationController?.pushViewController(playerVC, animated: true)
    }
    
    @objc func downloadAction(_ sender: UIButton){
        if self.viewModel.downloadedWorkout != nil{
            
            Helper.shared.log(event: .DOWNLOADWORKOUT, params: [:])
            
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
    
    @objc func instructorProfile(){
        if isFromInstructor{
            return
        }
        
        Helper.shared.log(event: .INSTRUCTORPROFILE, params: [:])
        let storyboard = UIStoryboard(name: "Instructor", bundle: nil)
        let instVC = storyboard.instantiateViewController(withIdentifier: "InstructorViewController") as! InstructorViewController
        instVC.viewModel.instructor = workoutItem!.instructor
        self.navigationController?.pushViewController(instVC, animated: true)
        
    }
    
    @objc func viewMoreAction(){
        if self.isViewMore{
            self.isViewMore = false
        }else{
            self.isViewMore = true
        }
        
        self.tblWorkout.reloadData()
        
    }
}
extension WorkoutDetailViewController : UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.arrSection.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        if self.arrSection[section] == .workoutPlan{
            return self.workoutItem?.workoutPlanLines.count ?? 0
        }else if self.arrSection[section] == .playlist{
            let count = self.workoutItem?.playlist.count ?? 0
            if count > 3{
                if self.isViewMore{
                    return count + 1
                }else{
                    return 3 + 1
                }
            }else{
                return count
            }
            
        } else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let sItem = self.arrSection[section]
        
        switch sItem {
        case .feedback:
            let cell : WokoutFeedbackInfoTVC = tableView.dequeueReusableCell(withIdentifier: WokoutFeedbackInfoTVC.identifier) as! WokoutFeedbackInfoTVC
            cell.selectionStyle = .none
            if workoutItem != nil{
                cell.setupWorkoutInfo(item: workoutItem!, logItem: self.workoutLog!)
            }
            return cell;
        case .detail:
            let cell : WorkoutDetailInfoTVC = tableView.dequeueReusableCell(withIdentifier: WorkoutDetailInfoTVC.identifier) as! WorkoutDetailInfoTVC
            cell.selectionStyle = .none
            cell.btnInstructor.addTarget(self, action: #selector(self.instructorProfile), for: .touchUpInside)
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
        case .playlist:
            
            let count = self.workoutItem?.playlist.count ?? 0
            if count > 3{
                if self.isViewMore{
                    if indexPath.row >= count{//View More Cell
                        let cell = tableView.dequeueReusableCell(withIdentifier: PlaylistViewMoreTVC.identifier) as! PlaylistViewMoreTVC
                        cell.selectionStyle = .none
                        tableView.separatorStyle = .none
                        cell.btnViewMore.addTarget(self, action: #selector(self.viewMoreAction), for: .touchUpInside)
                        if self.isViewMore{
                            cell.iconImageView.image = UIImage(named: "icon_up_arrow_only")
                            cell.btnViewMore.setTitle("View Less", for: .normal)
                        }else{
                            cell.btnViewMore.setTitle("View More", for: .normal)
                            cell.iconImageView.image = UIImage(named: "icon_down_arrow_only")
                        }
                        return cell
                    }
                }else{
                    if indexPath.row >= 3{//View More Cell
                        let cell = tableView.dequeueReusableCell(withIdentifier: PlaylistViewMoreTVC.identifier) as! PlaylistViewMoreTVC
                        cell.selectionStyle = .none
                        tableView.separatorStyle = .none
                        cell.btnViewMore.addTarget(self, action: #selector(self.viewMoreAction), for: .touchUpInside)
                        if self.isViewMore{
                            cell.btnViewMore.setTitle("View Less", for: .normal)
                            cell.iconImageView.image = UIImage(named: "icon_up_arrow_only")
                        }else{
                            cell.btnViewMore.setTitle("View More", for: .normal)
                            cell.iconImageView.image = UIImage(named: "icon_down_arrow_only")
                        }
                        return cell
                    }
                }
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: PlaylistInfoTVC.identifier) as! PlaylistInfoTVC
            cell.selectionStyle = .none
            tableView.separatorStyle = .none
            let arrPlayList = self.workoutItem?.playlist ?? []
            let item = arrPlayList[indexPath.row]
            cell.setupPlaylistInfo(item: item)
            return cell
            
        /*let cell : PlaylistTVC = tableView.dequeueReusableCell(withIdentifier: PlaylistTVC.identifier) as! PlaylistTVC
         let arrPlayList = self.workoutItem?.playlist ?? []
         cell.updateInforList(list: arrPlayList, isFull: false)
         cell.selectionStyle = .none
         return cell;*/
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.arrSection[section] == .workoutPlan{
            let headerCell = tableView.dequeueReusableCell(withIdentifier: "WorkoutHeaderTVC") as! WorkoutHeaderTVC
            headerCell.lblTitle.text = "Workout Plan"
            return headerCell
        }else if self.arrSection[section] == .playlist{
            let headerCell = tableView.dequeueReusableCell(withIdentifier: "WorkoutHeaderTVC") as! WorkoutHeaderTVC
            headerCell.lblTitle.text = "Playlist"
            return headerCell
        }else{
            return nil
        }
        
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.arrSection[section] == .workoutPlan{
            return 70.0
        }else if self.arrSection[section] == .playlist{
            return 70.0
        }else{
            return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let section = indexPath.section
        let sItem = self.arrSection[section]
        switch sItem {
        case .feedback:
            return UITableView.automaticDimension
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
        case .playlist:
            return UITableView.automaticDimension
        }
    }
}


enum WorkoutDetailSections {
    case feedback
    case detail
    case rating
    case equipment
    case startWorkout
    case workoutPlan
    case playlist
}
