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
    
    @IBOutlet weak var viewFName: UIView!
    @IBOutlet weak var viewLName: UIView!
    @IBOutlet weak var viewUName: UIView!
    @IBOutlet weak var viewGender: UIView!
    @IBOutlet weak var viewBirthday: UIView!
    @IBOutlet weak var viewLocation: UIView!
    
    @IBOutlet weak var txtFName: UITextField!
    @IBOutlet weak var txtLName: UITextField!
    @IBOutlet weak var txtUName: UITextField!
    @IBOutlet weak var txtGender: UITextField!
    @IBOutlet weak var txtBirthday: UITextField!
    @IBOutlet weak var txtLocation: UITextField!
    
    private lazy var datePicker = UIDatePicker()
    private lazy var genderPicker = UIPickerView()
    private lazy var user = PreferenceManager.shared.user
    var viewModel: CreateProfileViewModel!
    
    var superObj: ProfileViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.setupUserInfo()
        self.setupPicker()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.superObj.showChooseImage()
    }
    
    //MARK: - Setups
    func setupUI()  {
        
        txtFName.addTarget(self, action: #selector(self.textDidChange(_:)), for: .editingChanged)
        txtLName.addTarget(self, action: #selector(self.textDidChange(_:)), for: .editingChanged)
        txtUName.addTarget(self, action: #selector(self.textDidChange(_:)), for: .editingChanged)
        txtGender.addTarget(self, action: #selector(self.textDidChange(_:)), for: .editingChanged)
        txtBirthday.addTarget(self, action: #selector(self.textDidChange(_:)), for: .editingChanged)
        txtLocation.addTarget(self, action: #selector(self.textDidChange(_:)), for: .editingChanged)
        
        Helper.shared.setupViewLayer(sender: self.viewFName, isSsubScriptionView: false);
        Helper.shared.setupViewLayer(sender: self.viewLName, isSsubScriptionView: false);
        Helper.shared.setupViewLayer(sender: self.viewUName, isSsubScriptionView: false);
        Helper.shared.setupViewLayer(sender: self.viewGender, isSsubScriptionView: false);
        Helper.shared.setupViewLayer(sender: self.viewBirthday, isSsubScriptionView: false);
        Helper.shared.setupViewLayer(sender: self.viewLocation, isSsubScriptionView: false);
    }
    
    func setupUserInfo(){
        user = PreferenceManager.shared.user
        self.txtFName.text = user.fName
        self.txtLName.text = user.lName
        self.txtUName.text = user.name
        self.txtGender.text = user.gender
        self.txtLocation.text = user.location
        
        let tempUB = user.birthday
        if let dob = tempUB.fromServerBirthday(){
            self.datePicker.date = dob
            self.txtBirthday.text = dob.toDisplayBirthday()
        }
        
        self.viewModel.profileItem.email = user.email
        self.viewModel.profileItem.name = user.name
        self.viewModel.profileItem.fname = user.fName
        self.viewModel.profileItem.lname = user.lName
        self.viewModel.profileItem.gender = user.gender
        self.viewModel.profileItem.birthday = datePicker.date.toServerBirthday().trim()
        self.viewModel.profileItem.location = user.location
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
    
    @IBAction func logOutAction(_ sender: UIButton){
        Helper.shared.logout()
    }
    
    @IBAction func doneAction(_ sender: UIButton){
        self.viewModel.profileItem.email = user.email
        self.viewModel.profileItem.name = txtUName.text!.trim()
        self.viewModel.profileItem.fname = txtFName.text!.trim()
        self.viewModel.profileItem.lname = txtLName.text!.trim()
        self.viewModel.profileItem.gender = txtGender.text!.trim()
        self.viewModel.profileItem.birthday = datePicker.date.toServerBirthday().trim()
        self.viewModel.profileItem.location = txtLocation.text!.trim()
        
        if self.viewModel.isValidate(){
            delegate?.didPressSave()
        }
    }
    
}

extension InfoViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.viewModel.arrGender.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.viewModel.arrGender[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.txtGender.text = self.viewModel.arrGender[row].rawValue
        self.viewModel.profileItem.gender = txtGender.text!.trim()
    }
}


extension InfoViewController: UITextFieldDelegate{
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
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == txtUName{
            let inValidCharacterSet = NSCharacterSet.whitespaces
            guard let firstChar = string.unicodeScalars.first else {return true}
            return !(inValidCharacterSet as NSCharacterSet).isCharInSet(char: Character(firstChar))
        }
        
        return true
    }
    
}


extension InfoViewController : IndicatorInfoProvider{
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}
