//
//  DefaultFeedbackTVC.swift
//  Zygo
//
//  Created by Priya Gandhi on 15/02/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit

protocol DefaultFeedbackTVCDelegates{
    
    func didSelectFeedback(status: ThumbStatus, dificultyLevel: Int)
}

class DefaultFeedbackTVC: UITableViewCell {
    
    @IBOutlet weak var btnThumbsUp : UIButton!
    @IBOutlet weak var btnThumbsDown : UIButton!
    
    @IBOutlet weak var btnShare : UIButton!
    
    @IBOutlet weak var likeCollectionView : UICollectionView!
    
    var delegate: DefaultFeedbackTVCDelegates?
    
    private var thumb: ThumbStatus = .none
    private var dificultyLevel: Int = -1
    static let identifierCVC = "LikeCVC"
    
    static let identifier: String = "DefaultFeedbackTVC"
    var arrList : [Int] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        arrList = Array(1...10)
        
        let cellSize = CGSize(width: 30, height: 30);
        self.likeCollectionView.register(UINib.init(nibName: LikeCVC.identifier, bundle: nil), forCellWithReuseIdentifier: LikeCVC.identifier)
        
        let layout = UICollectionViewFlowLayout();
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal; //.horizontal
        layout.itemSize = cellSize;
        self.likeCollectionView.setCollectionViewLayout(layout, animated: true);
        self.likeCollectionView.dataSource = self;
        self.likeCollectionView.delegate = self;
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setupThumb(status: ThumbStatus){
        self.thumb = status
        switch status {
        case .up:
            self.btnThumbsUp.isSelected = true
            self.btnThumbsDown.isSelected = false
        case .down:
            self.btnThumbsUp.isSelected = false
            self.btnThumbsDown.isSelected = true
        case .none:
            self.btnThumbsUp.isSelected = false
            self.btnThumbsDown.isSelected = false
        }
    }
    
    @IBAction func thumbUpAction(_ sender: UIButton){
        self.thumb = .up
        self.btnThumbsUp.isSelected = true
        self.btnThumbsDown.isSelected = false
        self.delegate?.didSelectFeedback(status: self.thumb, dificultyLevel: self.dificultyLevel)
    }
    
    @IBAction func thumbDownAction(_ sender: UIButton){
        self.thumb = .down
        self.btnThumbsUp.isSelected = false
        self.btnThumbsDown.isSelected = true
        self.delegate?.didSelectFeedback(status: self.thumb, dificultyLevel: self.dificultyLevel)
    }
    
    @objc func dificultySelctAction(_ sender: UIButton){
        self.dificultyLevel = sender.tag + 1
        self.likeCollectionView.reloadData()
        self.delegate?.didSelectFeedback(status: self.thumb, dificultyLevel: self.dificultyLevel)
    }
    
}
extension DefaultFeedbackTVC: UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LikeCVC", for: indexPath) as! LikeCVC;
        cell.btnTitle.setTitle(String(arrList[indexPath.row]), for: .normal)
        cell.btnTitle.addTarget(self, action: #selector(self.dificultySelctAction(_:)), for: .touchUpInside)
        cell.btnTitle.tag = indexPath.row
        
        cell.btnTitle.isSelected = false
        cell.btnTitle.backgroundColor = UIColor.white
        if indexPath.row == (self.dificultyLevel - 1){
            cell.btnTitle.isSelected = true
            cell.btnTitle.backgroundColor = UIColor.appBlueColor()
        }
        return cell;
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        self.dificultyLevel = indexPath.row + 1
        self.likeCollectionView.reloadData()
    }
}

enum ThumbStatus{
    case none
    case up
    case down
}
