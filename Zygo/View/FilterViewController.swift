//
//  FilterViewController.swift
//  Zygo
//
//  Created by Priya Gandhi on 24/01/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController {
    
    @IBOutlet weak var tblFilter : UITableView!
    @IBOutlet weak var btnShowClasses : UIButton!
    
    @IBOutlet weak var btnAll : UIButton!
    @IBOutlet weak var btnNotTaken : UIButton!
    @IBOutlet weak var btnTaken : UIButton!
    
    private let viewModel = FilterViewModel()
    
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerTVC()
        
        if self.viewModel.arrSelectedFiltes.count > 0 || PreferenceManager.shared.isNotTakenByMe || PreferenceManager.shared.isTakenByMe{
            self.viewModel.getFilteredWorkouts { [weak self] in
                self?.updateShowButton()
            }
        }else{
            self.updateShowButton()
        }
        
        if PreferenceManager.shared.isTakenByMe{
            self.selectTaken()
        }else if PreferenceManager.shared.isNotTakenByMe{
            self.selectNotTaken()
        }else{
            self.selectAll()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getFilters { [weak self] in
            self?.tblFilter.reloadData()
        }
    }
    
    //MARK: - Setup
    func selectAll(){
        btnAll.layer.cornerRadius = 10.0
        btnAll.layer.masksToBounds = true
        btnAll.layer.borderWidth = 0
        
        btnAll.setTitleColor(.white, for: .normal)
        btnAll.backgroundColor = UIColor.appBlueColor()
        btnAll.titleLabel?.font = UIFont.appBold(with: 14.0)
        
        btnNotTaken.layer.cornerRadius = 10.0
        btnNotTaken.layer.masksToBounds = true
        btnNotTaken.layer.borderWidth = 1
        btnNotTaken.layer.borderColor = UIColor.appTitleDarkColor().cgColor
        
        btnNotTaken.setTitleColor(UIColor.appTitleDarkColor(), for: .normal)
        btnNotTaken.backgroundColor = UIColor.white
        btnNotTaken.titleLabel?.font = UIFont.appRegular(with: 14.0)
        
        btnTaken.layer.cornerRadius = 10.0
        btnTaken.layer.masksToBounds = true
        btnTaken.layer.borderWidth = 1
        btnTaken.layer.borderColor = UIColor.appTitleDarkColor().cgColor
        
        btnTaken.setTitleColor(UIColor.appTitleDarkColor(), for: .normal)
        btnTaken.backgroundColor = UIColor.white
        btnTaken.titleLabel?.font = UIFont.appRegular(with: 14.0)
        
        PreferenceManager.shared.isTakenByMe = false
        PreferenceManager.shared.isNotTakenByMe = false
    }
    
    func selectNotTaken(){
        
        btnNotTaken.layer.cornerRadius = 10.0
        btnNotTaken.layer.masksToBounds = true
        btnNotTaken.layer.borderWidth = 0
        
        btnNotTaken.setTitleColor(.white, for: .normal)
        btnNotTaken.backgroundColor = UIColor.appBlueColor()
        btnNotTaken.titleLabel?.font = UIFont.appBold(with: 14.0)
        
        btnAll.layer.cornerRadius = 10.0
        btnAll.layer.masksToBounds = true
        btnAll.layer.borderWidth = 1
        btnAll.layer.borderColor = UIColor.appTitleDarkColor().cgColor
        
        btnAll.setTitleColor(UIColor.appTitleDarkColor(), for: .normal)
        btnAll.backgroundColor = UIColor.white
        btnAll.titleLabel?.font = UIFont.appRegular(with: 14.0)
        
        
        btnTaken.layer.cornerRadius = 10.0
        btnTaken.layer.masksToBounds = true
        btnTaken.layer.borderWidth = 1
        btnTaken.layer.borderColor = UIColor.appTitleDarkColor().cgColor
        
        btnTaken.setTitleColor(UIColor.appTitleDarkColor(), for: .normal)
        btnTaken.backgroundColor = UIColor.white
        btnTaken.titleLabel?.font = UIFont.appRegular(with: 14.0)
        
        PreferenceManager.shared.isTakenByMe = false
        PreferenceManager.shared.isNotTakenByMe = true
    }
    
    func selectTaken(){
        
        btnTaken.layer.cornerRadius = 10.0
        btnTaken.layer.masksToBounds = true
        btnTaken.layer.borderWidth = 0
        
        btnTaken.setTitleColor(.white, for: .normal)
        btnTaken.backgroundColor = UIColor.appBlueColor()
        btnTaken.titleLabel?.font = UIFont.appBold(with: 14.0)
        
        
        btnAll.layer.cornerRadius = 10.0
        btnAll.layer.masksToBounds = true
        btnAll.layer.borderWidth = 1
        btnAll.layer.borderColor = UIColor.appTitleDarkColor().cgColor
        
        btnAll.setTitleColor(UIColor.appTitleDarkColor(), for: .normal)
        btnAll.backgroundColor = UIColor.white
        btnAll.titleLabel?.font = UIFont.appRegular(with: 14.0)
        
        
        btnNotTaken.layer.cornerRadius = 10.0
        btnNotTaken.layer.masksToBounds = true
        btnNotTaken.layer.borderWidth = 1
        btnNotTaken.layer.borderColor = UIColor.appTitleDarkColor().cgColor
        
        btnNotTaken.setTitleColor(UIColor.appTitleDarkColor(), for: .normal)
        btnNotTaken.backgroundColor = UIColor.white
        btnNotTaken.titleLabel?.font = UIFont.appRegular(with: 14.0)
        
        PreferenceManager.shared.isTakenByMe = true
        PreferenceManager.shared.isNotTakenByMe = false
    }
    
    func registerTVC()  {
        tblFilter.separatorStyle = .none
        tblFilter.register(UINib.init(nibName: FilterTVC.identifier, bundle: nil), forCellReuseIdentifier: FilterTVC.identifier);
        
    }
    
    func updateShowButton(){
        
        if self.viewModel.arrSelectedFiltes.count > 0 || PreferenceManager.shared.isNotTakenByMe || PreferenceManager.shared.isTakenByMe{
            let count = self.viewModel.arrWorkouts.count
            if count == 0{
                self.btnShowClasses.setTitle("NO CLASSES FOUND", for: .normal)
                self.btnShowClasses.isUserInteractionEnabled = false
                self.btnShowClasses.alpha = 0.5
            }else if count == 1{
                self.btnShowClasses.setTitle("SHOW \(count) CLASS", for: .normal)
                self.btnShowClasses.isUserInteractionEnabled = true
                self.btnShowClasses.alpha = 1.0
            }else{
                self.btnShowClasses.setTitle("SHOW \(count) CLASSES", for: .normal)
                self.btnShowClasses.isUserInteractionEnabled = true
                self.btnShowClasses.alpha = 1.0
            }
        }else{
            self.btnShowClasses.setTitle("SHOW ALL CLASSES", for: .normal)
            self.btnShowClasses.isUserInteractionEnabled = true
            self.btnShowClasses.alpha = 1.0
        }
        
    }
    
    //MARK: - UIButtons Action
    @IBAction func homeAction(_ sender: UIButton){
        sideMenuController?.revealMenu()
    }
    
    @IBAction func backAction(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clearAllAction(_ sender: UIButton){
        PreferenceManager.shared.selectedFilters = []
        PreferenceManager.shared.isNotTakenByMe = false
        PreferenceManager.shared.isTakenByMe = false
        self.selectAll()
        self.viewModel.arrSelectedFiltes.removeAll()
        self.viewModel.arrWorkouts.removeAll()
        self.updateShowButton()
        self.tblFilter.reloadData()
    }
    
    @IBAction func showClassesAction(_ sender: UIButton){
        let count = self.viewModel.arrWorkouts.count
        if count > 0{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WorkoutsViewController") as! WorkoutsViewController
            vc.isFromFilter = true
            Helper.shared.topNavigationController()?.pushViewController(vc, animated: true)
        }
        //NotificationCenter.default.post(name: .fetchWorkouts, object: nil)
        //Helper.shared.moveToTab(index: 0)
        //self.navigationController?.popViewController(animated: true)
        
        
    }
    
    @IBAction func allAction(_ sender: UIButton){
        self.selectAll()
        self.viewModel.getFilteredWorkouts { [weak self] in
            self?.updateShowButton()
        }
    }
    
    @IBAction func notTakenAction(_ sender: UIButton){
        self.selectNotTaken()
        self.viewModel.getFilteredWorkouts { [weak self] in
            self?.updateShowButton()
        }
    }
    
    @IBAction func takenAction(_ sender: UIButton){
        self.selectTaken()
        self.viewModel.getFilteredWorkouts { [weak self] in
            self?.updateShowButton()
        }
    }
}

