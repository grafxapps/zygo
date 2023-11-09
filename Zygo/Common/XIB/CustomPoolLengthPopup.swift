//
//  CustomPoolLengthPopup.swift
//  Zygo
//
//  Created by Som on 05/03/22.
//  Copyright © 2022 Somparkash. All rights reserved.
//

import UIKit

//MARK: -
class CustomPoolLengthPopup: UIViewController {
    
    @IBOutlet weak var txtDistance: UITextField!
    @IBOutlet weak var txtUnits: UITextField!
    @IBOutlet weak var btnSave: UIButton!
    
    private let arrPoolLengthUnits: [PoolLengthUnit] = [.meters, .feet, .yards]
    private var unitsPicket = UIPickerView()
    private var selectedUnit: PoolLengthUnit = .feet
    
    var onSave: ((Double, PoolLengthUnit) -> Void)?

    //MARK: - UIViewcontroller LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }

    //MARK: - Setups
    func setupUI(){
        self.btnSave.layer.cornerRadius = 10.0
        self.btnSave.layer.masksToBounds = true
        
        unitsPicket.dataSource = self
        unitsPicket.delegate = self
        txtUnits.inputView = unitsPicket
        
        let poolInfo = PreferenceManager.shared.poolUnitInfo
        
        if poolInfo.customPoolDistance > 0{
            self.txtDistance.text = "\(Int(poolInfo.customPoolDistance))"
        }
        
        self.txtUnits.text = poolInfo.customPoolLengthUnits.rawValue.capitalized
        if let selectedIndex = self.arrPoolLengthUnits.firstIndex(where: { $0 == poolInfo.customPoolLengthUnits }){
            self.selectedUnit = self.arrPoolLengthUnits[selectedIndex]
            unitsPicket.selectRow(selectedIndex, inComponent: 0, animated: false)
        }
        
        //txtDistance.delegate = self
    }
    
    //MARK: - UIButton Actions
    @IBAction func poolLengthUnitsAction(_ sender: UIButton){
        self.txtUnits.becomeFirstResponder()
    }
    
    @IBAction func saveAction(_ sender: UIButton){
        let distance = Double(txtDistance.text!.trim()) ?? 0
        if distance <= 0{
            Helper.shared.alert(title: Constants.appName, message: "Please enter distance.")
            return
        }
        
        self.dismiss(animated: true) {
            self.onSave?(distance, self.selectedUnit)
        }
        
    }
    
    @IBAction func backAction(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: -
}

//MARK: - UIPickerView DataSources and Delegates
extension CustomPoolLengthPopup: UIPickerViewDataSource, UIPickerViewDelegate{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.arrPoolLengthUnits.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.arrPoolLengthUnits[row].rawValue.capitalized
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.txtUnits.text = self.arrPoolLengthUnits[row].rawValue.capitalized
        self.selectedUnit = self.arrPoolLengthUnits[row]
    }
}
