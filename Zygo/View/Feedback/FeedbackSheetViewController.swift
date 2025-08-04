//
//  FeedbackSheetViewController.swift
//  Zygo
//
//  Created by Priya Gandhi on 13/02/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit
import Branch
import CoreLocation

protocol FeedbackSheetViewControllerDelegates {
    func feedbackDone()
}

class FeedbackSheetViewController: UIViewController {
    
    @IBOutlet weak var collectionView : UICollectionView!
    @IBOutlet weak var pageControl : UIPageControl!
    
    static let identifier: String = "FeedbackAchievementTVC"
    private var itemSize: CGSize = CGSize.zero
    
    @IBOutlet weak var tblList: UITableView!
    
    @IBOutlet weak var feedbackView: UIView!
    @IBOutlet weak var syncValView: UIView!
    @IBOutlet weak var distanceValView: UIView!
    @IBOutlet weak var strokeView: UIView!
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var achievementView: UIView!
    
    @IBOutlet weak var shareContentBottomView: UIView!
    
    @IBOutlet weak var feedbackScrollView: UIScrollView!
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var iconImageView: UICircleImageView!
    
    @IBOutlet weak var btnFeedbackDoneAction: UIButton!
    @IBOutlet weak var btnDistanceDoneAction: UIButton!
    @IBOutlet weak var btnStrokeDoneAction: UIButton!
    @IBOutlet weak var btnShareDoneAction: UIButton!
    @IBOutlet weak var btnAchievementDoneAction: UIButton!
    
    @IBOutlet weak var tblHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var lblLapCount: UILabel!
    @IBOutlet weak var lblDistance: UILabel!
    
    @IBOutlet weak var distanceView: UIView!
    @IBOutlet weak var lapCountView: UIView!
    
    @IBOutlet weak var txtLapCount: UITextField!
    @IBOutlet weak var txtDistance: UITextField!
    @IBOutlet weak var txtUnits: UITextField!
    @IBOutlet weak var txtPoolLength: UITextField!
    @IBOutlet weak var lblTotalDistance: UILabel!
    
    @IBOutlet weak var txtStroke: UITextField!
    
    @IBOutlet weak var btnNotAccurate: UIButton!
    
    @IBOutlet weak var lblWorkoutName: UILabel!
    @IBOutlet weak var workoutImage: UIImageView!
    @IBOutlet weak var lblWorkoutDistance: UILabel!
    
    private lazy var poolLengthPicker = UIPickerView()
    private lazy var distanceUnitsPicker = UIPickerView()
    private lazy var lapCountPicker = UIPickerView()
    private lazy var strokePicker = UIPickerView()
    
    private var arrPoolType: [PoolType] = [.fiftyMeter, .twentyFiveYards, .openWater, .endlessPool, .custom]
    private var arrDistanceUnits: [PoolLengthUnit] = [.feet, .yards, .meters]
    private var arrLapCount: [Int] = []
    
    private let cellHeight: CGFloat = 197.0
    
    private var thumbStatus: ThumbStatus = .none
    private var dificultyLevel: Int = -1
    
    var achievements: [AchievementDTO] = []
    var workoutItem: WorkoutDTO!
    var workoutLogId: Int = -1
    var delegate: FeedbackSheetViewControllerDelegates?
    
    var isNoWorkout: Bool = false
    var isNoWorkoutMetric: Bool = false
    var noWorkoutStrokeValue: Int = 50
    
    private var maxHeight: CGFloat = 90
    private let viewModel = WorkoutPlayerViewModel()
    private var poolInfo = PreferenceManager.shared.poolUnitInfo
    private var currentIndex: CGFloat = 0
    
    private var selectedPoolLength: Int = -1
    private var selectedPoolLengthUnits: String = ""
    private var selectedPoolType: String = ""
    private var selectedLaps: Int = -1
    private var selectedDistance: Double = -1
    private var selectedCity: String = ""
    
    private var isOutOfPool: Bool = false
    private var isOpenWater: Bool = false
    private var isOutOfSync: Bool = false
    private var isDontKnow: Bool = false
    private var timeElapsed: Int = 0
    
