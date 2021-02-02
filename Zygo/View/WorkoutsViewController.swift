//
//  WorkoutsViewController.swift
//  Zygo
//
//  Created by Priya Gandhi on 24/01/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit

class WorkoutsViewController: UIViewController {
    @IBOutlet weak var tblWorkouts : UITableView!
    private let workoutIdentifier = "WorkoutInfoTVC"

    override func viewDidLoad() {
        super.viewDidLoad()
        registerTVC()

        // Do any additional setup after loading the view.
    }
    
    //MARK:- Setup
      func registerTVC()  {
          tblWorkouts.register(UINib.init(nibName: workoutIdentifier, bundle: nil), forCellReuseIdentifier: workoutIdentifier);
          
      }
    

}

extension WorkoutsViewController : UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : WorkoutInfoTVC = tableView.dequeueReusableCell(withIdentifier: workoutIdentifier) as! WorkoutInfoTVC
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
}
