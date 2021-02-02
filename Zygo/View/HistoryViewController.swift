//
//  HistoryViewController.swift
//  Zygo
//
//  Created by Priya Gandhi on 29/01/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class HistoryViewController: UIViewController {
    @IBOutlet weak var tblHistory : UITableView!
    private let historyInfoIdentifier = "HistoryInfoTVC"
    private let acheivementsIdentifier = "AchievementsTVC"
    private let pastWorkoutsIdentifier = "PastWorkoutsTVC"
    var itemInfo = IndicatorInfo(title: "History")

    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerTVC()
    }
    //MARK:- Setup
      func registerTVC()  {
          tblHistory.register(UINib.init(nibName: historyInfoIdentifier, bundle: nil), forCellReuseIdentifier: historyInfoIdentifier);
        tblHistory.register(UINib.init(nibName: acheivementsIdentifier, bundle: nil), forCellReuseIdentifier: acheivementsIdentifier);
        tblHistory.register(UINib.init(nibName: pastWorkoutsIdentifier, bundle: nil), forCellReuseIdentifier: pastWorkoutsIdentifier);

          
      }

}

extension HistoryViewController : UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
    return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }else if section == 1{
            return 1;
        }else{
            return 12;
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell : HistoryInfoTVC = tableView.dequeueReusableCell(withIdentifier: historyInfoIdentifier) as! HistoryInfoTVC
            return cell;
        }else if indexPath.section == 1{
            let cell : AchievementsTVC = tableView.dequeueReusableCell(withIdentifier: acheivementsIdentifier) as! AchievementsTVC
            let cellSize = CGSize(width:195, height:190);
            cell.achievementsClcView.register(UINib.init(nibName: "AchievementsCVC", bundle: nil), forCellWithReuseIdentifier: "AchievementsCVC")
                   
                   let layout = UICollectionViewFlowLayout();
                   layout.scrollDirection = .horizontal; //.horizontal
                   layout.itemSize = cellSize;
                   cell.achievementsClcView.setCollectionViewLayout(layout, animated: true);
                   cell.achievementsClcView.reloadData();
                   cell.achievementsClcView.dataSource = self;
                   cell.achievementsClcView.delegate = self;
            return cell;
        }else{
            let cell : PastWorkoutsTVC = tableView.dequeueReusableCell(withIdentifier: pastWorkoutsIdentifier) as! PastWorkoutsTVC
            return cell;
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            return 140.0
        }else if indexPath.section == 1{
            return 190.0
        }else{
            return 60.0

        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AchievementsCVC", for: indexPath) as! AchievementsCVC;
        return cell;
    }
}
extension HistoryViewController : IndicatorInfoProvider{
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}
