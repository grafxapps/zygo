//
//  HealthKitPermissionPopupVC.swift
//  Zygo
//
//  Created by Som Parkash on 22/03/23.
//  Copyright © 2023 Somparkash. All rights reserved.
//

import UIKit

class HealthKitPermissionPopupVC: UIViewController {
    
    @IBOutlet weak var btnYes: UIButton!
    
    @IBOutlet weak var settingsView: UIView!
    
    private var onGrant: (() -> Void)?
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, onGrant: @escaping () -> Void) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.onGrant = onGrant
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    //MARK: - Setups
    func setupUI(){
        self.btnYes.layer.cornerRadius = 10.0
    }
    
    //MARK: - UIButton Actions
    @IBAction func yesAction(_ sender: UIButton){
        self.dismiss(animated: true) {
            self.onGrant?()
        }
    }
    
    @IBAction func noAction(_ sender: UIButton){
        self.settingsView.isHidden = false
        self.btnYes.isHidden = true
        
    }
    
    @IBAction func closeAction(_ sender: UIButton){
        self.dismiss(animated: true)
    }
    
    @IBAction func grantAction(_ sender: UIButton){
        self.dismiss(animated: true) {
            self.onGrant?()
        }
    }
}
