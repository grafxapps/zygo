//
//  AchievementsTVC.swift
//  Zygo
//
//  Created by Priya Gandhi on 29/01/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit
protocol AchievementsTVCDelegates  {
    func didSelect(achievement: AchievementDTO)
}

class AchievementsTVC: UITableViewCell {
    @IBOutlet weak var achievementsClcView : UICollectionView!
    
    static let identifier = "AchievementsTVC"
    
    var arrAchievements: [AchievementDTO] = []
    var delegate: AchievementsTVCDelegates?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let cellSize = CGSize(width: (ScreenSize.SCREEN_WIDTH - 20)/3, height: 170);
        self.achievementsClcView.register(UINib.init(nibName: AchievementsCVC.identifier, bundle: nil), forCellWithReuseIdentifier: AchievementsCVC.identifier)
        
        let layout = UICollectionViewFlowLayout();
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .vertical; //.horizontal
        layout.itemSize = cellSize;
        self.achievementsClcView.setCollectionViewLayout(layout, animated: true);
        self.achievementsClcView.dataSource = self;
        self.achievementsClcView.delegate = self;
    }
    
    func setupAchievements(_ arrTempAchievements: [AchievementDTO]){
        self.arrAchievements.removeAll(keepingCapacity: true)
        self.arrAchievements.append(contentsOf: arrTempAchievements)
        self.achievementsClcView.reloadData()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

extension AchievementsTVC: UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrAchievements.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AchievementsCVC", for: indexPath) as! AchievementsCVC;
        let item = self.arrAchievements[indexPath.row]
        cell.lblTitle.text = item.name
        
        cell.iconImageView.image = nil
        cell.iconImageView.backgroundColor = .white
        if !item.icon.isEmpty{
            cell.iconImageView.sd_setImage(with: URL(string: item.icon.getImageURL()), placeholderImage: nil, options: .refreshCached, completed: nil)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelect(achievement: self.arrAchievements[indexPath.row])
    }
}
