//
//  ProfileViewController.swift
//  Zygo
//
//  Created by Priya Gandhi on 31/01/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit
import XLPagerTabStrip


class ProfileViewController: ButtonBarPagerTabStripViewController, InfoViewControllerDelegates{
    
    var infoVC: InfoViewController!
    var historyVC: HistoryViewController!
    var metricsVC: MetricsViewController!
    var badgesVC: BadgesVC!
    
    /*@IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var imageView: UICircleImageView!
    
    @IBOutlet weak var btnChooseImage: UIButton!
    @IBOutlet weak var btnSmallChooseImage: UIButton!*/
    
    private lazy var user = PreferenceManager.shared.user
    private lazy var poolUnitInfo = PreferenceManager.shared.poolUnitInfo
    private lazy var imagePickerController = UIImagePickerController()
    private lazy var viewModel = CreateProfileViewModel()
    
    //MARK: -
    override func viewDidLoad() {
        
        infoVC = self.storyboard?.instantiateViewController(withIdentifier: "InfoViewController") as? InfoViewController
        infoVC.viewModel = self.viewModel
        infoVC.superObj = self
        infoVC.delegate = self
        
        historyVC = self.storyboard?.instantiateViewController(withIdentifier: "HistoryViewController") as? HistoryViewController
        historyVC.superObj = self
        
        metricsVC = self.storyboard?.instantiateViewController(withIdentifier: "MetricsViewController") as? MetricsViewController
        metricsVC.superObj = self
        
        badgesVC = self.storyboard?.instantiateViewController(withIdentifier: "BadgesVC") as? BadgesVC
        badgesVC.superObj = self
        
        self.setupTabBars()
        super.viewDidLoad()
        self.view.layoutIfNeeded()
            
        self.containerView.isScrollEnabled = false
        self.setupUserInfo()
        Helper.shared.log(event: .TABPROFILE, params: [:])
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    //MARK: - Setups
    func setupUserInfo(){
        self.viewModel.profileItem.image = nil
        /*self.lblUserName.text = user.name
        self.imageView.image = UIImage(named: "icon_default")
        if !user.profilePic.isEmpty{
            self.imageView.sd_setImage(with: URL(string: user.profilePic.getImageURL()), placeholderImage: UIImage(named: "icon_default"), options: .refreshCached, completed: nil)
        }*/
        
        user = PreferenceManager.shared.user

        let tempUB = user.birthday
        if let dob = tempUB.fromServerBirthday(){
            self.viewModel.profileItem.birthday = dob.toServerBirthday().trim()
        }
        
        self.viewModel.profileItem.email = user.email
        self.viewModel.profileItem.name = user.name
        self.viewModel.profileItem.fname = user.fName
        self.viewModel.profileItem.lname = user.lName
        self.viewModel.profileItem.gender = user.gender
        self.viewModel.profileItem.location = user.location
        self.viewModel.profileItem.tSerialNumber = user.tSerialNumber
        self.viewModel.profileItem.hSerialNumber = user.hSerialNumber
        
        let poolUnitInfo = PreferenceManager.shared.poolUnitInfo
        self.viewModel.profileItemPoolUnitInfo.customPoolDistance = poolUnitInfo.customPoolDistance
        self.viewModel.profileItemPoolUnitInfo.customPoolLengthUnits = poolUnitInfo.customPoolLengthUnits
        self.viewModel.profileItemPoolUnitInfo.defaultPoolLength = poolUnitInfo.defaultPoolLength
        self.viewModel.profileItemPoolUnitInfo.unitPref = poolUnitInfo.unitPref
    }
    
    func setupTabBars(){
        
        self.buttonBarView.setNeedsLayout()
        self.buttonBarView.layoutIfNeeded()
        
        settings.style.buttonBarBackgroundColor = .white
        settings.style.buttonBarItemBackgroundColor = .white
        settings.style.selectedBarBackgroundColor = UIColor.appBlueColor()
        settings.style.buttonBarItemFont = UIFont.appMedium(with: 16.0)
        settings.style.selectedBarHeight = 3.0
        settings.style.buttonBarMinimumLineSpacing = 1
        settings.style.buttonBarItemTitleColor = UIColor.appTitleDarkColor()
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = UIColor.appTitleDarkColor()
            newCell?.label.textColor = UIColor.appBlueColor()
            
            self.buttonBarView.setNeedsLayout()
            self.buttonBarView.layoutIfNeeded()
        }
        //moveToViewController(at: 1)
    }
    