    //MARK: -
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, workoutItem: WorkoutDTO,  achievements: [AchievementDTO], workoutLogId: Int, timeElapsed: Int) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.workoutItem = workoutItem
        self.achievements = achievements
        self.workoutLogId = workoutLogId
        self.timeElapsed = timeElapsed
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.calculateMaxHeight()
        self.registerCustomCells()
        self.setupData()
        self.setupPickers()
        self.setupPoolInfo()
        self.registerCollectionCustomCells()
        self.setupAchievementDetail()
        
        /*BluetoothManager.shared.enableLapDataNotification { lapInfo in
            if self.currentIndex > 0{
                BluetoothManager.shared.disableLapDataNotification()
                return
            }
            self.updateLapInfo()
        }*/
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupData()
        let location = CLLocation(latitude: LocationManager.shared.currentLocation.latitude, longitude: LocationManager.shared.currentLocation.longitude)
        Helper.shared.getAddressFromGeocodeCoordinate(coordinate: location) { (city) in
            self.selectedCity = city
        }
        
        self.showBGImage()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setupData()
    }
    
    //MARK: - Setups
    
    func registerCollectionCustomCells(){
        
        let layout = UICollectionViewFlowLayout();
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal; //.horizontal
        layout.itemSize = CGSize(width: ScreenSize.SCREEN_WIDTH - 30.0, height: 178.0)
        self.collectionView.collectionViewLayout = layout
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        
        self.collectionView.register(UINib.init(nibName: FeedbackAchievementCVC.identifier, bundle: nil), forCellWithReuseIdentifier: FeedbackAchievementCVC.identifier)
    }
    
    func setupAchievementDetail(){
        
        if self.achievements.count > 1{
            self.pageControl.numberOfPages = self.achievements.count
        }else{
            self.pageControl.numberOfPages = 0
        }
        
        let textWidth = ScreenSize.SCREEN_WIDTH - 30.0
        self.itemSize = CGSize(width: textWidth, height: maxHeight - 25)
        
        self.collectionView.reloadData()
    }
    
    func updateLapInfo(lapData: BLELapInfoDTO){
        //let lapData = PreferenceManager.shared.lapInfo
        print("Number Of Laps in UpdateLapInfo: \(lapData.numberOfLaps)")
        let numberOfLaps = lapData.numberOfLaps
        self.txtLapCount.text = "\(numberOfLaps)"
        if numberOfLaps > 0{
            self.txtDistance.text = "\(numberOfLaps)"
        }
        
        if let index = self.arrLapCount.firstIndex(where: { $0 == numberOfLaps }){
            self.lapCountPicker.selectRow(index, inComponent: 0, animated: false)
        }
    }
    
    func setupPickers(){
        
        arrLapCount.removeAll()
        for lap in 1...1000{
            arrLapCount.append(lap)
        }
        
        self.txtDistance.delegate = self
        
        self.poolLengthPicker.dataSource = self
        self.poolLengthPicker.delegate = self
        self.txtPoolLength.inputView = poolLengthPicker
        self.txtPoolLength.delegate = self
        
        self.lapCountPicker.dataSource = self
        self.lapCountPicker.delegate = self
        self.lapCountPicker.selectRow(24, inComponent: 0, animated: false)
        self.txtLapCount.inputView = lapCountPicker
        self.txtLapCount.delegate = self
        
        self.distanceUnitsPicker.dataSource = self
        self.distanceUnitsPicker.delegate = self
        self.txtUnits.inputView = distanceUnitsPicker
        self.txtUnits.delegate = self
        
        self.strokePicker.dataSource = self
        self.strokePicker.delegate = self
        self.txtStroke.inputView = strokePicker
        self.txtStroke.delegate = self
        
        self.txtStroke.text = ""
        
        let info = PreferenceManager.shared.trackingInfo
        let cTempo = TempoTrainerManager.shared.currentTrainer
        if (info.isTempoTracking && cTempo != nil) || (info.isTempoTracking && isNoWorkout){
            if isNoWorkout{
                self.strokePicker.selectRow(noWorkoutStrokeValue - 1, inComponent: 0, animated: false)
                self.txtStroke.text = "\(noWorkoutStrokeValue)"
            }else{
                if let currentTempo = TempoTrainerManager.shared.currentTrainer{
                    switch currentTempo.type{
                    case .lapInterval:
                        self.strokePicker.selectRow(49, inComponent: 0, animated: false)
                        self.txtStroke.text = "50"
                    case .strokeRate:
                        self.strokePicker.selectRow((currentTempo.strokesPerMinute - 1), inComponent: 0, animated: false)
                        self.txtStroke.text = "\(currentTempo.strokesPerMinute)"
                    }
                }else{
                    self.strokePicker.selectRow(49, inComponent: 0, animated: false)
                    self.txtStroke.text = "50"
                }
            }
            
        }
    }
    
    func setupPoolInfo(){
        
        self.hideDistanceView()
        self.hideLapCountView()
        
        switch self.poolInfo.defaultPoolLength {
        case .twentyFiveYards:
            self.showLapCountView()
        case .fiftyMeter:
            self.showLapCountView()
        case .openWater:
            self.showDistanceView()
        case .endlessPool:
            self.showDistanceView()
        case .custom:
            self.showLapCountView()
        }
        
        if poolInfo.defaultPoolLength == .custom{
            if poolInfo.customPoolDistance.remainder(dividingBy: 1) > 0{
                self.txtPoolLength.text = "\(poolInfo.customPoolDistance) \(poolInfo.customPoolLengthUnits.rawValue.lowercased())"
            }else{
                self.txtPoolLength.text = "\(Int(poolInfo.customPoolDistance)) \(poolInfo.customPoolLengthUnits.rawValue.lowercased())"
            }
            
        }else{
            self.txtPoolLength.text = poolInfo.defaultPoolLength.rawValue.firstUppercased
        }
        
        
        if let selectedIndex = self.arrPoolType.firstIndex(where: { $0 == poolInfo.defaultPoolLength }){
            self.poolLengthPicker.selectRow(selectedIndex, inComponent: 0, animated: false)
        }
        
        self.updateDistanceOnLabel()
    }
    
    
    func showDistanceView(){
        self.lblDistance.isHidden = false
        self.distanceView.isHidden = false
    }
    
    func hideDistanceView(){
        self.lblDistance.isHidden = true
        self.distanceView.isHidden = true
    }
    
    func showLapCountView(){
        self.lblLapCount.isHidden = false
        self.lapCountView.isHidden = false
        
        let distance = Int(self.txtDistance.text ?? "0") ?? 0
        if distance > 0{
            if let index = self.arrLapCount.firstIndex(where: { $0 == distance }){
                self.lapCountPicker.selectRow(index, inComponent: 0, animated: false)
                self.txtLapCount.text = "\(distance)"
            }
        }
    }
    
    func hideLapCountView(){
        self.lblLapCount.isHidden = true
        self.lapCountView.isHidden = true
    }
    
    
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
        
        self.shareContentBottomView.layer.cornerRadius = 10.0
        self.shareContentBottomView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
        let screenHeight = ScreenSize.SCREEN_HEIGHT
        
        let constantHeight: CGFloat = 300.0
        var tblHeight = cellHeight //* CGFloat(self.list.count)
        /*if achievements.count > 0{
         self.didScrollAt(0)
         tblHeight = cellHeight + self.maxHeight
         }else{*/
        tblHeight = cellHeight
        //}
        
        let totalHeight = tblHeight + constantHeight
        if  totalHeight > screenHeight{
            self.tblHeightConstraint.constant = tblHeight - (totalHeight - screenHeight)
            self.tblList.isScrollEnabled = true
        }else{
            self.tblHeightConstraint.constant = tblHeight
            self.tblList.isScrollEnabled = false
        }
        
        if isNoWorkout || isNoWorkoutMetric{
            self.feedbackView.isHidden = true
            self.shareView.isHidden = true
        }
        
        self.syncValView.isHidden = true
        self.distanceValView.isHidden = true
        self.strokeView.isHidden = true
        self.achievementView.isHidden = true
        //
        let info = PreferenceManager.shared.trackingInfo
        if info.isDistanceTracking{
            //Check if sync data is 3 mintues old then show sync status screen
            if Helper.shared.isHeadsetSyncRecent(){
                self.syncValView.isHidden = true
            }else if PreferenceManager.shared.isBLEEnabledDevice{
                self.syncValView.isHidden = false
            }else{
                self.syncValView.isHidden = true
            }
            self.distanceValView.isHidden = false
        }
        
        let currentTempo = TempoTrainerManager.shared.currentTrainer
        if (info.isTempoTracking && currentTempo != nil) || (info.isTempoTracking && isNoWorkout){
            self.strokeView.isHidden = false
        }
        
        if self.achievements.count > 0{
            self.achievementView.isHidden = false
        }
        
        
        if poolInfo.unitPref == .metric{
            self.txtUnits.text = PoolLengthUnit.meters.rawValue.firstUppercased
        }else{
            self.txtUnits.text = PoolLengthUnit.yards.rawValue.firstUppercased
        }
        
        self.updateLapInfo(lapData: PreferenceManager.shared.lapInfo)
        
        if self.isNoWorkout || self.isNoWorkoutMetric{
            if info.isDistanceTracking{
                self.currentIndex = 2
            }else if info.isTempoTracking{
                self.currentIndex = 3
            }else if self.achievements.count > 0{
                self.currentIndex = 5
            }
            
            let x = ScreenSize.SCREEN_WIDTH * self.currentIndex
            self.feedbackScrollView.setContentOffset(CGPoint(x: x, y: 0), animated: false)
            self.updateNotAccurate()
        }else{
            self.lblWorkoutName.text = "I just completed the \("\(String(format: "%.f", workoutItem.workoutDuration)) min") \(workoutItem.workoutName) workout"
            self.workoutImage.sd_setImage(with: URL(string: workoutItem.thumbnailURL.getImageURL()), placeholderImage: nil, options: .refreshCached, completed: nil)
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
    
    func updateFeedbackOnServer(dismissOnDone: Bool = false){
        
        let strokeValue = Int(txtStroke.text!) ?? 0
         
        self.viewModel.workoutFeedback(self.workoutItem.workoutId, self.thumbStatus, self.dificultyLevel, workoutLogId: self.workoutLogId, poolLength: self.selectedPoolLength, poolLengthUnits: self.selectedPoolLengthUnits, poolType: self.selectedPoolType, laps: self.selectedLaps, distance: self.selectedDistance, strokeVlue: strokeValue, city: self.selectedCity, timeElapsed: self.timeElapsed, whyBreak: self.isOutOfPool, whyEndless: self.isOpenWater, whyNoSync: self.isOutOfSync, whyDontKnow: self.isDontKnow) { (isDone) in
            
            Helper.shared.log(event: .WORKOUTFEEDBACK, params: [:])
            if isDone{
                if dismissOnDone{
                    self.hideBGImage()
                    self.dismiss(animated: true) {
                        self.delegate?.feedbackDone()
                    }
                }
            }
        }
        
    }
    
    func updateDistanceOnLabel(){
        
        var totalDistance: Double = 0
        var toUnit: UnitLength = .yards
        var fromUnit: PoolLengthUnit = .feet
        var fromDistance: Double = 0
        var totalLapCount: Int = 0
        
        let poolType = self.poolInfo.defaultPoolLength
        
        switch poolType {
        case .twentyFiveYards:
            let lap = Int(self.txtLapCount.text!) ?? 0
            fromUnit = .yards
            fromDistance = 25
            totalLapCount = lap
        case .fiftyMeter:
            let lap = Int(self.txtLapCount.text!) ?? 0
            fromUnit = .meters
            fromDistance = 50
            totalLapCount = lap
        case .openWater:
            let lap = 1
            fromUnit = PoolLengthUnit(rawValue: self.txtUnits.text!.lowercased()) ?? .meters
            fromDistance = Double(self.txtDistance.text!) ?? 0
            totalLapCount = lap
        case .endlessPool:
            let lap = 1
            fromUnit = PoolLengthUnit(rawValue: self.txtUnits.text!.lowercased()) ?? .meters
            fromDistance = Double(self.txtDistance.text!) ?? 0
            totalLapCount = lap
        case .custom:
            let lap = Int(self.txtLapCount.text!) ?? 0
            fromUnit = self.poolInfo.customPoolLengthUnits
            fromDistance = self.poolInfo.customPoolDistance
            totalLapCount = lap
        }
        
        
        totalDistance = Helper.shared.distanceConvert(to: .yards ,from: fromUnit, distance: fromDistance) * Double(totalLapCount)
        if totalDistance >= 1{
            self.lblWorkoutDistance.text = String(format: "%.0f yards", totalDistance)
        }else{
            self.lblWorkoutDistance.text = ""
        }
        
        
        var strUnit = ""
        if self.poolInfo.unitPref == .metric{
            //Meter
            toUnit = .kilometers
            strUnit = "km"
        }else{
            //Yards
            toUnit = .miles
            strUnit = "miles"
        }
        
        if self.poolInfo.unitPref == .metric{
            if totalDistance < 1094{
                //Meter
                toUnit = .meters
                strUnit = "meters"
                
                totalDistance = Helper.shared.distanceConvert(to: toUnit ,from: fromUnit, distance: fromDistance) * Double(totalLapCount)
                
                if totalDistance >= 1{
                    self.lblTotalDistance.text = String(format: "%.0f \(strUnit)", totalDistance)
                }else{
                    self.lblTotalDistance.text = ""
                }
                
            }else{
                //Kilometer
                toUnit = .kilometers
                strUnit = "km"
                
                totalDistance = Helper.shared.distanceConvert(to: toUnit ,from: fromUnit, distance: fromDistance) * Double(totalLapCount)
                
                if totalDistance > 0{
                    self.lblTotalDistance.text = String(format: "%.1f \(strUnit)", totalDistance)
                }else{
                    self.lblTotalDistance.text = ""
                }
            }
        }else{
            if totalDistance < 1760{
                //yards
                toUnit = .yards
                strUnit = "yards"
                
                totalDistance = Helper.shared.distanceConvert(to: toUnit ,from: fromUnit, distance: fromDistance) * Double(totalLapCount)
                
                if totalDistance >= 1{
                    self.lblTotalDistance.text = String(format: "%.0f \(strUnit)", totalDistance)
                }else{
                    self.lblTotalDistance.text = ""
                }
            }else{
                //Miles
                toUnit = .miles
                strUnit = "miles"
                
                totalDistance = Helper.shared.distanceConvert(to: toUnit ,from: fromUnit, distance: fromDistance) * Double(totalLapCount)
                
                if totalDistance > 0{
                    self.lblTotalDistance.text = String(format: "%.1f \(strUnit)", totalDistance)
                }else{
                    self.lblTotalDistance.text = ""
                }
            }
        }
        
    }
    
    @objc func updateBLEInfo(){
        
        //Check If device is connected or not
        if !BluetoothManager.shared.isZygoDeviceConencted(){
            self.startDeviceSearching()
            return
        }
        
        self.updateDeviceBatteryInfo()
        self.updateDeviceLapInfo()
    }
    
    func startDeviceSearching(){
        self.startWaitOverTimer()
        BLEConnectionManager.shared.stopScanning()
        BLEConnectionManager.shared.startAutoConnectScanning { [weak self] in
            self?.updateDeviceBatteryInfo()
            self?.updateDeviceLapInfo()
        }
    }
    
    private var waitTimer: Timer?
    func startWaitOverTimer(){
        self.stopWaitOverTImer()
        self.waitTimer = Timer(timeInterval: 30, repeats: false, block: { timerObj in
            DispatchQueue.main.async {
                BLEConnectionManager.shared.stopScanning()
            }
            timerObj.invalidate()
        })
        
        RunLoop.main.add(self.waitTimer!, forMode: .common)
    }
    
    func stopWaitOverTImer(){
        self.waitTimer?.invalidate()
        self.waitTimer = nil
    }
    
    func updateDeviceBatteryInfo(){
        
        BluetoothManager.shared.readHardwareInfo { [weak self] deviceInfo in
            DispatchQueue.main.async {
                
            }
        }
    }
    
    func updateDeviceLapInfo(){
        
        BluetoothManager.shared.readLapData { [weak self] lapInfo in
            DispatchQueue.main.async {
                
                self?.updateLapInfo(lapData: lapInfo ?? PreferenceManager.shared.lapInfo)
                if Helper.shared.isHeadsetSyncRecent(){
                    self?.currentIndex = 2
                    let x = ScreenSize.SCREEN_WIDTH * (self?.currentIndex ?? 2.0)
                    self?.feedbackScrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
                    self?.updateNotAccurate()
                }
                let deviceInfo = PreferenceManager.shared.deviceInfo
                if deviceInfo.versionInfo.zygoDeviceVersion == .v2{
                    BluetoothManager.shared.readZygo2TranmistterSerialNumber { transmitterSerialNumber in
                        print("Zygo2 Transmitter Serial Number: \(transmitterSerialNumber)")
                        PreferenceManager.shared.transmitterSerialNumber = transmitterSerialNumber
                    }
                }else{
                    
                }
                BluetoothManager.shared.enableLapDataNotification { notiBLEInfo in
                    DispatchQueue.main.async {
                        if let updatedLapInfo = notiBLEInfo{
                            PreferenceManager.shared.lapInfo = updatedLapInfo
                        }
                        if self?.currentIndex ?? 2 > 1{
                            BluetoothManager.shared.disableLapDataNotification()
                            return
                        }
                        self?.updateLapInfo(lapData: notiBLEInfo ?? PreferenceManager.shared.lapInfo)
                        if Helper.shared.isHeadsetSyncRecent(){
                            self?.currentIndex = 2
                            let x = ScreenSize.SCREEN_WIDTH * (self?.currentIndex ?? 2.0)
                            self?.feedbackScrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
                            self?.updateNotAccurate()
                        }
                    }
                }
            }
        }
        
    }
    
    func updateNotAccurate(isFromSkip: Bool = false){
        
        if isFromSkip{
            self.btnNotAccurate.isHidden = false
            self.btnNotAccurate.setTitle("No lap count found", for: .normal)
            self.btnNotAccurate.isUserInteractionEnabled = false
        }else if Helper.shared.isHeadsetSyncRecent(){
            let lapInfo = PreferenceManager.shared.lapInfo
            //if lapInfo.oldNewStatus != 1{
            if lapInfo.numberOfLaps == 0{
                self.btnNotAccurate.isHidden = false
                self.btnNotAccurate.setTitle("No lap count found", for: .normal)
                self.btnNotAccurate.isUserInteractionEnabled = false
            }else{
                self.btnNotAccurate.isHidden = false
                self.btnNotAccurate.setTitle("Not accurate?", for: .normal)
                self.btnNotAccurate.isUserInteractionEnabled = true
            }
        }else if !PreferenceManager.shared.isBLEEnabledDevice{
            self.btnNotAccurate.isHidden = true
        }else{
            self.btnNotAccurate.isHidden = false
            self.btnNotAccurate.setTitle("Not accurate?", for: .normal)
            self.btnNotAccurate.isUserInteractionEnabled = true
        }
        
    }
    
    //MARK: - UIButton Actions
    @IBAction func backAction(_ sender: UIButton){
        self.hideBGImage()
        self.dismiss(animated: true) {
            self.delegate?.feedbackDone()
        }
    }
    
    @IBAction func doneAction(_ sender: UIButton){
        let info = PreferenceManager.shared.trackingInfo
        let currentTempo = TempoTrainerManager.shared.currentTrainer
        if info.isDistanceTracking{
            //Check if sync data is 3 mintues old then show sync status screen
            if Helper.shared.isHeadsetSyncRecent(){
                self.currentIndex = 2
            }else if !PreferenceManager.shared.isBLEEnabledDevice{
                self.currentIndex = 2
            }else{
                self.currentIndex = 1
                self.updateBLEInfo()
            }
            
            let x = ScreenSize.SCREEN_WIDTH * self.currentIndex
            self.feedbackScrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
            self.updateNotAccurate()
        }else if info.isTempoTracking && currentTempo != nil{
            self.currentIndex = 3
            let x = ScreenSize.SCREEN_WIDTH * self.currentIndex
            self.feedbackScrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
        }else{
            self.updateFeedbackOnServer()
            self.currentIndex = 4
            let x = ScreenSize.SCREEN_WIDTH * self.currentIndex
            self.feedbackScrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
        }
    }
    
    @IBAction func skipFeedbackAction(_ sender: UIButton){
        let info = PreferenceManager.shared.trackingInfo
        let currentTempo = TempoTrainerManager.shared.currentTrainer
        if info.isDistanceTracking{
            //Check if sync data is 3 mintues old then show sync status screen
            if Helper.shared.isHeadsetSyncRecent(){
                self.currentIndex = 2
            }else if !PreferenceManager.shared.isBLEEnabledDevice{
                self.currentIndex = 2
            }else{
                self.currentIndex = 1
                self.updateBLEInfo()
            }
            let x = ScreenSize.SCREEN_WIDTH * self.currentIndex
            self.feedbackScrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
            self.updateNotAccurate()
        }else if info.isTempoTracking && currentTempo != nil{
            self.currentIndex = 3
            let x = ScreenSize.SCREEN_WIDTH * self.currentIndex
            self.feedbackScrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
        }else{
            self.currentIndex = 4
            let x = ScreenSize.SCREEN_WIDTH * self.currentIndex
            self.feedbackScrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
        }
    }
    
    @IBAction func syncStatusAction(_ sender: UIButton){
        //Show BLE sync screen popup
        let syncVC = SyncStatusPopupVC(nibName: "SyncStatusPopupVC", bundle: nil)
        syncVC.onExit = {
            
            self.updateLapInfo(lapData: PreferenceManager.shared.lapInfo)
            
            if Helper.shared.isHeadsetSyncRecent(){
                self.currentIndex = 2
                let x = ScreenSize.SCREEN_WIDTH * self.currentIndex
                self.feedbackScrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
                self.updateNotAccurate()
            }
        }
        syncVC.transitioningDelegate = self
        syncVC.modalPresentationStyle = .custom
        self.present(syncVC, animated: true)
    }
    
    @IBAction func skipSyncStatusAction(_ sender: UIButton){
        self.currentIndex = 2
        let x = ScreenSize.SCREEN_WIDTH * self.currentIndex
        self.feedbackScrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
        self.updateNotAccurate(isFromSkip: true)
    }
    
    @IBAction func distanceDoneAction(_ sender: UIButton){
        let poolType = self.poolInfo.defaultPoolLength
        
        if poolType == .custom || poolType == .fiftyMeter || poolType == .twentyFiveYards{
            if self.txtLapCount.text!.isEmpty{
                Helper.shared.alert(title: Constants.appName, message: "Please select lap count.")
                return
                
            }
        }else{
            
            if self.txtDistance.text!.isEmpty{
                Helper.shared.alert(title: Constants.appName, message: "Please enter distance.")
                return
            }
        }
        
        switch poolType {
        case .twentyFiveYards:
            self.selectedLaps = Int(self.txtLapCount.text!) ?? 0
            self.selectedPoolType = self.poolInfo.defaultPoolLength.rawValue
            self.selectedPoolLength = 25
            self.selectedPoolLengthUnits = PoolLengthUnit.yards.rawValue
            self.selectedDistance = Helper.shared.distanceConvert(to: .yards ,from: .yards, distance: 25) * Double(self.selectedLaps)
        case .fiftyMeter:
            self.selectedLaps = Int(self.txtLapCount.text!) ?? 0
            self.selectedPoolType = self.poolInfo.defaultPoolLength.rawValue
            self.selectedPoolLength = 50
            self.selectedPoolLengthUnits = PoolLengthUnit.meters.rawValue
            self.selectedDistance = Helper.shared.distanceConvert(to: .yards ,from: .meters, distance: 50) * Double(self.selectedLaps)
        case .openWater:
            self.selectedLaps = 1
            self.selectedPoolType = self.poolInfo.defaultPoolLength.rawValue
            self.selectedPoolLength = Int(self.txtDistance.text!) ?? 0
            let unit = PoolLengthUnit(rawValue: self.txtUnits.text!.lowercased()) ?? .meters
            self.selectedPoolLengthUnits = self.txtUnits.text!.lowercased()
            self.selectedDistance = Helper.shared.distanceConvert(to: .yards ,from: unit, distance: Double(self.selectedPoolLength)) * Double(self.selectedLaps)
        case .endlessPool:
            self.selectedLaps = 1
            self.selectedPoolType = self.poolInfo.defaultPoolLength.rawValue
            self.selectedPoolLength = Int(self.txtDistance.text!) ?? 0
            let unit = PoolLengthUnit(rawValue: self.txtUnits.text!.lowercased()) ?? .meters
            self.selectedPoolLengthUnits = self.txtUnits.text!.lowercased()
            self.selectedDistance = Helper.shared.distanceConvert(to: .yards ,from: unit, distance: Double(self.selectedPoolLength)) * Double(self.selectedLaps)
        case .custom:
            self.selectedLaps = Int(self.txtLapCount.text!) ?? 0
            self.selectedPoolType = self.poolInfo.defaultPoolLength.rawValue
            self.selectedPoolLength = Int(self.poolInfo.customPoolDistance)
            self.selectedPoolLengthUnits = self.poolInfo.customPoolLengthUnits.rawValue
            self.selectedDistance = Helper.shared.distanceConvert(to: .yards ,from: self.poolInfo.customPoolLengthUnits, distance: self.poolInfo.customPoolDistance) * Double(self.selectedLaps)
        }
        
        
        let info = PreferenceManager.shared.trackingInfo
        if self.isNoWorkout{
            if info.isTempoTracking && isNoWorkout{
                self.currentIndex = 3
                let x = ScreenSize.SCREEN_WIDTH * self.currentIndex
                self.feedbackScrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
            }else if self.achievements.count > 0{
                self.updateFeedbackOnServer()
                self.currentIndex = 5
                let x = ScreenSize.SCREEN_WIDTH * self.currentIndex
                self.feedbackScrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
            }else{
                self.hideBGImage()
                self.dismiss(animated: true) {
                    self.delegate?.feedbackDone()
                }
            }
        }else if isNoWorkoutMetric{
            let currentTempo = TempoTrainerManager.shared.currentTrainer
            if info.isTempoTracking && currentTempo != nil{
                self.currentIndex = 3
                let x = ScreenSize.SCREEN_WIDTH * self.currentIndex
                self.feedbackScrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
            }else if self.achievements.count > 0{
                self.updateFeedbackOnServer()
                self.currentIndex = 5
                let x = ScreenSize.SCREEN_WIDTH * self.currentIndex
                self.feedbackScrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
            }else{
                self.updateFeedbackOnServer(dismissOnDone: true)
            }
        }else{
            let currentTempo = TempoTrainerManager.shared.currentTrainer
            if info.isTempoTracking && currentTempo != nil{
                self.currentIndex = 3
                let x = ScreenSize.SCREEN_WIDTH * self.currentIndex
                self.feedbackScrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
            }else{
                self.updateFeedbackOnServer()
                self.currentIndex = 4
                let x = ScreenSize.SCREEN_WIDTH * self.currentIndex
                self.feedbackScrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
            }
        }
        
        
    }
    
    @IBAction func skipDistanceAction(_ sender: UIButton){
        let info = PreferenceManager.shared.trackingInfo
        if self.isNoWorkout{
            if info.isTempoTracking && isNoWorkout{
                self.currentIndex = 3
                let x = ScreenSize.SCREEN_WIDTH * self.currentIndex
                self.feedbackScrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
            }else if self.achievements.count > 0{
                self.updateFeedbackOnServer()
                self.currentIndex = 5
                let x = ScreenSize.SCREEN_WIDTH * self.currentIndex
                self.feedbackScrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
            }else{
                self.hideBGImage()
                self.dismiss(animated: true) {
                    self.delegate?.feedbackDone()
                }
            }
        }else if isNoWorkoutMetric{
            let currentTempo = TempoTrainerManager.shared.currentTrainer
            if info.isTempoTracking && currentTempo != nil{
                self.currentIndex = 3
                let x = ScreenSize.SCREEN_WIDTH * self.currentIndex
                self.feedbackScrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
            }else if self.achievements.count > 0{
                self.updateFeedbackOnServer()
                self.currentIndex = 5
                let x = ScreenSize.SCREEN_WIDTH * self.currentIndex
                self.feedbackScrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
            }else{
                
                self.hideBGImage()
                self.dismiss(animated: true) {
                    self.delegate?.feedbackDone()
                }
            }
        }else{
            let currentTempo = TempoTrainerManager.shared.currentTrainer
            if info.isTempoTracking && currentTempo != nil{
                self.currentIndex = 3
                let x = ScreenSize.SCREEN_WIDTH * self.currentIndex
                self.feedbackScrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
            }else{
                self.currentIndex = 4
                let x = ScreenSize.SCREEN_WIDTH * self.currentIndex
                self.feedbackScrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
            }
        }
        
    }
    
    @IBAction func streakDoneAction(_ sender: UIButton){
        self.updateFeedbackOnServer()
        if self.isNoWorkout || self.isNoWorkoutMetric{
            if self.achievements.count > 0{
                self.currentIndex = 5
                let x = ScreenSize.SCREEN_WIDTH * self.currentIndex
                self.feedbackScrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
            }else{
                self.hideBGImage()
                self.dismiss(animated: true) {
                    self.delegate?.feedbackDone()
                }
            }
        }else{
            self.currentIndex = 4
            let x = ScreenSize.SCREEN_WIDTH * self.currentIndex
            self.feedbackScrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
        }
        
    }
    
    @IBAction func skipStreakAction(_ sender: UIButton){
        self.updateFeedbackOnServer()
        if self.isNoWorkout || self.isNoWorkoutMetric{
            if self.achievements.count > 0{
                self.currentIndex = 5
                let x = ScreenSize.SCREEN_WIDTH * self.currentIndex
                self.feedbackScrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
            }else{
                self.hideBGImage()
                self.dismiss(animated: true) {
                    self.delegate?.feedbackDone()
                }
            }
        }else{
            self.currentIndex = 4
            let x = ScreenSize.SCREEN_WIDTH * self.currentIndex
            self.feedbackScrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
        }
        
    }
    
    @IBAction func shareDoneAction(_ sender: UIButton){
        
        self.shareAction { workoutUrl in
            Helper.shared.shareWorkout(url: workoutUrl){
                if self.achievements.count > 0{
                    
                    self.currentIndex = 5
                    let x = ScreenSize.SCREEN_WIDTH * self.currentIndex
                    self.feedbackScrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
                }else{
                    self.hideBGImage()
                    self.dismiss(animated: true) {
                        self.delegate?.feedbackDone()
                    }
                }
            }
        }
    }
    
    @IBAction func shareSkipAction(_ sender: UIButton){
        if self.achievements.count > 0{
            self.currentIndex = 5
            let x = ScreenSize.SCREEN_WIDTH * self.currentIndex
            self.feedbackScrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
        }else{
            self.hideBGImage()
            self.dismiss(animated: true) {
                self.delegate?.feedbackDone()
            }
        }
    }
    
    @IBAction func achievementDoneAction(_ sender: UIButton){
        self.hideBGImage()
        self.dismiss(animated: true) {
            self.delegate?.feedbackDone()
        }
    }
    
    @objc func shareAction(completion: @escaping (URL) -> Void){
        
        Helper.shared.log(event: .SHAREWORKOUT, params: ["workout_id": workoutItem.workoutId, "workout_name": workoutItem.workoutName])
        
        let branchUniversalObject: BranchUniversalObject = BranchUniversalObject(canonicalIdentifier: "Worout_\(workoutItem.workoutName)_\(workoutItem.workoutId)")
        branchUniversalObject.title = "I just completed the \("\(String(format: "%.f", workoutItem.workoutDuration)) min") \(workoutItem.workoutName) workout"
        branchUniversalObject.contentDescription = ""
        branchUniversalObject.imageUrl = "https://i.postimg.cc/XvkJDpYG/1624553525866.png"//workoutItem.thumbnailURL.getImageURL()
        
        let linkProperties: BranchLinkProperties = BranchLinkProperties()
        linkProperties.controlParams = ["workout_id" : workoutItem.workoutId] //workoutItem.toDict()
        
        Helper.shared.startLoading()
        branchUniversalObject.getShortUrl(with: linkProperties) { (url, error) in
            Helper.shared.stopLoading()
            if error == nil {
                if let workoutUrl = URL(string: url ?? ""){
                    completion(workoutUrl)
                }
            }else{
                Helper.shared.alert(title: Constants.appName, message: error.debugDescription)
            }
        }
    }
    
    @IBAction func poolLengthAction(_ sender: UIButton){
        self.txtPoolLength.becomeFirstResponder()
    }
    
    @IBAction func distanceUnitsAction(_ sender: UIButton){
        self.txtUnits.becomeFirstResponder()
    }
    
    @IBAction func lapCountAction(_ sender: UIButton){
        self.txtLapCount.becomeFirstResponder()
    }
    
    @IBAction func strokeAction(_ sender: UIButton){
        self.txtStroke.becomeFirstResponder()
    }
    
    @IBAction func notAccurateAction(_ sender: UIButton){
        
        let notAccurateVC = NotAccuratePopupVC(nibName: "NotAccuratePopupVC", bundle: nil) { (isOutOfPool, isOpenWater, isOutOfSync, isDontKnow) in
            self.isOutOfPool = isOutOfPool
            self.isOpenWater = isOpenWater
            self.isOutOfSync = isOutOfSync
            self.isDontKnow = isDontKnow
        }
        notAccurateVC.transitioningDelegate = self
        notAccurateVC.modalPresentationStyle = .custom
        self.present(notAccurateVC, animated: true)
    }
    
    //MARK: -
}
extension FeedbackSheetViewController: UITableViewDataSource, UITableViewDelegate, FeedbackAchievementTVCDelegates, DefaultFeedbackTVCDelegates{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1//achievements.count > 0 ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /*if achievements.count > 0{
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
         
         }else{*/
        let cell = tableView.dequeueReusableCell(withIdentifier: DefaultFeedbackTVC.identifier) as! DefaultFeedbackTVC
        cell.setupThumb(status: self.thumbStatus)
        cell.delegate = self
        cell.btnShare.isHidden = true
        //cell.btnShare.addTarget(self, action: #selector(self.shareAction(_:)), for: .touchUpInside)
        cell.selectionStyle = .none
        return cell
        //}
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        /*if achievements.count > 0{
         if indexPath.row == 0{
         return self.maxHeight
         }else{
         return cellHeight
         }
         }else{*/
        return cellHeight
        //}
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

extension FeedbackSheetViewController: UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == distanceUnitsPicker{
            return self.arrDistanceUnits.count
        }
        
        if pickerView == lapCountPicker{
            return self.arrLapCount.count
        }
        
        if pickerView == strokePicker{
            return 120
        }
        
        return self.arrPoolType.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == distanceUnitsPicker{
            return self.arrDistanceUnits[row].rawValue.firstUppercased
        }
        
        if pickerView == lapCountPicker{
            return "\(self.arrLapCount[row])"
        }
        
        if pickerView == strokePicker{
            return "\(row+1)"
        }
        
        return self.arrPoolType[row].rawValue.firstUppercased
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == txtPoolLength{
            let type = self.arrPoolType[poolLengthPicker.selectedRow(inComponent: 0)]
            if type == .custom{
                //Show Custom pool length popup
                
                let customPoolLength = CustomPoolLengthPopup(nibName: "CustomPoolLengthPopup", bundle: nil)
                customPoolLength.transitioningDelegate = self
                customPoolLength.modalPresentationStyle = .custom
                customPoolLength.onSave = { distance, poolUnit in
                    self.poolInfo.defaultPoolLength = type
                    self.poolInfo.customPoolDistance = distance
                    self.poolInfo.customPoolLengthUnits = poolUnit
                    if distance.remainder(dividingBy: 1) > 0{
                        self.txtPoolLength.text = "\(distance) \(poolUnit.rawValue.lowercased())"
                    }else{
                        self.txtPoolLength.text = "\(Int(distance)) \(poolUnit.rawValue.lowercased())"
                    }
                    
                    self.setupPoolInfo()
                }
                
                self.present(customPoolLength, animated: true, completion: nil)
            }else{
                self.poolInfo.defaultPoolLength = type
                self.txtPoolLength.text = type.rawValue.firstUppercased
                self.setupPoolInfo()
            }
        }else if textField == txtUnits{
            let unit = self.arrDistanceUnits[distanceUnitsPicker.selectedRow(inComponent: 0)]
            self.txtUnits.text = unit.rawValue.firstUppercased
            self.updateDistanceOnLabel()
        }else if textField == txtLapCount{
            let lap = self.arrLapCount[lapCountPicker.selectedRow(inComponent: 0)]
            self.txtLapCount.text = "\(lap)"
            if lap > 0{
                self.txtDistance.text = "\(lap)"
            }
            self.updateDistanceOnLabel()
        }else if textField == txtDistance{
            self.updateDistanceOnLabel()
        }else if textField == txtStroke{
            let selectedrow = strokePicker.selectedRow(inComponent: 0) + 1
            self.txtStroke.text = "\(selectedrow)"
        }
        
    }
}

extension FeedbackSheetViewController: UIViewControllerTransitioningDelegate{
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentingAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissingAnimator()
    }
    
}

extension FeedbackSheetViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.achievements.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeedbackAchievementCVC.identifier, for: indexPath) as! FeedbackAchievementCVC
        
        let item = self.achievements[indexPath.row]
        cell.lblTitle.text = item.name
        cell.lblDescription.text = item.message
        
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == collectionView{
            print("Scroll to next Achievement")
            if self.achievements.count > 1{
                let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
                let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
                let visibleIndexPath = collectionView.indexPathForItem(at: visiblePoint)
                self.pageControl.currentPage = visibleIndexPath?.row ?? 0
                self.didScrollAt(visibleIndexPath?.row ?? 0)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.itemSize
    }
}