extension FilterViewController : UITableViewDataSource, UITableViewDelegate, BottomSheetVCDelegates{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.arrFiltes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : FilterTVC = tableView.dequeueReusableCell(withIdentifier: FilterTVC.identifier) as! FilterTVC
        let fItem = self.viewModel.arrFiltes[indexPath.row]
        cell.lblTitle.alpha = 0.8
        
        cell.lblTitle.textColor = UIColor.appTitleDarkColor()
        cell.lblTitle.font = UIFont.appMedium(with: 18.0)
        if self.viewModel.arrSelectedFiltes.contains(where: { $0.title.lowercased() == fItem.title.lowercased() }){
            cell.lblTitle.alpha = 1.0
            cell.lblTitle.textColor = .black
            cell.lblTitle.font = UIFont.appMedium(with: 20.0)
        }
        
        cell.lblTitle.text = fItem.title
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let sheetVC = BottomSheetVC(nibName: "BottomSheetVC", bundle: nil)
        let fItem = self.viewModel.arrFiltes[indexPath.row]
        
        var arrFilters = fItem.filters
        if fItem.title.lowercased() == "equipment"{
            var noEquipmentItem = FilterDTO([:])
            noEquipmentItem.fId = 0
            noEquipmentItem.fTitle = "No Equipment"
            arrFilters.append(noEquipmentItem)
        }
        
