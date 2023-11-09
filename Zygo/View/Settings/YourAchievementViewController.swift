//
//  YourAchievementViewController.swift
//  Zygo
//
//  Created by Priya Gandhi on 02/02/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit

//MARK: -
class YourAchievementViewController: UIViewController {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UITextView!
    
    var item: AchievementDTO!
    
    //MARK: - UIViewController LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadAchievementData()
    }
    
    //MARK: - Setups
    func loadAchievementData(){
        
        self.iconImageView.image = nil
        self.iconImageView.backgroundColor = .white
        if !item.icon.isEmpty{
            self.iconImageView.sd_setImage(with: URL(string: item.icon.getImageURL()), placeholderImage: nil, options: .refreshCached, completed: nil)
        }
        
        self.lblTitle.text = item.name
        let newDescription = item.descriptions.htmlToAttributedString
        newDescription?.addAttribute(.foregroundColor, value: self.lblDescription.textColor!, range: NSRange(location: 0, length: newDescription?.string.count ?? 0))
        self.lblDescription.attributedText = newDescription
    }
    
    //MARK: - UIButton Actions
    @IBAction func backAction(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
}
