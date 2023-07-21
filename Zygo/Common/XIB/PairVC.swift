//
//  PairVC.swift
//  Zygo
//
//  Created by Priya Gandhi on 26/02/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol PairVCDelegates {
    func didPair(_ device: BTDevice)
    func didUnPair(_ device: BTDevice)
}

class PairVC: UIViewController {
    
    @IBOutlet weak var tblList: UITableView!
    @IBOutlet weak var bgImageView: UIImageView!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var btnDoneAction: UIButton!
    
    @IBOutlet weak var lblPairTitle: UILabel!
    
    var delegate: PairVCDelegates?
    var device: BTDevice!
    
    private let cellHeight: CGFloat = 60.0
    var list: [String] = []
    
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if device.device.state == .connected{
            self.lblTitle.text = "Do you want to unpair this device?"
            self.lblStatus.text = "Connected"
            self.lblStatus.textColor = UIColor.appBlueColor()
            self.statusImageView.image = UIImage(named: "icon_bluetooth_enable")
        }else{
            self.lblTitle.text = "Do you want to pair this device?"
            self.lblStatus.text = "Pair"
            self.lblStatus.textColor = UIColor.lightGray
            self.statusImageView.image = UIImage(named: "icon_bluetooth_disable")
        }
        
        lblPairTitle.text = device.device.name ?? "Unknown"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.showBGImage()
    }
    
    //MARK: - Setups
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
    
    @IBAction func doneAction(_ sender: UIButton){
        self.hideBGImage()
        if device.device.state == .connected{
            self.delegate?.didUnPair(self.device)
        }else{
            self.delegate?.didPair(self.device)
        }
        
        
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: -
}

