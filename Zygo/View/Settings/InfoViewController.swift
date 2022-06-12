//
//  InfoViewController.swift
//  Zygo
//
//  Created by Priya Gandhi on 31/01/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit
import XLPagerTabStrip

protocol InfoViewControllerDelegates {
    func didPressSave()
}

class InfoViewController: UIViewController {
    
    var itemInfo = IndicatorInfo(title: "INFO")
    
    var delegate: InfoViewControllerDelegates?
    
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var imageView: UICircleImageView!
    
    @IBOutlet weak var btnChooseImage: UIButton!
    @IBOutlet weak var btnSmallChooseImage: UIButton!
    
    @IBOutlet weak var viewFName: UIView!
    @IBOutlet weak var viewLName: UIView!
    @IBOutlet weak var viewUName: UIView!
    @IBOutlet weak var viewHSerialNumber: UIView!
    @IBOutlet weak var viewTSerialNumber: UIView!
    @IBOutlet weak var viewGender: UIView!
    @IBOutlet weak var viewBirthday: UIView!
    @IBOutlet weak var viewLocation: UIView!
    @IBOutlet weak var viewPoolLength: UIView!
    @IBOutlet weak var viewUnitPreference: UIView!
    
    @IBOutlet weak var txtFName: UITextField!
    @IBOutlet weak var txtLName: UITextField!
    @IBOutlet weak var txtUName: UITextField!
    @IBOutlet weak var txtHSerialNumber: UITextField!
    @IBOutlet weak var txtTSerialNumber: UITextField!
    @IBOutlet weak var txtGender: UITextField!
    @IBOutlet weak var txtBirthday: UITextField!
    @IBOutlet weak var txtLocation: UITextField!
    @IBOutlet weak var txtUnit: UITextField!
    @IBOutlet weak var txtPoolLength: UITextField!
    
    private lazy var datePicker = UIDatePicker()
    private lazy var genderPicker = UIPickerView()
    private lazy var unitPicker = UIPickerView()
    private lazy var poolLengthPicker = UIPickerView()
    private lazy var user = PreferenceManager.shared.user
    private lazy var imagePickerController = UIImagePickerController()
    
    var viewModel: CreateProfileViewModel!
    