        sheetVC.mTitle = fItem.title
        sheetVC.list = arrFilters
        sheetVC.icon = fItem.icon
        if let selectedItems = self.viewModel.arrSelectedFiltes.filter({ $0.title.lowercased() == fItem.title.lowercased() }).last{
            sheetVC.selectedList = selectedItems.filters
        }
        
        sheetVC.delegate = self
        sheetVC.modalPresentationStyle = .overCurrentContext
        UIApplication.topViewController()?.present(sheetVC, animated: true, completion: nil)
        
    }
    
    func didSelect(title: String, list: [FilterDTO], icon: String) {
        if let index = self.viewModel.arrSelectedFiltes.firstIndex(where: { $0.title.lowercased() ==  title.lowercased()}){
            self.viewModel.arrSelectedFiltes.remove(at: index)
            let filter = GroupedFilterDTO(list, title: title, icon: icon)
            self.viewModel.arrSelectedFiltes.append(filter)
        }else{
            let filter = GroupedFilterDTO(list, title: title, icon: icon)
            self.viewModel.arrSelectedFiltes.append(filter)
        }
        self.tblFilter.reloadData()
        PreferenceManager.shared.selectedFilters = self.viewModel.arrSelectedFiltes
        
        self.viewModel.getFilteredWorkouts { [weak self] in
            self?.updateShowButton()
        }
    }
}
