//
//  TutorialsZ2VC.swift
//  Zygo
//
//  Created by Som Parkash on 06/12/24.
//  Copyright © 2024 Somparkash. All rights reserved.
//

import UIKit

//MARK: -
class TutorialsZ2VC: UIViewController {
    
    @IBOutlet weak var tutorialCollectionView: UICollectionView!
    @IBOutlet weak var tutorialPageControl: UIPageControl!
    
    private var tutorial: [UIImage] = []
    var type: TutorialType = .getStarted
    enum TutorialType{
        case getStarted
        case pairing
        case charging
        case countingLaps
        case syncingWithHeadset
        
        var content: [UIImage] {
            switch self {
            case .getStarted:
                return [Asset.Tutorials._1.image, Asset.Tutorials._2.image, Asset.Tutorials._3.image, Asset.Tutorials._4.image, Asset.Tutorials._10.image, Asset.Tutorials._11.image, Asset.Tutorials._12.image, Asset.Tutorials._13.image, Asset.Tutorials._17.image]
            case .pairing:
                return [Asset.Tutorials._5.image, Asset.Tutorials._7.image, Asset.Tutorials._16.image, Asset.Tutorials._15.image]
            case .charging:
                return [Asset.Tutorials._8.image, Asset.Tutorials._9.image]
            case .countingLaps:
                return [Asset.Tutorials._14.image]
            case .syncingWithHeadset:
                return [Asset.Tutorials._18.image]
            }
        }
    }

    //MARK: - UIViewcontroller LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tutorial = self.type.content
        self.tutorialPageControl.numberOfPages = self.tutorial.count
        if self.tutorial.count <= 1{
            self.tutorialPageControl.isHidden = true
        }
        self.registerCustomCell()
    }
    
    //MARK: - Setups
    private func registerCustomCell(){
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        self.tutorialCollectionView.collectionViewLayout = layout
        
        self.tutorialCollectionView.register(UINib(nibName: TutorialCVC.identifier, bundle: nil), forCellWithReuseIdentifier: TutorialCVC.identifier)
    }
    
    //MARK: - UIButton Actions
    @IBAction private func backButtonPressed(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
}

//MARK: -
extension TutorialsZ2VC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tutorial.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TutorialCVC.identifier, for: indexPath) as! TutorialCVC
        cell.imageView.image = tutorial[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.tutorialCollectionView.frame.size
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = Int(scrollView.contentOffset.x/scrollView.frame.size.width)
        self.tutorialPageControl.currentPage = pageIndex
    }
}
