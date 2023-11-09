//
//  MatricsViewController.swift
//  Zygo
//
//  Created by Som on 05/03/22.
//  Copyright © 2022 Somparkash. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Charts

//MARK: -
class MetricsViewController: UIViewController {
    
    var itemInfo = IndicatorInfo(title: "METRICS")
    var superObj: ProfileViewController!
    
    @IBOutlet weak var chartCollectionView : UICollectionView!
    @IBOutlet weak var gridContentView : UIView!
    
    @IBOutlet weak var chartLoadingView : UIView!
    
    @IBOutlet weak var changeMonthContentView : UIView!
    
    @IBOutlet weak var modeSwitch : UISwitch!
    @IBOutlet weak var dailyMonthlySwitch : UISwitch!
    
    @IBOutlet weak var lblLeft1 : UILabel!
    @IBOutlet weak var lblLeft2 : UILabel!
    @IBOutlet weak var lblLeft3 : UILabel!
    @IBOutlet weak var lblLeft4 : UILabel!
    @IBOutlet weak var lblLeft5 : UILabel!
    @IBOutlet weak var lblLeft6 : UILabel!
    @IBOutlet weak var lblLeft7 : UILabel!
    @IBOutlet weak var lblLeft8 : UILabel!
    @IBOutlet weak var lblLeft9 : UILabel!
    @IBOutlet weak var lblLeft10 : UILabel!
    
    @IBOutlet weak var btnNextMonth : UIButton!
    @IBOutlet weak var btnPreviousMonth : UIButton!
    
    @IBOutlet weak var lblTotalTitle : UILabel!
    @IBOutlet weak var lblTotalValue : UILabel!
    
    @IBOutlet weak var lblUnit : UILabel!
    @IBOutlet weak var lblTime : UILabel!
    @IBOutlet weak var lblDistance : UILabel!
    @IBOutlet weak var lblDaily : UILabel!
    @IBOutlet weak var lblMonthly : UILabel!
    
    @IBOutlet weak var lblCurrentGraphMonth : UILabel!
    
    @IBOutlet weak var chartView : UIView!
    
    var dataEntries: [MarticData] = []
    var maxEntry: Double = 0
    var cellSize = CGSize.zero
    var graphDate: Date = DateHelper.shared.currentLocalDateTime
    var isDistanceMode = false
    var isAllMode = false
    private let viewModel = MetricViewModel()
    
    var distanceUnit: UnitLength = .yards
    
    //MARK: - UIViewcontroller LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateSwitchBG()
        self.registerCustomCells()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateSwitchBG()
        
