//
//  DownloadsViewController.swift
//  Zygo
//
//  Created by Priya Gandhi on 24/01/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit

class DownloadsViewController: UIViewController {
    
    @IBOutlet weak var tblDownloads : UITableView!
    @IBOutlet weak var lblNoWorkouts : UILabel!
    
    private let downloadIdentifier = "DownloadsTVC"
    
    var arrWorkouts: [DownloadWorkoutDTO]  = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerTVC()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupWorkoutsData()
        ZygoWorkoutDownloadManager.shared.downloadComplete = { [weak self] in
            self?.setupWorkoutsData()
        }
    }
    
    //MARK:- Setup
    @objc func setupWorkoutsData(){
        arrWorkouts.removeAll(keepingCapacity: true)
        let arrLocalWorkouts = DatabaseManager.shared.getSavedWorkouts()
        for workoutItem in arrLocalWorkouts{
            let workout = WorkoutDTO(workoutItem.workoutDetailJSON.toDictionary())
            arrWorkouts.append(DownloadWorkoutDTO(workoutItem: workout, workoutLocal: workoutItem))
        }
        
        if arrWorkouts.count > 0{
            lblNoWorkouts.isHidden = true
        }else{
            lblNoWorkouts.isHidden = false
        }
        
        self.tblDownloads.reloadData()
    }
    
    func registerTVC()  {
        tblDownloads.contentInset = UIEdgeInsets(top: -5, left: 0, bottom: 0, right: 0)
        tblDownloads.separatorStyle = .none
        tblDownloads.register(UINib.init(nibName: downloadIdentifier, bundle: nil), forCellReuseIdentifier: downloadIdentifier);
    }
    
    //MARK: - UIButtons Action
    @IBAction func homeAction(_ sender: UIButton){
        sideMenuController?.revealMenu()
    }
    
    @objc func downloadAction(_ sender: UIButton){
        let index = sender.tag
        if index >= self.arrWorkouts.count{
            return
        }
        
        let item = self.arrWorkouts[index]
        DatabaseManager.shared.deleteWrokout(by: "\(item.workoutItem.workoutId)")
        self.arrWorkouts.remove(at: index)
        self.tblDownloads.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
        self.perform(#selector(self.setupWorkoutsData), with: nil, afterDelay: 0.5)
    }
}

extension DownloadsViewController : UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrWorkouts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : DownloadsTVC = tableView.dequeueReusableCell(withIdentifier: downloadIdentifier) as! DownloadsTVC
        cell.selectionStyle = .none
        let item = self.arrWorkouts[indexPath.row]
        cell.setupWorkoutInfo(item: item.workoutItem)
        let workoutStatus = WorkoutDownloadStatus(rawValue: item.workoutLocal.workoutDownloadStatus) ?? .downloaded
        
        cell.btnDelete.addTarget(self, action: #selector(self.downloadAction(_:)), for: .touchUpInside)
        cell.btnDelete.tag = indexPath.row
        if !cell.isDeleteViewHidden(){
            cell.hideDeleteView()
        }
        
        cell.downloadView.isHidden = true
        switch workoutStatus {
        case .downloaded:
            cell.downloadView.isHidden = true
            cell.lblDownloadStatus.text = ""
        case .downloading:
            cell.downloadView.isHidden = false
            cell.lblDownloadStatus.text = "Download in Progress"
        case .paused:
            cell.downloadView.isHidden = false
            cell.lblDownloadStatus.text = "Pending Download"
        case .cancelled:
            cell.downloadView.isHidden = false
            cell.lblDownloadStatus.text = "Pending Download"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 350.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.arrWorkouts[indexPath.row]
        
        let status = WorkoutDownloadStatus(rawValue: item.workoutLocal.workoutDownloadStatus) ?? .downloaded
        if status != .downloaded{
            if status == .paused || status == .cancelled{
                ZygoWorkoutDownloadManager.shared.download(workout: item.workoutItem)
                setupWorkoutsData()
            }
            return
        }
        let playerVC = self.storyboard?.instantiateViewController(withIdentifier: "WorkoutDetailViewController") as! WorkoutDetailViewController
        playerVC.workoutItem = item.workoutItem
        playerVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(playerVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}

extension DownloadsViewController{
    struct DownloadWorkoutDTO {
        var workoutItem: WorkoutDTO = WorkoutDTO([:])
        var workoutLocal: Workout = Workout()
    }
}




