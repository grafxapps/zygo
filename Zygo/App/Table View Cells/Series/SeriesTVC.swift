//
//  SeriesTVC.swift
//  Zygo
//
//  Created by Priya Gandhi on 16/02/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit

protocol SeriesTVCDelegates{
   func didSelect(workout: WorkoutDTO)
}

class SeriesTVC: UITableViewCell {
    
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var seriesClcView : UICollectionView!
    
    @IBOutlet weak var collectionViewHeightConstraint : NSLayoutConstraint!
    
    static let identifier = "SeriesTVC"
    
    var workoutInfo: [WorkoutDTO] = []
    var delegate: SeriesTVCDelegates?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let totalCellHeight = Helper.shared.getWorkoutCellHeight()
       
        self.collectionViewHeightConstraint.constant = totalCellHeight + 10.0//35.0
        self.layoutIfNeeded()
        
        let cellSize = CGSize(width: ScreenSize.SCREEN_WIDTH - 44.0, height: totalCellHeight);
        self.seriesClcView.register(UINib.init(nibName: SeriesCVC.identifier, bundle: nil), forCellWithReuseIdentifier: SeriesCVC.identifier)
        let layout = UICollectionViewFlowLayout();
        layout.sectionInset = UIEdgeInsets(top: 0, left: 21.0, bottom: 0, right: 21.0)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal; //.horizontal
        layout.itemSize = cellSize;
        self.seriesClcView.dataSource = self;
        self.seriesClcView.delegate = self;
        self.seriesClcView.collectionViewLayout = layout
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setupWorkoutInfo(item: SeriesDTO){
        self.lblTitle.text = item.seriesName
        workoutInfo = item.seriesWorkouts
        seriesClcView.reloadData()
    }
    
    
}
extension SeriesTVC: UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return workoutInfo.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SeriesCVC", for: indexPath) as! SeriesCVC;
        let item = workoutInfo[indexPath.row]
        cell.setupWorkoutInfo(item: item, index: indexPath.row)
        
        return cell;
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelect(workout: self.workoutInfo[indexPath.row])
    }
}