        //self.superObj.hideChooseImage()
        self.getCurrentGraphData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.updateSwitchBG()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateSwitchBG()
    }
    
    //MARK: - Setups
    func updateSwitchBG(){
        modeSwitch.onTintColor = UIColor.appBlueColor()
        modeSwitch.tintColor = UIColor.appBlueColor()
        modeSwitch.subviews[0].subviews[0].backgroundColor = UIColor.appBlueColor()
        
        dailyMonthlySwitch.onTintColor = UIColor.appBlueColor()
        dailyMonthlySwitch.tintColor = UIColor.appBlueColor()
        dailyMonthlySwitch.subviews[0].subviews[0].backgroundColor = UIColor.appBlueColor()
    }
    
    func showChartLoadingView(){
        self.chartLoadingView.alpha = 0.0
        self.chartLoadingView.isHidden = false
        UIView.animate(withDuration: 0.2) {
            self.chartLoadingView.alpha = 1.0
        }
    }
    
    func hideChartLoadingView(){
        
        self.dailyMonthlySwitch.isUserInteractionEnabled = true
        
        UIView.animate(withDuration: 0.4) {
            self.chartLoadingView.alpha = 0.0
        } completion: { (complete) in
            self.chartLoadingView.isHidden = true
        }
    }
    
    func getCurrentGraphData(){
        let cDate = DateHelper.shared.currentLocalDateTime
        self.getGraphData(date: cDate)
        
    }
    
    func getGraphData(date: Date){
        
        self.showChartLoadingView()
        
        if self.isAllMode{
            
            self.viewModel.getYearlyGraphData(){ (arrAllMonthData) in
                
                let monthCount = arrAllMonthData.count
                
                self.dataEntries.removeAll(keepingCapacity: true)
                let unitInfo = PreferenceManager.shared.poolUnitInfo.unitPref
                if unitInfo == .metric{
                    self.distanceUnit = .kilometers
                }else{
                    self.distanceUnit = .miles
                }
                
                for index in 0..<monthCount{
                    
                    let item = arrAllMonthData[index]
                    var value: Double = 0
                    if self.isDistanceMode{
                        value = Helper.shared.distanceConvert(to: self.distanceUnit, from: .yards, distance: item.distance)
                    }else{
                        value = item.duration
                    }
                    
                    if item.isShowYear{
                        self.dataEntries.append(MarticData(value: value, title: "\(item.month)\n\(item.year)"))
                    }else{
                        self.dataEntries.append(MarticData(value: value, title: "\(item.month)"))
                    }
                }
                
                self.updateChartData()
                
            }
        }else{
            self.graphDate = date
            self.lblCurrentGraphMonth.text = date.convertToFormat("MMM yyy")
            let month = Int(date.toFormat(format: "MM")) ?? 0
            let year = Int(date.toFormat(format: "yyyy")) ?? 0
            
            let cDate = DateHelper.shared.currentLocalDateTime
            let cmonth = Int(cDate.toFormat(format: "MM")) ?? 0
            let cyear = Int(cDate.toFormat(format: "yyyy")) ?? 0
            if month == cmonth && year == cyear{
                self.btnNextMonth.isUserInteractionEnabled = false
                self.btnNextMonth.alpha = 0.5
            }else{
                self.btnNextMonth.isUserInteractionEnabled = true
                self.btnNextMonth.alpha = 1.0
            }
            
            self.viewModel.getGraphData(withDate: date) { (arrMonthData) in
                
                let daysCount = arrMonthData.count
                
                self.dataEntries.removeAll(keepingCapacity: true)
                
                let arrAllDistance = arrMonthData.map({ $0.distance })
                let maxDistance = (arrAllDistance.max() ?? 0)
                let unitInfo = PreferenceManager.shared.poolUnitInfo.unitPref
                if unitInfo == .metric{
                    let maxDistanceMeters = Helper.shared.distanceConvert(to: .meters, from: .yards, distance: maxDistance)
                    if maxDistanceMeters < 1000{
                        self.distanceUnit = .meters
                    }else{
                        self.distanceUnit = .kilometers
                    }
                }else{
                    if maxDistance > 2000{
                        self.distanceUnit = .miles
                    }else{
                        self.distanceUnit = .yards
                    }
                }
                
                var dataIndex: Int = 0
                for index in 1...daysCount{
                    
                    let item = arrMonthData[dataIndex]
                    var value: Double = 0
                    if self.isDistanceMode{
                        value = Helper.shared.distanceConvert(to: self.distanceUnit, from: .yards, distance: item.distance)
                    }else{
                        value = item.duration
                    }
                    
                    if index == 1{
                        self.dataEntries.append(MarticData(value: value, title: "1"))
                    }else if daysCount == 28{
                        if index == 28{
                            self.dataEntries.append(MarticData(value: value, title: "28"))
                        }else{
                            if index%5 == 0 && index != 0{
                                self.dataEntries.append(MarticData(value: value, title: "\(index)"))
                            }else{
                                self.dataEntries.append(MarticData(value: value, title: ""))
                            }
                        }
                    }else if daysCount == 29{
                        if index == 29{
                            self.dataEntries.append(MarticData(value: value, title: "29"))
                        }else{
                            if index%5 == 0 && index != 0{
                                self.dataEntries.append(MarticData(value: value, title: "\(index)"))
                            }else{
                                self.dataEntries.append(MarticData(value: value, title: ""))
                            }
                        }
                    }else if daysCount == 30{
                        if index%5 == 0 && index != 0{
                            self.dataEntries.append(MarticData(value: value, title: "\(index)"))
                        }else{
                            self.dataEntries.append(MarticData(value: value, title: ""))
                        }
                    }else if daysCount == 31{
                        if index == 30{
                            self.dataEntries.append(MarticData(value: value, title: ""))
                        }else if index == 31{
                            self.dataEntries.append(MarticData(value: value, title: "31"))
                        }else{
                            if index%5 == 0 && index != 0{
                                self.dataEntries.append(MarticData(value: value, title: "\(index)"))
                            }else{
                                self.dataEntries.append(MarticData(value: value, title: ""))
                            }
                        }
                    }
                    
                    dataIndex += 1
                }
                
                self.updateChartData()
                
            }
        }
    }
    
    func updateChartData(){
        let arrDataValue = self.dataEntries.map({ $0.value })
        if self.isDistanceMode{
            self.maxEntry = (arrDataValue.max() ?? 0)
         }else{
            self.maxEntry = (arrDataValue.max() ?? 0)
         }
        
        //self.maxEntry = (arrDataValue.max() ?? 0) + 20
        
        let graphHeight: CGFloat = 250.0 /*ScreenSize.SCREEN_HEIGHT - (50 + UIApplication.statuBarFrame().height + 197.5 + UIApplication.BottomSpace() + 80.0)*/
        var width = (ScreenSize.SCREEN_WIDTH - 55.0)/CGFloat(self.dataEntries.count)
        if self.isAllMode{
            width = (ScreenSize.SCREEN_WIDTH - 55.0)/CGFloat(12.0)
        }
        
        cellSize = CGSize(width: width, height: graphHeight)
        
        self.setupGridView()
        //self.setupGridViewData()
        self.chartCollectionView.setContentOffset(.zero, animated: false)
        self.chartCollectionView.reloadData()
        
        if isAllMode{
            if self.dataEntries.count > 0{
                self.chartCollectionView.scrollToItem(at: IndexPath.init(row: self.dataEntries.count - 1, section: 0), at: .right, animated: false)
            }
        }
        
        let totalValue = arrDataValue.reduce(0,+)
        if self.isDistanceMode{
            //let distance = Helper.shared.distanceConvert(to: .miles, from: .yards, distance: totalValue)
            self.lblTotalTitle.text = "Total Distance:"
            if self.distanceUnit == .meters{
                self.lblTotalValue.text = String(format: "%.1f m", totalValue)
            }else if self.distanceUnit == .kilometers{
                self.lblTotalValue.text = String(format: "%.1f km", totalValue)
            }else if self.distanceUnit == .miles{
                self.lblTotalValue.text = String(format: "%.1f mi", totalValue)
            }else if self.distanceUnit == .yards{
                self.lblTotalValue.text = String(format: "%.1f yd", totalValue)
            }
            
        }else{
            
            let hours = (totalValue/60)/60
            self.lblTotalTitle.text = "Total Hours in Water:"
            self.lblTotalValue.text = String(format: "%.1f hours", hours)
        }
        
        self.hideChartLoadingView()
    }
    
    func registerCustomCells(){
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.scrollDirection = .horizontal
        chartCollectionView.collectionViewLayout = layout
        
        chartCollectionView.showsVerticalScrollIndicator = false
        chartCollectionView.showsHorizontalScrollIndicator = false
        
        chartCollectionView.register(UINib(nibName: BarCVC.identifier, bundle: nil), forCellWithReuseIdentifier: BarCVC.identifier)
        
    }
    
    func setupGridViewData(){
        let val = self.maxEntry/10.0
        if self.isDistanceMode{
            if self.maxEntry >= 10{
                self.lblLeft1.text = String(format: "%.1f",val)
                self.lblLeft2.text = String(format: "%.1f",Double(val * 2.0))
                self.lblLeft3.text = String(format: "%.1f",Double(val * 3.0))
                self.lblLeft4.text = String(format: "%.1f",Double(val * 4.0))
                self.lblLeft5.text = String(format: "%.1f",Double(val * 5.0))
                self.lblLeft6.text = String(format: "%.1f",Double(val * 6.0))
                self.lblLeft7.text = String(format: "%.1f",Double(val * 7.0))
                self.lblLeft8.text = String(format: "%.1f",Double(val * 8.0))
                self.lblLeft9.text = String(format: "%.1f",Double(val * 9.0))
                self.lblLeft10.text = String(format: "%.1f",Double(val * 10.0))
            }else if self.maxEntry <= 1{
                self.lblLeft1.text = "\(val.toHMIfPossible())"
                self.lblLeft2.text = ""
                self.lblLeft3.text = ""
                self.lblLeft4.text = String(format: "%.1f",Double(val * 4.0))
                self.lblLeft5.text = ""
                self.lblLeft6.text = ""
                self.lblLeft7.text = String(format: "%.1f",Double(val * 7.0))
                self.lblLeft8.text = ""
                self.lblLeft9.text = ""
                self.lblLeft10.text = String(format: "%.1f",Double(val * 10.0))
            }else{
                self.lblLeft1.text = String(format: "%.1f",val)
                self.lblLeft2.text = ""
                self.lblLeft3.text = ""
                self.lblLeft4.text = ""
                self.lblLeft5.text = String(format: "%.1f",Double(val * 5.0))
                self.lblLeft6.text = ""
                self.lblLeft7.text = ""
                self.lblLeft8.text = ""
                self.lblLeft9.text = ""
                self.lblLeft10.text = String(format: "%.1f",Double(val * 10.0))
            }
            
        }else{
            
            if self.maxEntry >= 10{
                self.lblLeft1.text = "\(val.toHMIfPossible())"
                self.lblLeft2.text = "\(Double(val * 2.0).toHMIfPossible())"
                self.lblLeft3.text = "\(Double(val * 3.0).toHMIfPossible())"
                self.lblLeft4.text = "\(Double(val * 4.0).toHMIfPossible())"
                self.lblLeft5.text = "\(Double(val * 5.0).toHMIfPossible())"
                self.lblLeft6.text = "\(Double(val * 6.0).toHMIfPossible())"
                self.lblLeft7.text = "\(Double(val * 7.0).toHMIfPossible())"
                self.lblLeft8.text = "\(Double(val * 8.0).toHMIfPossible())"
                self.lblLeft9.text = "\(Double(val * 9.0).toHMIfPossible())"
                self.lblLeft10.text = "\(Double(val * 10.0).toHMIfPossible())"
            }else if self.maxEntry <= 1{
                self.lblLeft1.text = "\(val.toHMIfPossible())"
                self.lblLeft2.text = ""
                self.lblLeft3.text = ""
                self.lblLeft4.text = "\(Double(val * 4.0).toHMIfPossible())"
                self.lblLeft5.text = ""
                self.lblLeft6.text = ""
                self.lblLeft7.text = "\(Double(val * 7.0).toHMIfPossible())"
                self.lblLeft8.text = ""
                self.lblLeft9.text = ""
                self.lblLeft10.text = "\(Double(val * 10.0).toHMIfPossible())"
            }else{
                self.lblLeft1.text = "\(val.toHMIfPossible())"
                self.lblLeft2.text = ""
                self.lblLeft3.text = ""
                self.lblLeft4.text = ""
                self.lblLeft5.text = "\(Double(val * 5.0).toHMIfPossible())"
                self.lblLeft6.text = ""
                self.lblLeft7.text = ""
                self.lblLeft8.text = ""
                self.lblLeft9.text = ""
                self.lblLeft10.text = "\(Double(val * 10.0).toHMIfPossible())"
            }
            
        }
        
    }
    
    func setupGridView(){
        
        let arrSubViews = gridContentView.subviews
        for sview in arrSubViews{
            sview.removeFromSuperview()
        }
        
        let totalHeight: CGFloat = cellSize.height - 38.0
        var __y: CGFloat = 0.0
        let __x: CGFloat = 40.0
        let __width: CGFloat = ScreenSize.SCREEN_WIDTH - 45.0
        
        var unitTitle: String = "m"
        var maxLines: Int = 0
        
        var maxValueForGrid = self.maxEntry
        //Setup horizontal lines
        var horizontalValues: [Int] = []
        if !self.isAllMode{
            if !self.isDistanceMode{//In this case lines should be according to minutes only with three lines
                maxLines = 3
                
                
                let remainder = (ceil(self.maxEntry / 60.0)).truncatingRemainder(dividingBy: 60.0)
                if remainder != 0{
                    self.maxEntry += (60.0 - remainder) * 60.0
                }
                
                let minimumSeconds = 60.0 * 60.0
                if maxEntry < minimumSeconds{
                    self.maxEntry = minimumSeconds
                }
                
                maxValueForGrid = ceil(self.maxEntry / 60.0)
                
                let valPerLine = maxValueForGrid/Double(maxLines)
                for index in 0...maxLines{
                    horizontalValues.append(Int(ceil(valPerLine * Double(index))))
                }
                
                unitTitle = "min"
                
                var graphMaxValue = Double(horizontalValues.max() ?? 0)
                graphMaxValue = graphMaxValue * 60
                if self.maxEntry < graphMaxValue{
                    self.maxEntry = graphMaxValue
                }
                
            }else{//Distance Mode
                
                //Convert yards to meter
                maxValueForGrid = self.maxEntry
                if self.distanceUnit == .meters{
                    if maxValueForGrid <= 1000{
                        self.maxEntry = 1000
                        maxValueForGrid = 1000
                        maxLines = 5
                    }
                    
                    let valPerLine = maxValueForGrid/Double(maxLines)
                    for index in 0...maxLines{
                        horizontalValues.append(Int(ceil(valPerLine * Double(index))))
                    }
                    self.lblUnit.text = "m"
                }else if self.distanceUnit == .kilometers{
                    if maxValueForGrid < 1{
                        self.maxEntry = 1
                        maxValueForGrid = 1
                    }
                    
                    maxValueForGrid = ceil(maxValueForGrid)
                    maxLines = Int(maxValueForGrid)
                    
                    if maxLines > 10{
                        maxValueForGrid = Double(self.roundMaxValue(maxValue: maxLines))
                        maxLines = 10
                    }
                    
                    let valPerLine = maxValueForGrid/Double(maxLines)
                    for index in 0...maxLines{
                        horizontalValues.append(Int(ceil(valPerLine * Double(index))))
                    }
                    
                    unitTitle = "km"
                }else if self.distanceUnit == .yards{
                    if maxValueForGrid <= 2000{
                        self.maxEntry = 2000
                        maxValueForGrid = 2000
                        maxLines = 4
                    }
                    
                    let valPerLine = maxValueForGrid/Double(maxLines)
                    for index in 0...maxLines{
                        horizontalValues.append(Int(ceil(valPerLine * Double(index))))
                    }
                    
                    unitTitle = "yd"
                }else if self.distanceUnit == .miles{
                    if maxValueForGrid < 1{
                        self.maxEntry = 1
                        maxValueForGrid = 1
                    }
                    
                    maxValueForGrid = ceil(maxValueForGrid)
                    maxLines = Int(maxValueForGrid)
                    
                    if maxLines > 10{
                        maxValueForGrid = Double(self.roundMaxValue(maxValue: maxLines))
                        maxLines = 10
                    }
                    
                    let valPerLine = maxValueForGrid/Double(maxLines)
                    for index in 0...maxLines{
                        horizontalValues.append(Int(ceil(valPerLine * Double(index))))
                    }
                    
                    unitTitle = "mi"
                }
                
                let graphMaxValue = Double(horizontalValues.max() ?? 0)
                if self.maxEntry < graphMaxValue{
                    self.maxEntry = graphMaxValue
                }
            }
        }else{
            if !self.isDistanceMode{//In this case lines should be according to hours only with three lines
                
                //Convert seconds to hours
                maxValueForGrid = self.maxEntry/3600.0
                if maxValueForGrid < 1{
                    self.maxEntry = 3600
                    maxValueForGrid = 1
                }
                maxValueForGrid = ceil(maxValueForGrid)
                maxLines = Int(maxValueForGrid)
                
                if maxLines > 10{
                    maxValueForGrid = Double(self.roundMaxValue(maxValue: maxLines))
                    maxLines = 10
                }
                
                let valPerLine = maxValueForGrid/Double(maxLines)
                for index in 0...maxLines{
                    horizontalValues.append(Int(ceil(valPerLine * Double(index))))
                }
                
                unitTitle = "hr"
                
                var graphMaxValue = Double(horizontalValues.max() ?? 0)
                graphMaxValue = graphMaxValue * 60 * 60
                if self.maxEntry < graphMaxValue{
                    self.maxEntry = graphMaxValue
                }
                
            }else{//Distance Mode
                
                //Convert yards to meter
                maxValueForGrid = self.maxEntry
                if self.distanceUnit == .kilometers{
                    if maxValueForGrid < 1{
                        self.maxEntry = 1
                        maxValueForGrid = 1
                    }
                    
                    maxValueForGrid = ceil(maxValueForGrid)
                    maxLines = Int(maxValueForGrid)
                    
                    if maxLines > 10{
                        maxValueForGrid = Double(self.roundMaxValue(maxValue: maxLines))
                        maxLines = 10
                        
                        
                    }
                    
                    let valPerLine = maxValueForGrid/Double(maxLines)
                    for index in 0...maxLines{
                        horizontalValues.append(Int(ceil(valPerLine * Double(index))))
                    }
                    
                    unitTitle = "km"
                }else if self.distanceUnit == .miles{
                    if maxValueForGrid < 1{
                        self.maxEntry = 1
                        maxValueForGrid = 1
                    }
                    
                    maxValueForGrid = ceil(maxValueForGrid)
                    maxLines = Int(maxValueForGrid)
                    
                    if maxLines > 10{
                        maxValueForGrid = Double(self.roundMaxValue(maxValue: maxLines))
                        maxLines = 10
                    }
                    
                    let valPerLine = maxValueForGrid/Double(maxLines)
                    for index in 0...maxLines{
                        horizontalValues.append(Int(ceil(valPerLine * Double(index))))
                    }
                    
                    unitTitle = "mi"
                }
                
                let graphMaxValue = Double(horizontalValues.max() ?? 0)
                if self.maxEntry < graphMaxValue{
                    self.maxEntry = graphMaxValue
                }
            }
        }
        
        let strAtt = NSAttributedString(string: unitTitle, attributes: [NSAttributedString.Key.underlineStyle : NSUnderlineStyle.thick.rawValue])
        self.lblUnit.attributedText = strAtt
        
        var index: Int = 0
        for val in horizontalValues{
            
            __y = totalHeight - (CGFloat(val) * (totalHeight/CGFloat(maxValueForGrid)))
            
            let lineView = UIView(frame: CGRect(x: __x, y: __y, width: __width, height: 1.0))
            lineView.backgroundColor = UIColor.init(red: 112.0/255.0, green: 112.0/255.0, blue: 112.0/255.0, alpha: 0.1)
            //chartView.addSubview(lineView)
            gridContentView.addSubview(lineView)
            
            let lblVal = UILabel(frame: CGRect(x: 0.0, y: __y - 6.0, width: 30.0, height: 12.0))
            lblVal.font = UIFont.appMedium(with: 12.0)
            lblVal.textAlignment = .right
            lblVal.textColor = UIColor.lightGray
            lblVal.text = ""
            
            if val > 0{
                lblVal.text = String(format: "%d", val)
            }
            
            if !self.isAllMode{
                if self.isDistanceMode{
                    if self.distanceUnit == .yards{
                        let mVal = Double(val)/1000.0
                        if mVal > 0{
                            lblVal.text = String(format: "%.1fk", mVal)
                        }
                        
                    }
                }
            }
            
            
            gridContentView.addSubview(lblVal)
            
            index += 1
        }
        
    }
    
    //MARK: - UIButton Actions
    @IBAction func nextMonthAction(_ sender: UIButton){
        
        if let date = Calendar.current.date(byAdding: .month, value: 1, to: self.graphDate){
            self.getGraphData(date: date)
        }
        
    }
    
    @IBAction func previousMonthAction(_ sender: UIButton){
        if let date = Calendar.current.date(byAdding: .month, value: -1, to: self.graphDate){
            self.getGraphData(date: date)
        }
    }
    
    @IBAction func dailyMonthlyModeAction(_ sender: UISwitch){
        if sender.isOn{
            self.allAction()
        }else{
            self.monthAction()
        }
    }
    
    @IBAction func monthAction(){
        if !self.isAllMode{
            return
        }
        
        self.dailyMonthlySwitch.isOn = false
        
        self.dailyMonthlySwitch.isUserInteractionEnabled = false
        self.lblMonthly.textColor = UIColor.appTitleDarkColor()
        self.lblDaily.textColor = UIColor.appBlueColor()
        
        self.changeMonthContentView.isHidden = false
        self.isAllMode = false
        self.getGraphData(date: self.graphDate)
    }
    
    @IBAction func allAction(){
        if self.isAllMode{
            return
        }
        
        self.dailyMonthlySwitch.isOn = true
        
        self.dailyMonthlySwitch.isUserInteractionEnabled = false
        self.lblMonthly.textColor = UIColor.appBlueColor()
        self.lblDaily.textColor = UIColor.appTitleDarkColor()
        
        self.changeMonthContentView.isHidden = true
        self.isAllMode = true
        self.getGraphData(date: self.graphDate)
    }
    
    @IBAction func switchModeAction(_ sender: UISwitch){
        if sender.isOn{
            self.timeAction()
        }else{
            self.distanceAction()
        }
    }
    
    @IBAction func timeAction(){
        
        if !self.isDistanceMode{
            return
        }
        
        self.modeSwitch.isOn = true
        self.isDistanceMode = false
        self.lblTime.textColor = UIColor.appBlueColor()
        self.lblDistance.textColor = UIColor.appTitleDarkColor()
        self.getGraphData(date: self.graphDate)
    }
    
    @IBAction func distanceAction(){
        if self.isDistanceMode{
            return
        }
        
        self.modeSwitch.isOn = false
        self.isDistanceMode = true
        self.lblTime.textColor = UIColor.appTitleDarkColor()
        self.lblDistance.textColor = UIColor.appBlueColor()
        self.getGraphData(date: self.graphDate)
    }
    
    func roundMaxValue(maxValue: Int) -> Int{
        var maxValueForGrid = maxValue
        let maxValueCount = "\(maxValue)".count
        
        var strDivideValue = "1"
        if maxValueCount == 1 || maxValueCount == 2{
            strDivideValue = "10"
        }else{
            for _ in 1...(maxValueCount-1){
                strDivideValue += "0"
            }
        }
        
        
        
        var divideValue = Int(strDivideValue) ?? 10
        if divideValue < 10{
            divideValue = 10
        }
        let remainder = maxValue % divideValue
        if  remainder != 0{
            maxValueForGrid += (divideValue - remainder)
        }
        
        return maxValueForGrid
    }
    
    //MARK: -
}


//MARK: - UICollectionView Datasources and Delegates
extension MetricsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataEntries.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BarCVC.identifier, for: indexPath) as! BarCVC
        
        cell.setupBar(at: self.dataEntries[indexPath.row].value, max: self.maxEntry, barFullHeight: Double(cellSize.height - 38.0))
        if self.isAllMode{
            cell.lblBottom.numberOfLines = 2
        }else{
            cell.lblBottom.numberOfLines = 1
        }
        cell.lblBottom.contentMode = .top
        cell.lblBottom.text = self.dataEntries[indexPath.row].title
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
    
}

extension MetricsViewController : IndicatorInfoProvider{
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}

struct MarticData{
    var value: Double = 0
    var title: String = ""
    
}
