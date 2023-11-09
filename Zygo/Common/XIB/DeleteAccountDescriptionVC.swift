//
//  DeleteAccountDescriptionVC.swift
//  Zygo
//
//  Created by Som on 12/06/22.
//  Copyright © 2022 Somparkash. All rights reserved.
//

import UIKit

//MARK: -
class DeleteAccountDescriptionVC: UIViewController {

    @IBOutlet weak var contentInfoView: UIView!
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var bgImageView: UIImageView!
    
    var onContinue: (() -> Void)?
    
    //MARK: - UIViewcontroller LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.showBGImage()
    }
    
    //MARK: - Setups
    func setupUI(){
        contentInfoView.layer.cornerRadius = 10.0
        contentInfoView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        bottomView.layer.cornerRadius = 10.0
        bottomView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
    
    func showBGImage(){
        self.bgImageView.alpha = 0.0
        UIView.animate(withDuration: 1.0) {
            self.bgImageView.alpha = 0.4
        }
    }
    
    func hideBGImage(){
        self.bgImageView.alpha = 0.0
    }
    
    //MARK: - UIButton Actions
    @IBAction func backAction(_ sender: UIButton){
        self.hideBGImage()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func continueAction(_ sender: UIButton){
        self.hideBGImage()
        self.dismiss(animated: true) {
            self.onContinue?()
        }
    }
    
}
