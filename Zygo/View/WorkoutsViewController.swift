//
//  WorkoutsViewController.swift
//  Zygo
//
//  Created by Priya Gandhi on 24/01/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit
import SDWebImage

class WorkoutsViewController: UIViewController {
    
    @IBOutlet weak var tblWorkouts : UITableView!
    @IBOutlet weak var lblNoData : UILabel!
    @IBOutlet weak var internetConnectionView : UIView!
    @IBOutlet weak var filterClassesView : UIView!
    @IBOutlet weak var lblFilterClasses : UILabel!
    
    private let workoutIdentifier = "WorkoutInfoTVC"
    private let viewModel = WorkoutsViewModel()
    private var refreshControl = UIRefreshControl()
    private var isFromDidLoad: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addObservers()
        self.registerTVC()
        //self.fetchWorkouts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchWorkouts(isLoading: isFromDidLoad, isFromDidLoad)
        self.viewModel.getUserProfile()   
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AppDelegate.app.protector.preventScreenShoot()
    }
    
    deinit {
        self.removeObservers()
    }
    
    //MARK:- Setup
    func registerTVC()  {
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: [NSAttributedString.Key.font : UIFont.appMedium(with: 16.0)])
        refreshControl.addTarget(self, action: #selector(self.pullToRefresh), for: .valueChanged)
        tblWorkouts.refreshControl = refreshControl
        
        tblWorkouts.contentInset = UIEdgeInsets(top: -5, left: 0, bottom: 0, right: 0)
        tblWorkouts.separatorStyle = .none
        tblWorkouts.register(UINib.init(nibName: workoutIdentifier, bundle: nil), forCellReuseIdentifier: workoutIdentifier);
    }
    
    @objc func pullToRefresh(){
        self.fetchWorkouts(isLoading: true, false)
    }
    
    @objc func fetchWorkouts(isLoading: Bool = true, _ isWait: Bool = true){
        if isFromDidLoad {
            isFromDidLoad = false
        }
        
        let selectedFilters = PreferenceManager.shared.selectedFilters
        if selectedFilters.count > 0 || PreferenceManager.shared.isNotTakenByMe || PreferenceManager.shared.isTakenByMe{
            self.viewModel.getFilteredWorkouts(isLoading:isLoading, isLoadingStop: false, selectedFilters: selectedFilters) { [weak self] (isError) in
                if isError{
                    self?.lblNoData.isHidden = true
                    self?.internetConnectionView.isHidden = false
                    self?.filterClassesView.isHidden = false
                    self?.lblFilterClasses.text = "\(self?.viewModel.arrWorkouts.count ?? 0)"
                    self?.refreshControl.endRefreshing()
                    self?.tblWorkouts.reloadData()
                    Helper.shared.stopLoading()
                }else{
                    self?.internetConnectionView.isHidden = true
                    
                    if self?.viewModel.arrWorkouts.count ?? 0 > 0{
                        self?.lblNoData.isHidden = true
                        //self?.perform(#selector(self?.stopFilteredWorkoutsLoading), with: nil, afterDelay: 3.0)
                        self?.stopFilteredWorkoutsLoading()
                    }else{
                        self?.lblNoData.isHidden = false
                        self?.filterClassesView.isHidden = false
                        self?.lblFilterClasses.text = "\(self?.viewModel.arrWorkouts.count ?? 0)"
                        self?.refreshControl.endRefreshing()
                        self?.tblWorkouts.reloadData()
                        Helper.shared.stopLoading()
                    }
                }
            }
        }else{
            self.filterClassesView.isHidden = true
            self.lblFilterClasses.text = "0"
            self.viewModel.getWorkoutList(isLoading: isLoading, isLoadingStop: false) { [weak self]  (isError) in
                if isError{
                    Helper.shared.stopLoading()
                    self?.lblNoData.isHidden = true
                    self?.internetConnectionView.isHidden = false
                    self?.refreshControl.endRefreshing()
                    self?.tblWorkouts.reloadData()
                }else{
                    self?.internetConnectionView.isHidden = true
                    if self?.viewModel.arrWorkouts.count ?? 0 > 0{
                        self?.lblNoData.isHidden = true
                        self?.imagesDownloader()
                        if isWait{
                            self?.perform(#selector(self?.stopWorkoutsLoading), with: nil, afterDelay: 3.0)
                        }else{
                            self?.stopWorkoutsLoading()
                        }
                        
                    }else{
                        Helper.shared.stopLoading()
                        self?.lblNoData.isHidden = false
                        self?.refreshControl.endRefreshing()
                        self?.tblWorkouts.reloadData()
                    }
                }
            }
        }
        
    }
    
    @objc func stopWorkoutsLoading(){
        Helper.shared.stopLoading()
        self.refreshControl.endRefreshing()
        self.tblWorkouts.reloadData()
    }
    
    @objc func stopFilteredWorkoutsLoading(){
        Helper.shared.stopLoading()
        self.filterClassesView.isHidden = false
        self.lblFilterClasses.text = "\(self.viewModel.arrWorkouts.count)"
        self.refreshControl.endRefreshing()
        self.tblWorkouts.reloadData()
    }
    
    func imagesDownloader(){
        let arrUrls = self.viewModel.arrWorkouts.map({ URL(string: $0.thumbnailURL.getImageURL())! })
        SDWebImagePrefetcher.shared.prefetchURLs(arrUrls)
    }
    
    func addObservers(){
        self.removeObservers()
        NotificationCenter.default.addObserver(self, selector: #selector(self.showFilterWorkouts), name: .fetchWorkouts, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.removeObservers), name: .removeObservers, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateCompltedWorkouts), name: .UpdateCompletedWorkouts, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didSelectTab), name: .didSelectClassesTab, object: nil)
        
    }
    
    @objc func didSelectTab(){
        if self.viewModel.arrWorkouts.count > 0{
            self.tblWorkouts.scroll(to: .top, animated: true)
        }
        
    }
    
    @objc func showFilterWorkouts(){
        self.isFromDidLoad = true
    }
    
    @objc func removeObservers(){
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func updateCompltedWorkouts(){
        DispatchQueue.main.async {
            self.tblWorkouts.reloadData()
        }
    }
    
    @IBAction func retryAction(_ sender: UIButton){
        self.fetchWorkouts()
    }
    
    //MARK: - UIButtons Action
    @IBAction func homeAction(_ sender: UIButton){
        sideMenuController?.revealMenu()
    }
    
    @IBAction func filterAction(_ sender: UIButton){
        let filterVC = self.storyboard?.instantiateViewController(withIdentifier: "FilterViewController") as! FilterViewController
        filterVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(filterVC, animated: true)
    }
    
}

extension WorkoutsViewController : UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.arrWorkouts.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let nCell = cell as? WorkoutInfoTVC else{
            return
        }
        nCell.workoutImage.image = nil
        let item = self.viewModel.arrWorkouts[indexPath.row]
        if !item.thumbnailURL.isEmpty{
            /*nCell.workoutImage.af.setImage(withURL: URL(string: item.thumbnailURL.getImageURL())!, cacheKey: item.thumbnailURL.getImageURL(), placeholderImage: nil, progress: { (progress) in
                
            }, progressQueue: .main, imageTransition: .crossDissolve(0.4), runImageTransitionIfCached: false) { (response) in
                
            }*/
            nCell.workoutImage.sd_setImage(with: URL(string: item.thumbnailURL.getImageURL()), placeholderImage: nil, options: .progressiveLoad, completed: nil)
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : WorkoutInfoTVC = tableView.dequeueReusableCell(withIdentifier: workoutIdentifier) as! WorkoutInfoTVC
        cell.selectionStyle = .none
        let item = self.viewModel.arrWorkouts[indexPath.row]
        cell.setupWorkoutInfo(item: item)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let playerVC = self.storyboard?.instantiateViewController(withIdentifier: "WorkoutDetailViewController") as! WorkoutDetailViewController
        playerVC.workoutItem = self.viewModel.arrWorkouts[indexPath.row]
        playerVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(playerVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}
