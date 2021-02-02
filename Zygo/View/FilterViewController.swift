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
    private let filterIdentifier = "FilterTVC"
    var arrFilters : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        arrFilters = ["Workout Type","Duration","Difficulty Level","Instructor","Equipment","Series","Pool Length"]
        self.registerTVC()
    }
    
    //MARK:- Setup
    func registerTVC()  {
        tblFilter.register(UINib.init(nibName: filterIdentifier, bundle: nil), forCellReuseIdentifier: filterIdentifier);
        
    }
}
extension FilterViewController : UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrFilters.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : FilterTVC = tableView.dequeueReusableCell(withIdentifier: filterIdentifier) as! FilterTVC
        cell.lblTitle.text = arrFilters[indexPath.row]
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
