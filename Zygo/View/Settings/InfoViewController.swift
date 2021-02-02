//
//  InfoViewController.swift
//  Zygo
//
//  Created by Priya Gandhi on 31/01/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class InfoViewController: UIViewController {
    var itemInfo = IndicatorInfo(title: "Info")
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
    private lazy var viewModel = CreateProfileViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //MARK: - Setups
    func setupUI()  {
        
        Helper.shared.setupViewLayer(sender: self.viewFName, isSsubScriptionView: false);
        Helper.shared.setupViewLayer(sender: self.viewLName, isSsubScriptionView: false);
        Helper.shared.setupViewLayer(sender: self.viewUName, isSsubScriptionView: false);
        Helper.shared.setupViewLayer(sender: self.viewGender, isSsubScriptionView: false);
        Helper.shared.setupViewLayer(sender: self.viewBirthday, isSsubScriptionView: false);
        Helper.shared.setupViewLayer(sender: self.viewLocation, isSsubScriptionView: false);
    }
    
    func setupUserInfo(){
        
        self.txtFName.text = user.fName
        self.txtLName.text = user.lName
        self.txtUName.text = user.name
        self.txtGender.text = user.gender
        self.txtLocation.text = user.location
        self.txtBirthday.text = user.birthday
    }
    func setupPicker(){
        datePicker.maximumDate = Date()
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
        
        let alert = UIAlertController(title: nil, message: "Please enter your gender.", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Ex: Male/Female"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
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
           self.viewModel.profileItem.name = txtUName.text!.trim()
           self.viewModel.profileItem.fname = txtFName.text!.trim()
           self.viewModel.profileItem.lname = txtLName.text!.trim()
           self.viewModel.profileItem.gender = txtGender.text!.trim()
           self.viewModel.profileItem.birthday = txtBirthday.text!.trim()
           self.viewModel.profileItem.location = txtLocation.text!.trim()
           
           if self.viewModel.isValidate(){
               self.viewModel.createProfile { [weak self] (isCreate) in
                   
                   if isCreate{
                       //Update User
                       self?.user.name = self?.viewModel.profileItem.name ?? ""
                       self?.user.fName = self?.viewModel.profileItem.fname ?? ""
                       self?.user.lName = self?.viewModel.profileItem.lname ?? ""
                       self?.user.gender = self?.viewModel.profileItem.gender ?? ""
                       self?.user.birthday = self?.viewModel.profileItem.birthday ?? ""
                       self?.user.location = self?.viewModel.profileItem.location ?? ""
                       if let nUser = self?.user{
                           PreferenceManager.shared.user = nUser
                       }
                       
                       Helper.shared.setDashboardRoot()
                   }
               }
               
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
       }
   }


   extension InfoViewController: UITextFieldDelegate{
       func textFieldDidEndEditing(_ textField: UITextField) {
           if textField == txtBirthday{
               self.txtBirthday.text = datePicker.date.toServerBirthday()
           }
           
           if textField == txtGender{
               let gender = self.viewModel.arrGender[genderPicker.selectedRow(inComponent: 0)]
               if gender == .type{
                   self.txtGender.text = ""
                   self.alertForCustomGender()
               }else{
                   self.txtGender.text = gender.rawValue
               }
           }
       }
       
   }


extension InfoViewController : IndicatorInfoProvider{
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}
