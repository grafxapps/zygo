//
//  FeedbackSheetViewController.swift
//  Zygo
//
//  Created by Priya Gandhi on 13/02/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit
import Branch

protocol FeedbackSheetViewControllerDelegates {
    func feedbackDone()
}

class FeedbackSheetViewController: UIViewController {
    
    @IBOutlet weak var tblList: UITableView!
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var iconImageView: UICircleImageView!
    @IBOutlet weak var btnDoneAction: UIButton!
    
    @IBOutlet weak var tblHeightConstraint: NSLayoutConstraint!
    
    private let cellHeight: CGFloat = 197.0
    
    private var thumbStatus: ThumbStatus = .none
    private var dificultyLevel: Int = -1
    
    var achievements: [AchievementDTO] = []
    var workoutItem: WorkoutDTO!
    var delegate: FeedbackSheetViewControllerDelegates?
    
    private var maxHeight: CGFloat = 90
    private let viewModel = WorkoutPlayerViewModel()
    
    //MARK: -
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, workoutItem: WorkoutDTO,  achievements: [AchievementDTO]) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.workoutItem = workoutItem
        self.achievements = achievements
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.calculateMaxHeight()
        self.registerCustomCells()
        self.setupData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.showBGImage()
    }
    
    //MARK: - Setups
    func showBGImage(){
        self.bgImageView.alpha = 0.0
        UIView.animate(withDuration: 1.0) {
            self.bgImageView.alpha = 0.4
        }
    }
    
    func hideBGImage(){
        self.bgImageView.alpha = 0.0
    }
    
    func setupData(){
        let screenHeight = ScreenSize.SCREEN_HEIGHT
        
        let constantHeight: CGFloat = 300.0
        var tblHeight = cellHeight //* CGFloat(self.list.count)
        if achievements.count > 0{
            self.didScrollAt(0)
            tblHeight = cellHeight + self.maxHeight
        }else{
            tblHeight = cellHeight
        }
        
        let totalHeight = tblHeight + constantHeight
        if  totalHeight > screenHeight{
            self.tblHeightConstraint.constant = tblHeight - (totalHeight - screenHeight)
            self.tblList.isScrollEnabled = true
        }else{
            self.tblHeightConstraint.constant = tblHeight
            self.tblList.isScrollEnabled = false
        }
    }
    
    func registerCustomCells(){
        self.tblList.separatorStyle = .none
        self.tblList.estimatedRowHeight = cellHeight
        self.tblList.register(UINib(nibName: DefaultFeedbackTVC.identifier, bundle: nil), forCellReuseIdentifier: DefaultFeedbackTVC.identifier)
        self.tblList.register(UINib(nibName: FeedbackAchievementTVC.identifier, bundle: nil), forCellReuseIdentifier: FeedbackAchievementTVC.identifier)
    }
    
    func calculateMaxHeight(){
        
        let textWidth = ScreenSize.SCREEN_WIDTH - 30.0
        let textFont = UIFont.appMedium(with: 16.0)
        var itemDescriptionHeight: CGFloat = 0
        
        for item in achievements{
            let height = item.message.height(withConstrainedWidth: textWidth, font: textFont)
            if height > itemDescriptionHeight{
                itemDescriptionHeight = height
            }
        }
        
        self.maxHeight = 90 + itemDescriptionHeight + 30
    }
    
    //MARK: - UIButton Actions
    @IBAction func backAction(_ sender: UIButton){
        self.hideBGImage()
        self.dismiss(animated: true) {
            self.delegate?.feedbackDone()
        }
    }
    
    @IBAction func doneAction(_ sender: UIButton){
        viewModel.workoutFeedback(workoutItem.workoutId, self.thumbStatus, self.dificultyLevel) { (isDone) in
            if isDone{
                self.hideBGImage()
                self.dismiss(animated: true) {
                    self.delegate?.feedbackDone()
                }
            }
        }
    }
    
    @objc @IBAction func shareAction(_ sender: UIButton){
        
        let branchUniversalObject: BranchUniversalObject = BranchUniversalObject(canonicalIdentifier: "Worout_\(workoutItem.workoutName)_\(workoutItem.workoutId)")
        branchUniversalObject.title = "I just completed the \("\(String(format: "%.f", workoutItem.workoutDuration)) min") \(workoutItem.workoutName) workout"
        branchUniversalObject.contentDescription = ""
        branchUniversalObject.imageUrl = workoutItem.thumbnailURL.getImageURL()
        
        let linkProperties: BranchLinkProperties = BranchLinkProperties()
        linkProperties.controlParams = ["workout_id" : workoutItem.workoutId] //workoutItem.toDict()
        
        Helper.shared.startLoading()
        branchUniversalObject.getShortUrl(with: linkProperties) { (url, error) in
            Helper.shared.stopLoading()
            if error == nil {
                if let workoutUrl = URL(string: url ?? ""){
                    Helper.shared.shareWorkout(url: workoutUrl)
                }
            }else{
                Helper.shared.alert(title: Constants.appName, message: error.debugDescription)
            }
        }
    }
    
    //MARK: -
}
extension FeedbackSheetViewController: UITableViewDataSource, UITableViewDelegate, FeedbackAchievementTVCDelegates, DefaultFeedbackTVCDelegates{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return achievements.count > 0 ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if achievements.count > 0{
            if indexPath.row == 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: FeedbackAchievementTVC.identifier) as! FeedbackAchievementTVC
                cell.setupAchievementDetail(arrAchi: self.achievements, maxHeight: self.maxHeight)
                cell.selectionStyle = .none
                cell.delegate = self
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: DefaultFeedbackTVC.identifier) as! DefaultFeedbackTVC
                cell.setupThumb(status: self.thumbStatus)
                cell.delegate = self
                cell.btnShare.addTarget(self, action: #selector(self.shareAction(_:)), for: .touchUpInside)
                cell.selectionStyle = .none
                return cell
            }
            
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: DefaultFeedbackTVC.identifier) as! DefaultFeedbackTVC
            cell.setupThumb(status: self.thumbStatus)
            cell.delegate = self
            cell.btnShare.addTarget(self, action: #selector(self.shareAction(_:)), for: .touchUpInside)
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if achievements.count > 0{
            if indexPath.row == 0{
                return self.maxHeight
            }else{
                return cellHeight
            }
        }else{
            return cellHeight
        }
    }
    
    func didScrollAt(_ position: Int) {
        let item = self.achievements[position]
        self.iconImageView.image = nil //UIImage(named: "placeholder")
        self.iconImageView.backgroundColor = .white
        if !item.icon.isEmpty{
            self.iconImageView.alpha = 0.0
            self.iconImageView.sd_setImage(with: URL(string: item.icon.getImageURL()), placeholderImage: nil, options: .refreshCached) { (image, error, type, url) in  
                UIView.animate(withDuration: 0.4) {
                    self.iconImageView.alpha = 1.0
                }
            }
            //self.iconImageView.sd_setImage(with: URL(string: item.icon.getImageURL()), placeholderImage: nil, options: .refreshCached, completed: nil)
        }
    }
    
    func didSelectFeedback(status: ThumbStatus, dificultyLevel: Int) {
        self.thumbStatus = status
        self.dificultyLevel = dificultyLevel
    }
    
}