    func isProfileChanged() -> Bool{
        let user = PreferenceManager.shared.user
        let poolUnitInfo = PreferenceManager.shared.poolUnitInfo
        
        if self.viewModel.profileItem.name != user.name{
            return true
        }
        
        if self.viewModel.profileItem.fname != user.fName{
            return true
        }
        
        if self.viewModel.profileItem.lname != user.lName{
            return true
        }
        
        if self.viewModel.profileItem.gender != user.gender{
            return true
        }
        
        if self.viewModel.profileItem.birthday != user.birthday{
            return true
        }
        
        if self.viewModel.profileItem.location != user.location{
            return true
        }
        
        if self.viewModel.profileItem.image != nil{
            return true
        }
        
        if self.viewModel.profileItem.tSerialNumber != user.tSerialNumber{
            return true
        }
        
        if self.viewModel.profileItem.hSerialNumber != user.hSerialNumber{
            return true
        }
        
        if self.viewModel.profileItemPoolUnitInfo.unitPref != poolUnitInfo.unitPref{
            return true
        }
        
        if self.viewModel.profileItemPoolUnitInfo.defaultPoolLength != poolUnitInfo.defaultPoolLength{
            return true
        }
        
        if self.viewModel.profileItemPoolUnitInfo.customPoolDistance != poolUnitInfo.customPoolDistance{
            return true
        }
        
        if self.viewModel.profileItemPoolUnitInfo.customPoolLengthUnits != poolUnitInfo.customPoolLengthUnits{
            return true
        }
        
        return false
    }
    
    func showProfileChangePopUp(){
        Helper.shared.alertYesNoActions(title: "Exit without saving?", message: "Are you sure you want to leave without saving your profile?", yesActionTitle: "Yes", noActionTitle: "No") { (isYes) in
            if isYes{
                self.infoVC.setupUserInfo()
                self.viewModel.profileItem.image = nil
                self.setupUserInfo()
            }
        }
    }
    
    /*func hideChooseImage(){
        self.btnChooseImage.isHidden = true
        self.btnSmallChooseImage.isHidden = true
    }
    
    func showChooseImage(){
        self.btnChooseImage.isHidden = false
        self.btnSmallChooseImage.isHidden = false
    }*/
    
    //MARK: - UIButton Actions
    func didPressSave() {
        self.viewModel.updateProfile { [weak self] (isUpdated, profileImage) in
            Helper.shared.log(event: .SAVEPROFILE, params: [:])
            if isUpdated{
                //Update User
                self?.user.profilePic = profileImage
                self?.user.name = self?.viewModel.profileItem.name ?? ""
                self?.user.fName = self?.viewModel.profileItem.fname ?? ""
                self?.user.lName = self?.viewModel.profileItem.lname ?? ""
                self?.user.gender = self?.viewModel.profileItem.gender ?? ""
                self?.user.birthday = self?.viewModel.profileItem.birthday ?? ""
                self?.user.location = self?.viewModel.profileItem.location ?? ""
                self?.user.tSerialNumber = self?.viewModel.profileItem.tSerialNumber ?? ""
                self?.user.hSerialNumber = self?.viewModel.profileItem.hSerialNumber ?? ""
                
                self?.poolUnitInfo.customPoolDistance = self?.viewModel.profileItemPoolUnitInfo.customPoolDistance ?? 0.0
                self?.poolUnitInfo.customPoolLengthUnits = self?.viewModel.profileItemPoolUnitInfo.customPoolLengthUnits ?? .yards
                self?.poolUnitInfo.defaultPoolLength = self?.viewModel.profileItemPoolUnitInfo.defaultPoolLength ?? .twentyFiveYards
                self?.poolUnitInfo.unitPref = self?.viewModel.profileItemPoolUnitInfo.unitPref ?? .standard
                
                if let nUser = self?.user{
                    PreferenceManager.shared.user = nUser
                }
                
                if let poolUnitInfo = self?.poolUnitInfo{
                    PreferenceManager.shared.poolUnitInfo = poolUnitInfo
                }
                
                self?.setupUserInfo()
                //self?.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func backAction(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func homeAction(_ sender: UIButton){
        sideMenuController?.revealMenu()
    }
    
    /*@IBAction func chooseImageAction(_ sender: UIButton){
        self.imageOptionsAlert()
    }*/
    
    // MARK: - PagerTabStripDataSource
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        return [badgesVC, historyVC, infoVC]
    }
}


//MARK: - Image Picker
/*extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imageOptionsAlert(){
        let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        
        //Take Photo Action
        let takePhotoAction = UIAlertAction.init(title: NSLocalizedString("Take Photo", comment: ""), style: .default) { (action) in
            //Show ImagePicker Controller with camera
            self.imagePickerController.delegate = self
            self.imagePickerController.allowsEditing = true
            self.imagePickerController.sourceType = .camera
            self.imagePickerController.cameraDevice = .front
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
        
        //Choose Photo Action
        let choosePhotoAction = UIAlertAction.init(title: NSLocalizedString("Choose Photo", comment: ""), style: .default) { (action) in
            //Show ImagePicker Controller with photo gallary
            self.imagePickerController.delegate = self
            self.imagePickerController.allowsEditing = true
            self.imagePickerController.sourceType = .photoLibrary
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
        
        //Cancel Action
        let cancelAction = UIAlertAction.init(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { (action) in
        }
        
        //Add all actions in alert controller
        //If camera availabel in device then show option of take photo
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            alert.addAction(takePhotoAction)
        }
        alert.addAction(choosePhotoAction)
        alert.addAction(cancelAction)
        
        //Present aler controller on current controller
        self.present(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            return
        }
        
        picker.dismiss(animated: true, completion: nil)
        self.imageView.image = image
        self.viewModel.profileItem.image = image
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}*/
