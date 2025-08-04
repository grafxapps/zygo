//
//  RenameBluetoothIDVC.swift
//  Zygo
//
//  Created by Som Parkash on 29/09/24.
//  Copyright © 2024 Somparkash. All rights reserved.
//

import UIKit

class RenameBluetoothIDVC: UIViewController {

    @IBOutlet weak var currentBTNameLabel: UILabel!
    @IBOutlet weak var updatedBTNameLabel: UILabel!
    @IBOutlet weak var btNameTextFiled: UITextField!
    @IBOutlet weak var btNameTextFiledContentView: UIView!
    @IBOutlet weak var renameButton: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var errorMessagelabel: UILabel!
    @IBOutlet weak var successView: UIView!
    
    private let model = RenameBluetoothIDVM()
    
    var onBTNameUpdate: ((String) -> Void)? = nil
    
    //MARK: - UIViewcontroller LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    //MARK: - Setups
    func setupUI(){
        self.btNameTextFiled.delegate = self
        self.btNameTextFiledContentView.layer.borderWidth = 1.0
        self.btNameTextFiledContentView.layer.borderColor = Asset.Colors.appDisableGrayColor.color.cgColor
        
        let user = PreferenceManager.shared.user
        self.currentBTNameLabel.text = user.btName
        self.checkZygoConnectStatus()
        BluetoothManager.shared.onDeviceDisconnect = { [weak self] in
            DispatchQueue.main.async{
                self?.checkZygoConnectStatus()
            }
        }
    }
    
    private func checkZygoConnectStatus(){
        if BluetoothManager.shared.isZygoDeviceConencted(){
            DispatchQueue.main.async{
                self.readBTCurrentName()
            }
            self.updateZygoConnectedView()
        }else{
            BLEConnectionManager.shared.stopScanning()
            self.updateZygoConnectingView()
            BLEConnectionManager.shared.startAutoConnectScanning { [weak self] in
                self?.updateZygoConnectedView()
                DispatchQueue.main.async{
                    self?.readBTCurrentName()
                }
            }
        }
    }
    
    private func readBTCurrentName(){
        //Read device name and update it on server
        BluetoothManager.shared.readBTName { [weak self] name in
            DispatchQueue.main.async{
                print("BT Name: \(name)")
                self?.currentBTNameLabel.text = name
                PreferenceManager.shared.user.btName = name
            }
        }
    }
    
    private func updateZygoConnectingView(){
        self.errorMessagelabel.text = "Make sure your case is on and close by."
        self.renameButton.setTitle("CONNECTING", for: .normal)
        self.renameButton.isUserInteractionEnabled = false
        self.loadingIndicator.isHidden = false
        self.loadingIndicator.startAnimating()
    }
    
    private func updateZygoConnectedView(){
        self.errorMessagelabel.text = ""
        self.renameButton.isUserInteractionEnabled = true
        self.renameButton.setTitle("RENAME", for: .normal)
        self.loadingIndicator.isHidden = true
    }
    
    private func isValidKeyboardString(_ input: String) -> Bool {
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()-_=+[]{}|;’:'\",.<>?/\\`~ ")
        return input.rangeOfCharacter(from: allowedCharacters.inverted) == nil
    }
    
    //MARK: - UIButton Actions
    @IBAction private func renameButtonPressed(_ sender: UIButton){
        let btNameInput = self.btNameTextFiled.text!.trim()
        let btName = btNameInput.replacingOccurrences(of: "’", with: "'")
        if btName.isEmpty{
            Helper.shared.alert(title: Constants.appName, message: "Please enter your Zygo’s name and it should only include regular keyboard characters and can’t have leading or trailing spaces.")
            return
        }
        
        if !isValidKeyboardString(btName){
            Helper.shared.alert(title: Constants.appName, message: "Your Zygo’s name can only include regular keyboard characters and can’t have leading or trailing spaces.")
            return
        }
        
        self.loadingIndicator.isHidden = false
        self.loadingIndicator.startAnimating()
        self.renameButton.isUserInteractionEnabled = false
        self.renameButton.setTitle("RENAMING", for: .normal)
        BluetoothManager.shared.updateBTName(name: btName) { [weak self] isUpdate in
            DispatchQueue.main.async {
                if isUpdate{
                    print("BTName Update Success")
                    PreferenceManager.shared.user.btName = btName
                    self?.model.updateBTName(name: btName) {
                        DispatchQueue.main.async{
                            self?.onBTNameUpdate?(btName)
                            self?.updatedBTNameLabel.text = btName
                            self?.successView.isHidden = false
                        }
                    }
                }else{
                    print("BTName Update Failed")
                    self?.errorMessagelabel.text = "Connection error. Try again."
                    self?.renameButton.isUserInteractionEnabled = true
                    self?.loadingIndicator.isHidden = true
                    self?.renameButton.setTitle("RENAME", for: .normal)
                }
            }
        }
        
    }
    
    @IBAction private func closeButtonAction(_ sender: UIButton){
        self.dismiss(animated: true)
    }
    
    //MARK: -
}

//MARK: - UITextField Delegates
extension RenameBluetoothIDVC: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let fullText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        return fullText.count <= 20
    }
}
