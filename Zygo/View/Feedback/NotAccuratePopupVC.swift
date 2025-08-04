//
//  NotAccuratePopupVC.swift
//  Zygo
//
//  Created by Som Parkash on 22/03/23.
//  Copyright © 2023 Somparkash. All rights reserved.
//

import UIKit

//MARK: -
class NotAccuratePopupVC: UIViewController {
    
    @IBOutlet weak var outOfPoolImageView: UIImageView!
    @IBOutlet weak var openWaterImageView: UIImageView!
    @IBOutlet weak var notSyncImageView: UIImageView!
    @IBOutlet weak var dontKnowImageView: UIImageView!
    
    private var isOutOfPool: Bool = false
    private var isOpenWater: Bool = false
    private var isNotSync: Bool = false
    private var isDontKnow: Bool = false
    
    private var onSave: ((Bool, Bool, Bool, Bool) -> Void)?
    //MARK: - UIViewcontroller LifeCycle
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, onSave: @escaping (Bool, Bool, Bool, Bool) -> Void) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.onSave = onSave
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.updateChecks()
    }
    
    //MARK: - Setups
    func updateChecks(){
        
        let unCheckImageName: String = "icon_uncheck_circle"
        let checkImageName: String = "icon_check_circle"
        
        if isOutOfPool{
            self.outOfPoolImageView.image = UIImage(named: checkImageName)
        }else{
            self.outOfPoolImageView.image = UIImage(named: unCheckImageName)
        }
        
        if isOpenWater{
            self.openWaterImageView.image = UIImage(named: checkImageName)
        }else{
            self.openWaterImageView.image = UIImage(named: unCheckImageName)
        }
        
        if isNotSync{
            self.notSyncImageView.image = UIImage(named: checkImageName)
        }else{
            self.notSyncImageView.image = UIImage(named: unCheckImageName)
        }
        
        if isDontKnow{
            self.dontKnowImageView.image = UIImage(named: checkImageName)
        }else{
            self.dontKnowImageView.image = UIImage(named: unCheckImageName)
        }
        
    }
    
    
    //MARK: - UIButton Actions
    @IBAction func outOfPoolAction(_ sender: UIButton){
        if isOutOfPool{
            isOutOfPool = false
        }else{
            isOutOfPool = true
        }
        
        self.updateChecks()
    }
    
    @IBAction func openWaterAction(_ sender: UIButton){
        if isOpenWater{
            isOpenWater = false
        }else{
            isOpenWater = true
        }
        
        self.updateChecks()
    }
    
    @IBAction func notSyncAction(_ sender: UIButton){
        if isNotSync{
            isNotSync = false
        }else{
            isNotSync = true
        }
        
        self.updateChecks()
    }
    
    @IBAction func dontKnowAction(_ sender: UIButton){
        if isDontKnow{
            isDontKnow = false
        }else{
            isDontKnow = true
        }
        
        self.updateChecks()
    }
    
    @IBAction func saveAction(_ sender: UIButton){
        self.dismiss(animated: true) {
            self.onSave?(self.isOutOfPool, self.isOpenWater, self.isNotSync, self.isDontKnow)
        }
    }
    
    //MARK: -
    
}
