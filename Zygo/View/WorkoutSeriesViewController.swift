//
//  WorkoutSeriesViewController.swift
//  Zygo
//
//  Created by Som on 06/02/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit
import SDWebImage

class WorkoutSeriesViewController: UIViewController {
    
    @IBOutlet weak var tblWorkouts : UITableView!
    private let viewModel = WorkoutsViewModel()
    private var refreshControl = UIRefreshControl()
    @IBOutlet weak var internetConnectionView : UIView!
    
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerTVC()
        self.fetchWorkouts()
        self.addObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.getUserProfile()
    }
    
    deinit {
        self.removeObservers()
    }
    
    //MARK:- Setup
    func addObservers(){
        self.removeObservers()
        NotificationCenter.default.addObserver(self, selector: #selector(self.removeObservers), name: .removeObservers, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateCompltedWorkouts), name: .UpdateCompletedWorkouts, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didSelectTab), name: .didSelectSeriesTab, object: nil)
        
    }
    
    @objc func didSelectTab(){
        if self.viewModel.arrSeriesWorkouts.count > 0{
            self.tblWorkouts.scroll(to: .top, animated: true)
        }
    }
    
    @objc func removeObservers(){
        NotificationCenter.default.removeObserver(self)
    }
    
    func registerTVC()  {
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: [NSAttributedString.Key.font : UIFont.appMedium(with: 16.0)])
        refreshControl.addTarget(self, action: #selector(self.fetchWorkouts), for: .valueChanged)
        tblWorkouts.refreshControl = refreshControl
        
        let rowHeight = Helper.shared.getWorkoutCellHeight()
        tblWorkouts.rowHeight = rowHeight + 10.0 + 34.0
        //tblWorkouts.estimatedRowHeight = 285.0
        tblWorkouts.separatorStyle = .none
        tblWorkouts.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tblWorkouts.register(UINib.init(nibName: SeriesTVC.identifier, bundle: nil), forCellReuseIdentifier: SeriesTVC.identifier);
    }
    
    @objc func fetchWorkouts(){
        self.viewModel.getWorkoutSeriesList { [weak self] (isError) in
            if isError{
                self?.internetConnectionView.isHidden = false
            }else{
                self?.internetConnectionView.isHidden = true
            }
            self?.refreshControl.endRefreshing()
            self?.tblWorkouts.reloadData()
            self?.imagesDownloader()
        }
    }
    
    func imagesDownloader(){
        let arrUrls = self.viewModel.arrSeriesWorkouts.flatMap({ $0.seriesWorkouts.map({ URL(string: $0.thumbnailURL.getImageURL())! })  })
        
        SDWebImagePrefetcher.shared.prefetchURLs(arrUrls)
    }
    
    @objc func updateCompltedWorkouts(){
        DispatchQueue.main.async {
            self.tblWorkouts.reloadData()
        }
    }
    
    //MARK: - UIButtons Action
    @IBAction func homeAction(_ sender: UIButton){
        sideMenuController?.revealMenu()
    }
    
    @IBAction func retryAction(_ sender: UIButton){
        self.fetchWorkouts()
    }
    
}
extension WorkoutSeriesViewController : UITableViewDataSource, UITableViewDelegate, SeriesTVCDelegates{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.arrSeriesWorkouts.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : SeriesTVC = tableView.dequeueReusableCell(withIdentifier: SeriesTVC.identifier) as! SeriesTVC
        cell.delegate = self
        cell.selectionStyle = .none
        let item = self.viewModel.arrSeriesWorkouts[indexPath.row]
        cell.setupWorkoutInfo(item: item)
        return cell;
    }
    
    func didSelect(workout: WorkoutDTO) {
        let playerVC = self.storyboard?.instantiateViewController(withIdentifier: "WorkoutDetailViewController") as! WorkoutDetailViewController
        playerVC.workoutItem = workout
        playerVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(playerVC, animated: true)
    }
}