    var superObj: ProfileViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.setupPicker()
        self.setupUserInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.superObj.showChooseImage()
    }
    
    //MARK: - Setups
    func setupUI()  {
        
        txtFName.addTarget(self, action: #selector(self.textDidChange(_:)), for: .editingChanged)
        txtLName.addTarget(self, action: #selector(self.textDidChange(_:)), for: .editingChanged)
        txtUName.addTarget(self, action: #selector(self.textDidChange(_:)), for: .editingChanged)
        
        txtHSerialNumber.addTarget(self, action: #selector(self.textDidChange(_:)), for: .editingChanged)
        txtTSerialNumber.addTarget(self, action: #selector(self.textDidChange(_:)), for: .editingChanged)
        txtGender.addTarget(self, action: #selector(self.textDidChange(_:)), for: .editingChanged)
        txtBirthday.addTarget(self, action: #selector(self.textDidChange(_:)), for: .editingChanged)
        txtLocation.addTarget(self, action: #selector(self.textDidChange(_:)), for: .editingChanged)
        
        Helper.shared.setupViewLayer(sender: self.viewFName, isSsubScriptionView: false);
        Helper.shared.setupViewLayer(sender: self.viewLName, isSsubScriptionView: false);
        Helper.shared.setupViewLayer(sender: self.viewUName, isSsubScriptionView: false);
        Helper.shared.setupViewLayer(sender: self.viewHSerialNumber, isSsubScriptionView: false);
        Helper.shared.setupViewLayer(sender: self.viewTSerialNumber, isSsubScriptionView: false);
        Helper.shared.setupViewLayer(sender: self.viewGender, isSsubScriptionView: false);
        Helper.shared.setupViewLayer(sender: self.viewBirthday, isSsubScriptionView: false);
        Helper.shared.setupViewLayer(sender: self.viewLocation, isSsubScriptionView: false);
        Helper.shared.setupViewLayer(sender: self.viewUnitPreference, isSsubScriptionView: false);
        Helper.shared.setupViewLayer(sender: self.viewPoolLength, isSsubScriptionView: false);
    }
    
    func setupUserInfo(){
        user = PreferenceManager.shared.user
        
        self.lblUserName.text = user.name
        self.imageView.image = UIImage(named: "icon_default")
        if !user.profilePic.isEmpty{
            self.imageView.sd_setImage(with: URL(string: user.profilePic.getImageURL()), placeholderImage: UIImage(named: "icon_default"), options: .refreshCached, completed: nil)
        }
        
        self.txtFName.text = user.fName
        self.txtLName.text = user.lName
        self.txtUName.text = user.name
        self.txtGender.text = user.gender
        self.txtLocation.text = user.location
        
        if !user.tSerialNumber.isEmpty{
            if user.tSerialNumber.count >= 2{
                let tPrefix = user.tSerialNumber.prefix(upTo: user.tSerialNumber.index(user.tSerialNumber.startIndex, offsetBy: 2))
                if tPrefix == "RA"{
                    let tStr = user.tSerialNumber.replacingOccurrences(of: "RA", with: "")
                    if tStr.count > 7{
                        self.txtTSerialNumber.text = String(tStr.dropFirst())
                    }else{
                        self.txtTSerialNumber.text = tStr
                    }
                }else{
                    self.txtTSerialNumber.text = String(user.tSerialNumber.dropFirst())
                }
            }else{
                self.txtTSerialNumber.text = String(user.tSerialNumber.dropFirst())
            }
        }
        
        
        if !user.hSerialNumber.isEmpty{
            if user.hSerialNumber.count >= 2{
                let hPrefix = user.hSerialNumber.prefix(upTo: user.hSerialNumber.index(user.hSerialNumber.startIndex, offsetBy: 2))
                if hPrefix == "RA"{
                    let hStr = user.hSerialNumber.replacingOccurrences(of: "HA", with: "")
                    if hStr.count > 7{
                        self.txtHSerialNumber.text = String(hStr.dropFirst())
                    }
                }else{
                    self.txtHSerialNumber.text = String(user.hSerialNumber.dropFirst())
                }
            }else{
                self.txtHSerialNumber.text = String(user.hSerialNumber.dropFirst())
            }
        }
        
        
        let tempUB = user.birthday
        if let dob = tempUB.fromServerBirthday(){
            self.datePicker.date = dob
            self.txtBirthday.text = dob.toDisplayBirthday()
        }
        
        let poolUnitInfo = PreferenceManager.shared.poolUnitInfo
        self.txtUnit.text = poolUnitInfo.unitPref.rawValue
        if poolUnitInfo.defaultPoolLength == .custom{
            if poolUnitInfo.customPoolDistance.remainder(dividingBy: 1) > 0{
                self.txtPoolLength.text = "\(poolUnitInfo.customPoolDistance) \(poolUnitInfo.customPoolLengthUnits.rawValue.lowercased())"
            }else{
                self.txtPoolLength.text = "\(Int(poolUnitInfo.customPoolDistance)) \(poolUnitInfo.customPoolLengthUnits.rawValue.lowercased())"
            }
            
        }else{
            self.txtPoolLength.text = poolUnitInfo.defaultPoolLength.rawValue.firstUppercased
        }
        
        
        
        if let selectedIndex = self.viewModel.arrPoolType.firstIndex(where: { $0 == poolUnitInfo.defaultPoolLength }){
            self.poolLengthPicker.selectRow(selectedIndex, inComponent: 0, animated: false)
        }
        
        self.viewModel.profileItemPoolUnitInfo.customPoolDistance = poolUnitInfo.customPoolDistance
        self.viewModel.profileItemPoolUnitInfo.customPoolLengthUnits = poolUnitInfo.customPoolLengthUnits
        self.viewModel.profileItemPoolUnitInfo.defaultPoolLength = poolUnitInfo.defaultPoolLength
        self.viewModel.profileItemPoolUnitInfo.unitPref = poolUnitInfo.unitPref
        
        self.viewModel.profileItem.email = user.email
        self.viewModel.profileItem.name = user.name
        self.viewModel.profileItem.fname = user.fName
        self.viewModel.profileItem.lname = user.lName
        self.viewModel.profileItem.gender = user.gender
        self.viewModel.profileItem.birthday = datePicker.date.toServerBirthday().trim()
        self.viewModel.profileItem.location = user.location
        self.viewModel.profileItem.tSerialNumber = user.tSerialNumber
        self.viewModel.profileItem.hSerialNumber = user.hSerialNumber
    }
    
    func setupPicker(){
        datePicker.maximumDate = DateHelper.shared.currentLocalDateTime
        
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        txtBirthday.inputView = datePicker
        txtBirthday.delegate = self
        
        genderPicker.delegate = self
        genderPicker.dataSource = self
        txtGender.inputView = genderPicker
        txtGender.delegate = self
        
        unitPicker.dataSource = self
        unitPicker.delegate = self
        txtUnit.inputView = unitPicker
        txtUnit.delegate = self
        
        poolLengthPicker.dataSource = self
        poolLengthPicker.delegate = self
        txtPoolLength.inputView = poolLengthPicker
        txtPoolLength.delegate = self
    }
    
    func alertForCustomGender(){
        
        let alert = UIAlertController(title: nil, message: "", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = ""
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.txtGender.text = self.user.gender
            self.viewModel.profileItem.gender = self.txtGender.text!.trim()
        }
        
        let doneAction = UIAlertAction(title: "Done", style: .default) { (action) in
            guard let txtAGender = alert.textFields?.first else{
                return
            }
            
            let nGender = txtAGender.text!.trim()
            if nGender.isEmpty{
                Helper.shared.alert(title: Constants.appName, message: "Please enter your gender.") {
                    self.alertForCustomGender()
                }
            }else{
                self.txtGender.text = nGender
                self.viewModel.profileItem.gender = self.txtGender.text!.trim()
            }
        }
        
        alert.addAction(cancelAction)
        alert.addAction(doneAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - UIButton Actions
    @IBAction func logOutAction(_ sender: UIButton){
        Helper.shared.logout()
    }
    
    @IBAction func doneAction(_ sender: UIButton){
        
        self.txtFName.resignFirstResponder()
        self.txtLName.resignFirstResponder()
        self.txtUName.resignFirstResponder()
        self.txtGender.resignFirstResponder()
        self.txtBirthday.resignFirstResponder()
        self.txtLocation.resignFirstResponder()
        self.txtHSerialNumber.resignFirstResponder()
        self.txtTSerialNumber.resignFirstResponder()
        
        self.viewModel.profileItem.email = user.email
        self.viewModel.profileItem.name = txtUName.text!.trim()
        self.viewModel.profileItem.fname = txtFName.text!.trim()
        self.viewModel.profileItem.lname = txtLName.text!.trim()
        self.viewModel.profileItem.gender = txtGender.text!.trim()
        self.viewModel.profileItem.birthday = datePicker.date.toServerBirthday().trim()
        self.viewModel.profileItem.location = txtLocation.text!.trim()
        
        if !txtHSerialNumber.text!.trim().isEmpty{
            self.viewModel.profileItem.hSerialNumber = "H" + txtHSerialNumber.text!.trim()
        }else{
            self.viewModel.profileItem.hSerialNumber = ""
        }
        
        if !txtTSerialNumber.text!.trim().isEmpty{
            self.viewModel.profileItem.tSerialNumber = "R" + txtTSerialNumber.text!.trim()
        }else{
            self.viewModel.profileItem.tSerialNumber = ""
        }
        
        if self.viewModel.isInfoValidate(){
            delegate?.didPressSave()
        }
    }
    
    @IBAction func trasmitterInfo(){
        
        let alert = CustomAlertVC(nibName: "CustomAlertVC", bundle: nil, title: "Transmitter Serial Number", message: "Located on the back of the transmitter.") { (isComplete) in
        }
        
        alert.transitioningDelegate = self
        alert.modalPresentationStyle = .custom
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func headsetInfo(){
        
        let alert = CustomAlertVC(nibName: "CustomAlertVC", bundle: nil, title: "Headset Serial Number", message: "Located on the inner left side of the headset.") { (isComplete) in
            
    
        }
        
        alert.transitioningDelegate = self
        alert.modalPresentationStyle = .custom
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    @IBAction func chooseImageAction(_ sender: UIButton){
        self.imageOptionsAlert()
    }
}

extension InfoViewController: UIViewControllerTransitioningDelegate{
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentingAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissingAnimator()
    }
    
}

extension InfoViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == unitPicker{
            return self.viewModel.arrUnits.count
        }
        
        if pickerView == poolLengthPicker{
            return self.viewModel.arrPoolType.count
        }
        
        return self.viewModel.arrGender.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == unitPicker{
            return self.viewModel.arrUnits[row].rawValue
        }
        
        if pickerView == poolLengthPicker{
            return self.viewModel.arrPoolType[row].rawValue.firstUppercased
        }
        
        return self.viewModel.arrGender[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == unitPicker{
            self.txtUnit.text = self.viewModel.arrUnits[row].rawValue
            return
        }
        
        if pickerView == poolLengthPicker{
            //self.txtPoolLength.text = self.viewModel.arrPoolType[row].rawValue
            return
        }
        
        self.txtGender.text = self.viewModel.arrGender[row].rawValue
        self.viewModel.profileItem.gender = txtGender.text!.trim()
    }
}


extension InfoViewController: UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == txtTSerialNumber{
            if textField.text!.trim().isEmpty{
                //txtTSerialNumber.text = "RA"
            }
        }else if textField == txtHSerialNumber{
            if textField.text!.trim().isEmpty{
                //txtHSerialNumber.text = "HA"
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == txtBirthday{
            self.txtBirthday.text = datePicker.date.toDisplayBirthday()
            self.viewModel.profileItem.birthday = datePicker.date.toServerBirthday().trim()
        }
        
        if textField == txtGender{
            let gender = self.viewModel.arrGender[genderPicker.selectedRow(inComponent: 0)]
            if gender == .type{
                self.txtGender.text = ""
                self.alertForCustomGender()
            }else{
                self.txtGender.text = gender.rawValue
                self.viewModel.profileItem.gender = txtGender.text!.trim()
            }
        }
        
        if textField == txtUnit{
            let unit = self.viewModel.arrUnits[unitPicker.selectedRow(inComponent: 0)]
            self.viewModel.profileItemPoolUnitInfo.unitPref = unit
            self.txtUnit.text = unit.rawValue
        }
        
        if textField == txtPoolLength{
            let type = self.viewModel.arrPoolType[poolLengthPicker.selectedRow(inComponent: 0)]
            if type == .custom{
                //Show Custom pool length popup
                
                let customPoolLength = CustomPoolLengthPopup(nibName: "CustomPoolLengthPopup", bundle: nil)
                customPoolLength.transitioningDelegate = self
                customPoolLength.modalPresentationStyle = .custom
                customPoolLength.onSave = { distance, poolUnit in
                    self.viewModel.profileItemPoolUnitInfo.defaultPoolLength = type
                    self.viewModel.profileItemPoolUnitInfo.customPoolDistance = distance
                    self.viewModel.profileItemPoolUnitInfo.customPoolLengthUnits = poolUnit
                    if distance.remainder(dividingBy: 1) > 0{
                        self.txtPoolLength.text = "\(distance) \(poolUnit.rawValue.lowercased())"
                    }else{
                        self.txtPoolLength.text = "\(Int(distance)) \(poolUnit.rawValue.lowercased())"
                    }
                    
                }
                
                self.present(customPoolLength, animated: true, completion: nil)
            }else{
                self.viewModel.profileItemPoolUnitInfo.defaultPoolLength = type
                self.txtPoolLength.text = type.rawValue.firstUppercased
            }
        }
        
        if textField == txtTSerialNumber{
            if self.viewModel.profileItem.tSerialNumber.trim() == "R"{
                txtTSerialNumber.text = ""
                self.viewModel.profileItem.tSerialNumber = ""
            }
        }else if textField == txtHSerialNumber{
            if self.viewModel.profileItem.hSerialNumber.trim() == "H"{
                txtHSerialNumber.text = ""
                self.viewModel.profileItem.hSerialNumber = ""
            }
        }
    }
    
    @objc func textDidChange(_ textField: UITextField){
        if textField == txtUName{
            
            var fullText = textField.text!
            fullText = fullText.replacingOccurrences(of: " ", with: "")
            
            txtUName.text = fullText
            self.viewModel.profileItem.name = txtUName.text!.trim()
        }else if textField == txtUName{
            self.viewModel.profileItem.name = txtUName.text!.trim()
        }else if textField == txtFName{
            self.viewModel.profileItem.fname = txtFName.text!.trim()
        }else if textField == txtLName{
            self.viewModel.profileItem.lname = txtLName.text!.trim()
        }else if textField == txtGender{
            self.viewModel.profileItem.gender = txtGender.text!.trim()
        }else if textField == txtBirthday{
            self.viewModel.profileItem.birthday = datePicker.date.toServerBirthday().trim()
        }else if textField == txtLocation{
            self.viewModel.profileItem.location = txtLocation.text!.trim()
        }else if textField == txtHSerialNumber{
            /*var hStr = txtHSerialNumber.text!.trim()
            if !hStr.contains("H"){
                hStr = hStr.replacingOccurrences(of: "H", with: "")
                let newString = "H" + hStr
                
                hStr = newString
            }
            //txtHSerialNumber.text = hStr
            self.viewModel.profileItem.hSerialNumber = hStr*///txtHSerialNumber.text!.trim()
        }else if textField == txtTSerialNumber{
            
           /* var hStr = txtTSerialNumber.text!.trim()
            if !hStr.contains("R"){
                hStr = hStr.replacingOccurrences(of: "R", with: "")
                let newString = "R" + hStr
                
                hStr = newString
            }
            /*txtTSerialNumber.text = hStr*/
            
            self.viewModel.profileItem.tSerialNumber = hStr*///txtTSerialNumber.text!.trim()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == txtUName{
            let inValidCharacterSet = NSCharacterSet.whitespaces
            guard let firstChar = string.unicodeScalars.first else {return true}
            return !(inValidCharacterSet as NSCharacterSet).isCharInSet(char: Character(firstChar))
        }else if textField == txtHSerialNumber{
            if string == " "{
                return false
            }
            
            let cs = NSCharacterSet(charactersIn: Constants.ACCEPTABLE_CHARACTERS).inverted
            let filtered = string.components(separatedBy: cs).joined(separator: "")
            
            let fullText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            return fullText.count <= 8 && (string == filtered)
        }else if textField == txtTSerialNumber{
            
            if string == " "{
                return false
            }
            
            let cs = NSCharacterSet(charactersIn: Constants.ACCEPTABLE_CHARACTERS).inverted
            let filtered = string.components(separatedBy: cs).joined(separator: "")
            
            let fullText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            return fullText.count <= 8 && (string == filtered)
        }
        
        return true
    }
    
}


extension InfoViewController : IndicatorInfoProvider{
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}

//MARK: - Image Picker
extension InfoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
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
    
}
