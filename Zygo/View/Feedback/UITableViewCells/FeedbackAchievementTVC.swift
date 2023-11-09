//
//  FeedbackAchievementTVC.swift
//  Zygo
//
//  Created by Som on 16/02/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit


protocol FeedbackAchievementTVCDelegates {
    func didScrollAt(_ position: Int)
}

class FeedbackAchievementTVC: UITableViewCell {
    
    @IBOutlet weak var collectionView : UICollectionView!
    @IBOutlet weak var pageControl : UIPageControl!
    
    var delegate: FeedbackAchievementTVCDelegates?
    static let identifier: String = "FeedbackAchievementTVC"
    private var arrAchievements: [AchievementDTO] = []
    private var itemSize: CGSize = CGSize.zero
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.registerCustomCells()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func registerCustomCells(){
        
        let layout = UICollectionViewFlowLayout();
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal; //.horizontal
        layout.itemSize = CGSize(width: ScreenSize.SCREEN_WIDTH - 30.0, height: 190.0)
        self.collectionView.collectionViewLayout = layout
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        
        self.collectionView.register(UINib.init(nibName: FeedbackAchievementCVC.identifier, bundle: nil), forCellWithReuseIdentifier: FeedbackAchievementCVC.identifier)
    }
    
    func setupAchievementDetail(arrAchi: [AchievementDTO], maxHeight: CGFloat){
        self.arrAchievements.removeAll(keepingCapacity: true)
        self.arrAchievements.append(contentsOf: arrAchi)
        
        if self.arrAchievements.count > 1{
            self.pageControl.numberOfPages = self.arrAchievements.count
        }else{
            self.pageControl.numberOfPages = 0
        }
        
        let textWidth = ScreenSize.SCREEN_WIDTH - 30.0
        self.itemSize = CGSize(width: textWidth, height: maxHeight - 25)
        
        self.collectionView.reloadData()
    }
    
}

extension FeedbackAchievementTVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrAchievements.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeedbackAchievementCVC.identifier, for: indexPath) as! FeedbackAchievementCVC
        
        let item = self.arrAchievements[indexPath.row]
        cell.lblTitle.text = item.name
        cell.lblDescription.text = item.message
        
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == collectionView{
            print("Scroll to next Achievement")
            if self.arrAchievements.count > 1{
                let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
                let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
                let visibleIndexPath = collectionView.indexPathForItem(at: visiblePoint)
                self.pageControl.currentPage = visibleIndexPath?.row ?? 0
                self.delegate?.didScrollAt(visibleIndexPath?.row ?? 0)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.itemSize
    }
}
