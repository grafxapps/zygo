//
//  InstructorsListViewController.swift
//  Zygo
//
//  Created by Som on 10/08/21.
//  Copyright © 2021 Somparkash. All rights reserved.
//

import UIKit

//MARK: -
class InstructorsListViewController: UIViewController {
    
    @IBOutlet weak var tblList: UITableView!
    
    private let viewModel = InstructorViewModel()
    private var refreshControl = UIRefreshControl()
    
    //MARK: - UIViewcontroller LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerCustomCells()
        self.fetchInstructors()
    }
    
    //MARK: - Setups
    func registerCustomCells(){
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(self.fetchInstructors), for: .valueChanged)
        self.tblList.refreshControl = self.refreshControl
        self.tblList.separatorStyle = .none
        self.tblList.register(UINib(nibName: InstructorTVC.identifier, bundle: nil), forCellReuseIdentifier: InstructorTVC.identifier)
    }
    
    @objc func fetchInstructors(){
        self.viewModel.getInstructors {
            self.refreshControl.endRefreshing()
            self.tblList.reloadData()
        }
    }
    
    //MARK: - UIButton Actions
    @IBAction func backAction(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
}

extension InstructorsListViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.arrInstructors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: InstructorTVC.identifier) as! InstructorTVC
        cell.selectionStyle = .none
        let item = self.viewModel.arrInstructors[indexPath.row]
        cell.setupInfo(item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        Helper.shared.log(event: .TABPROFILE, params: [:])
        let instVC = self.storyboard?.instantiateViewController(withIdentifier: "InstructorViewController") as! InstructorViewController
        let item = self.viewModel.arrInstructors[indexPath.row]
        instVC.viewModel.instructor = item
        self.navigationController?.pushViewController(instVC, animated: true)
    }
}
