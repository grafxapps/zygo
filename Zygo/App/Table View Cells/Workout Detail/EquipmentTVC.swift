//
//  EquipmentTVC.swift
//  Zygo
//
//  Created by Priya Gandhi on 04/02/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit

class EquipmentTVC: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    
    static let identifier = "EquipmentTVC"
    @IBOutlet weak var collecEquip : UICollectionView!
    
    var arrEquipments: [WorkoutEquipmentDTO] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupCollectionView()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setupCollectionView()  {
        let cellSize = CGSize(width: 75, height: 75);
        collecEquip.register(UINib.init(nibName: EquipmentCVC.identifier, bundle: nil), forCellWithReuseIdentifier: EquipmentCVC.identifier)
        
        let layout = UICollectionViewFlowLayout();
        layout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        layout.scrollDirection = .horizontal; //.horizontal
        layout.itemSize = cellSize;
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collecEquip.setCollectionViewLayout(layout, animated: true);
        collecEquip.reloadData();
        collecEquip.dataSource = self;
        collecEquip.delegate = self;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrEquipments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EquipmentCVC.identifier, for: indexPath) as! EquipmentCVC;
        
        let item = self.arrEquipments[indexPath.row]
        
        cell.eImageView.image = nil
        cell.eImageView.backgroundColor = .white
        if !item.image.isEmpty{
            cell.eImageView.sd_setImage(with: URL(string: item.image.getImageURL()), placeholderImage: nil, options: .refreshCached, completed: nil)
        }
        
        return cell
    }
    
    func updateEquipments(arrEquipments: [WorkoutEquipmentDTO]){
        self.arrEquipments.removeAll(keepingCapacity: true)
        self.arrEquipments.append(contentsOf: arrEquipments)
        self.collecEquip.reloadData()
    }
}
