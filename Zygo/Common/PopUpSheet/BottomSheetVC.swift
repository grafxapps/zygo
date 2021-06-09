//
//  BottomSheetVC.swift
//  Zygo
//
//  Created by Som on 01/02/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit
import SDWebImage

protocol BottomSheetVCDelegates {
    func didSelect(title: String, list: [FilterDTO], icon: String)
}

//MARK: -
class BottomSheetVC: UIViewController {
    
    @IBOutlet weak var tblList: UITableView!
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var btnDoneAction: UIButton!
    
    @IBOutlet weak var tblHeightConstraint: NSLayoutConstraint!
    
    private let cellHeight: CGFloat = 60.0
    
    var delegate: BottomSheetVCDelegates?
    var list: [FilterDTO] = []
    var selectedList: [FilterDTO] = []
    var mTitle: String = ""
    var icon: String = ""
    
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        self.lblTitle.text = self.mTitle
        
        let screenHeight = ScreenSize.SCREEN_HEIGHT
        
        let constantHeight: CGFloat = 355.0
        let tblHeight = cellHeight * CGFloat(self.list.count)
        let totalHeight = tblHeight + constantHeight
        if  totalHeight > screenHeight{
            self.tblHeightConstraint.constant = tblHeight - (totalHeight - screenHeight)
        }else{
            self.tblHeightConstraint.constant = tblHeight
            //self.view.layoutIfNeeded()
        }
        
        self.iconImageView.image = nil
        self.iconImageView.backgroundColor = .white
        if !self.icon.isEmpty{
            self.iconImageView.sd_setImage(with: URL(string: self.icon.getImageURL()), placeholderImage: nil, options: .progressiveLoad, completed: nil)
        }
        
        
        //Constant Height
        //355
    }
    
    func registerCustomCells(){
        self.tblList.separatorStyle = .none
        self.tblList.estimatedRowHeight = 80.0
        self.tblList.rowHeight = cellHeight
        self.tblList.register(UINib(nibName: SheetTCV.identifier, bundle: nil), forCellReuseIdentifier: SheetTCV.identifier)
    }
    
    
    //MARK: - UIButton Actions
    @IBAction func backAction(_ sender: UIButton){
        self.hideBGImage()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneAction(_ sender: UIButton){
        self.hideBGImage()
        delegate?.didSelect(title: self.mTitle, list: self.selectedList, icon: self.icon)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func selectAction(_ sender: UIButton){
        
        let index = sender.tag
        if index >= self.list.count{
            return
        }
        
        let item = self.list[index]
        if let fIndex = self.selectedList.firstIndex(where: { $0.fId == item.fId }){
            selectedList.remove(at: fIndex)
        }else{
            selectedList.append(item)
        }
        self.tblList.reloadData()
    }
    
    //MARK: -
}


extension BottomSheetVC: UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SheetTCV.identifier) as! SheetTCV
        let item = self.list[indexPath.row]
        cell.lblTitle.text = item.fTitle
        cell.selectionStyle = .none
        cell.btnSelect.tag = indexPath.row
        cell.btnSelect.addTarget(self, action: #selector(self.selectAction(_:)), for: .touchUpInside)
        
        cell.iconImageView.image = UIImage(named: "icon_uncheck_circle")
        if self.selectedList.contains(where: { $0.fId == item.fId }){
            cell.iconImageView.image = UIImage(named: "icon_check_circle")
        }
        
        return cell
    }
    
}
