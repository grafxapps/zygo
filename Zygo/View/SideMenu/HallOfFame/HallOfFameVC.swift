//
//  HallOfFameVC.swift
//  Zygo
//
//  Created by Som Parkash on 24/11/23.
//  Copyright © 2023 Somparkash. All rights reserved.
//

import UIKit

//MARK: -
class HallOfFameVC: UIViewController {
    
    @IBOutlet weak var distanceClassesSwitch: UISwitch!
    @IBOutlet weak var timeSwitch: UISwitch!
    
    @IBOutlet weak var btnDistance: UIButton!
    @IBOutlet weak var btnClasses: UIButton!
    @IBOutlet weak var btnAllTime: UIButton!
    @IBOutlet weak var btnLast30Days: UIButton!
    
    @IBOutlet weak var tblData: UITableView!
    
    private let viewModel = HallOfFameViewModel()
    
    //MARK: -  UIViewcontroller LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.registerCustomCell()
        self.updateHallOfFameList()
    }
    
    //MARK: - Setups
    func updateHallOfFameList(){
        self.viewModel.getHallOfFame { isUpdated in
            self.tblData.reloadData()
        }
    }
    
    func setupUI(){
        distanceClassesSwitch.onTintColor = UIColor.appBlueColor()
        distanceClassesSwitch.tintColor = UIColor.appBlueColor()
        distanceClassesSwitch.subviews[0].subviews[0].backgroundColor = UIColor.appBlueColor()
        
        timeSwitch.onTintColor = UIColor.appBlueColor()
        timeSwitch.tintColor = UIColor.appBlueColor()
        timeSwitch.subviews[0].subviews[0].backgroundColor = UIColor.appBlueColor()
    }
    
    func registerCustomCell(){
        self.tblData.separatorStyle = .none
        self.tblData.register(UINib(nibName: HallOfFameTVC.identifier, bundle: nil), forCellReuseIdentifier: HallOfFameTVC.identifier)
    }
    
    //MARK: - UIButton Actions
    @IBAction func backAction(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func distanceClassesSwitchAction(_ sender: UISwitch){
        
        if sender.isOn{
            self.btnClasses.setTitleColor(UIColor.appBlueColor(), for: .normal)
            self.btnDistance.setTitleColor(UIColor.appTitleDarkColor(), for: .normal)
            self.viewModel.type = .classes
        }else{
            self.btnClasses.setTitleColor(UIColor.appTitleDarkColor(), for: .normal)
            self.btnDistance.setTitleColor(UIColor.appBlueColor(), for: .normal)
            self.viewModel.type = .distance
        }
        
        self.updateHallOfFameList()
    }
    
    @IBAction func timeSwitchAction(_ sender: UISwitch){
        if sender.isOn{
            self.btnLast30Days.setTitleColor(UIColor.appBlueColor(), for: .normal)
            self.btnAllTime.setTitleColor(UIColor.appTitleDarkColor(), for: .normal)
            self.viewModel.time = .month
        }else{
            self.btnLast30Days.setTitleColor(UIColor.appTitleDarkColor(), for: .normal)
            self.btnAllTime.setTitleColor(UIColor.appBlueColor(), for: .normal)
            self.viewModel.time = .all
        }
        self.updateHallOfFameList()
    }
    
    //MARK: -
}

//MARK: - UITableView Delegates and Datasources
extension HallOfFameVC: UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.arrHallOfFame.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HallOfFameTVC.identifier) as! HallOfFameTVC
        cell.selectionStyle = .none
        let fameItem = self.viewModel.arrHallOfFame[indexPath.row]
        cell.loadData(fameItem, type: self.viewModel.type, time: self.viewModel.time)
        cell.lblNumber.text = "#\(indexPath.row + 1)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
}
