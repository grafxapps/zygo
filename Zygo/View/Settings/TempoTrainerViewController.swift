//
//  TempoTrainerViewController.swift
//  Zygo
//
//  Created by Priya Gandhi on 10/02/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class TempoTrainerViewController: UIViewController {
    
    @IBOutlet weak var viewStrokes : UIView!
    @IBOutlet weak var viewSeconds : UIView!
    @IBOutlet weak var viewSlider : UIView!
    
    @IBOutlet weak var placeholderToolBar : UIView!
    @IBOutlet weak var lblToolBarPlaceholder : UILabel!
    
    @IBOutlet weak var btnDrop : UIButton!
    @IBOutlet weak var viewDrop : UIView!
    
    @IBOutlet weak var btnDing : UIButton!
    @IBOutlet weak var viewDing : UIView!
    
    @IBOutlet weak var btnBeep : UIButton!
    @IBOutlet weak var viewBeep : UIView!
    
    @IBOutlet weak var btnStart : UIButton!
    
    @IBOutlet weak var viewLap : UIView!
    
    @IBOutlet weak var lblStrokeRate : UILabel!
    @IBOutlet weak var lblStrokeSubTitle : UILabel!
    @IBOutlet weak var viewStroke : UIView!
    
    @IBOutlet weak var lblLap : UILabel!
    @IBOutlet weak var lblLabSubTitle : UILabel!
    
    @IBOutlet weak var txtStroke : UITextField!
    
    @IBOutlet weak var txtSeconds : UITextField!
    
    private var previousStrokeText: String = ""
    private var previousSecondsText: String = ""
    
    private var soundDuration: Double = 0.1//By Default
    private var maximumStrokeRate: Int = 120
    private var minimumSecondsPerLap: Double = 5
    private var maximumSecondsPerLap: Double = 999
    private var trainer: TempoTrainerManager.TemoTrainer = TempoTrainerManager.TemoTrainer([:])
    private var lightColor = UIColor(displayP3Red: 209.0/255.0, green: 209.0/255.0 , blue: 209.0/255.0, alpha: 1.0)
    
    //MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewStrokes.setupShadowViewAnimation(shadowRadius: 4.0, shadowOpacity: 0.5, shadowOffset: CGSize(width: 0, height: 4.0))
        self.viewSeconds.setupShadowViewAnimation(shadowRadius: 4.0, shadowOpacity: 0.5, shadowOffset: CGSize(width: 0, height: 4.0))
        
        self.viewDrop.setupShadowViewAnimation(shadowRadius: 4.0, shadowOpacity: 0.5, shadowOffset: CGSize(width: 0, height: 4.0))
        self.viewDing.setupShadowViewAnimation(shadowRadius: 4.0, shadowOpacity: 0.5, shadowOffset: CGSize(width: 0, height: 4.0))
        self.viewBeep.setupShadowViewAnimation(shadowRadius: 4.0, shadowOpacity: 0.5, shadowOffset: CGSize(width: 0, height: 4.0))
        
        self.txtStroke.inputAccessoryView = placeholderToolBar
        self.txtSeconds.inputAccessoryView = placeholderToolBar
        
        self.txtStroke.attributedPlaceholder = NSAttributedString(string: "00",
                                                                  attributes: [NSAttributedString.Key.foregroundColor: lightColor])
        
        self.txtSeconds.attributedPlaceholder = NSAttributedString(string: "00",
                                                                  attributes: [NSAttributedString.Key.foregroundColor: lightColor])
        
        self.viewDing.hideShadow()
        self.viewBeep.hideShadow()
        
        self.setupBtnLayout(sender: btnDing);
        self.setupBtnLayout(sender: btnBeep);
        self.setupSelectedBtnLayout(sender: btnDrop);
        self.setupSoundDuration()
        self.disableBtnStart()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addObservers()
        UITextField.appearance().tintColor = UIColor.white
        self.setupExistingTrainerData()
        IQKeyboardManager.shared.enable = false
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeObservers()
        UITextField.appearance().tintColor = UIColor.appBlueColor()
        IQKeyboardManager.shared.enable = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateExitingData()
    }
    
    //MARK:- Setup
    func removeObservers(){
        NotificationCenter.default.removeObserver(self)
    }
    
    func addObservers(){
        self.removeObservers()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIApplication.keyboardDidShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIApplication.keyboardDidHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(){
        //self.showPlaceHolder("Stroke Rate", ScreenSize.SCREEN_HEIGHT - )
    }
    
    @objc func keyboardWillHide(){
        
    }
    
    func showPlaceHolder(_ text: String, _ y: CGFloat){
        let label = UILabel(frame: CGRect(x: 100, y: y, width: ScreenSize.SCREEN_WIDTH - 200.0, height: 50.0))
        label.text = text
        self.view.addSubview(label)
    }
    
    func updateExitingData(){
        guard let existing = TempoTrainerManager.shared.currentTrainer else {
            return
        }
        
        self.trainer = existing
        switch self.trainer.type{
        case .strokeRate:
            self.StrokeRateAction(sender: UIButton())
        case .lapInterval:
            self.lapIntervalAction(sender: UIButton())
        }
        
        self.txtSeconds.text = "\(self.trainer.secondsPerLap)"
        self.txtStroke.text = "\(self.trainer.strokesPerMinute)"
    }
    
    func setupExistingTrainerData(){
        var isAlreadyStarted: Bool = false
        if TempoTrainerManager.shared.currentTrainer != nil{
            isAlreadyStarted = true
        }
        TempoTrainerManager.shared.currentTrainer = PreferenceManager.shared.tempoTrainer
        
        guard let existing = TempoTrainerManager.shared.currentTrainer else {
            return
        }
        
        self.trainer = existing
        switch self.trainer.type{
        case .strokeRate:
            self.StrokeRateAction(sender: UIButton())
        case .lapInterval:
            self.lapIntervalAction(sender: UIButton())
        }
        
        self.txtStroke.text = "\(self.trainer.strokesPerMinute)"
        self.txtSeconds.text = "\(self.trainer.secondsPerLap)"
        
        self.updateSoundButtonLayout(type: self.trainer.soundType)
        self.enableBtnStart()
        
        if isAlreadyStarted{
            
            if AppDelegate.app.tempoPlayer != nil{
                if AppDelegate.app.tempoPlayer?.isPlaying ?? false{
                //if AppDelegate.app.tempoPlayer?.rate ?? 0 > 0 {
                    self.btnStart.isSelected = true
                }
            }
        }
        
    }
    
    private func setupBtnLayout (sender : UIButton){
        sender.layer.borderWidth = 2
        sender.layer.borderColor = UIColor.appBlueColor().cgColor
        sender.backgroundColor = UIColor.white
        sender.setTitleColor(.appBlueColor(), for: .normal)
        sender.layer.masksToBounds = true
    }
    private func setupSelectedBtnLayout (sender : UIButton){
        sender.backgroundColor = UIColor.appBlueColor()
        sender.setTitleColor(.white, for: .normal)
        sender.layer.masksToBounds = true;
    }
    
    func enableStrokeRate(){
        
        trainer.type = .strokeRate
        
        self.lblStrokeRate.textColor = .appBlueColor()
        self.viewStrokes.backgroundColor = .appBlueColor()
        self.txtStroke.textColor = .white
        self.lblStrokeSubTitle.textColor = .appBlueColor()
    }
    
    func disableStrokeRate(){
        self.lblStrokeRate.textColor = lightColor
        self.viewStrokes.backgroundColor = .white
        self.txtStroke.textColor = lightColor
        self.lblStrokeSubTitle.textColor = lightColor
    }
    
    func enableLapInterval(){
        self.lblLap.textColor = .appBlueColor()
        self.viewSeconds.backgroundColor = .appBlueColor()
        self.txtSeconds.textColor = .white
        self.lblLabSubTitle.textColor = .appBlueColor()
        
        trainer.type = .lapInterval
    }
    
    func disableLapInterval(){
        self.lblLap.textColor = lightColor
        self.viewSeconds.backgroundColor = .white
        self.txtSeconds.textColor = lightColor
        self.lblLabSubTitle.textColor = lightColor
    }
    
    func enableBtnStart(){
        self.btnStart.alpha = 1.0
        self.btnStart.isUserInteractionEnabled = true
    }
    
    func disableBtnStart(){
        self.btnStart.alpha = 0.5
        self.btnStart.isUserInteractionEnabled = false
    }
    
    func setupSoundDuration(){
        //self.soundDuration = TempoTrainerManager.shared.getSoundDuration(trainer.soundType)
        self.maximumStrokeRate = 120
        
        /*self.maximumStrokeRate = Int(60.0/self.soundDuration)
        if self.maximumStrokeRate > 150{
            self.maximumStrokeRate = 150
        }*/
    }
    
    func checkLapIntervalMinimumValue(){
        if self.trainer.type == .lapInterval{
            if txtSeconds.text!.trim().isEmpty{
                return
            }
            
            let seconds = Int(txtSeconds.text!) ?? 0
            if seconds < Int(self.minimumSecondsPerLap){
                txtSeconds.text = "\(Int(self.minimumSecondsPerLap))"
            }else if seconds > Int(self.maximumSecondsPerLap){
                txtSeconds.text = "\(Int(self.maximumSecondsPerLap))"
            }
        }
        
    }
    
    func checkStrokeMaximumValue(){
        if self.trainer.type == .strokeRate{
            let stroke = Int(txtStroke.text!) ?? 0
            if stroke > self.maximumStrokeRate{
                txtStroke.text = "\(self.maximumStrokeRate)"
            }
        }
    }
    
    //MARK:- UIButton Actions
    @IBAction func backAction(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func toolbarDoneAction(_ sender: UIButton){
        if txtSeconds.isEditing{
            txtSeconds.resignFirstResponder()
        }
        
        if txtStroke.isEditing{
            txtStroke.resignFirstResponder()
        }
    }
    
    
    @IBAction func btnDropAction (sender : UIButton){
        
        if self.btnStart.isSelected{//Means Already Playing
            if self.trainer.type == .strokeRate{
                if self.trainer.strokesPerMinute > 100{
                    Helper.shared.alert(title: Constants.appName, message: "Only the beep sound can play at over 100 strokes/minute.")
                   return
                }
            }
            self.updateSoundButtonLayout(type: .drop)
            self.startTempoTrainer()
        }else{
            self.updateSoundButtonLayout(type: .drop)
            TempoTrainerManager.shared.playSound(for: .drop)
        }
    }
    
    @IBAction func btnDingAction (sender : UIButton){
        
        if self.btnStart.isSelected{//Means Already Playing
            if self.trainer.type == .strokeRate{
                if self.trainer.strokesPerMinute > 100{
                    Helper.shared.alert(title: Constants.appName, message: "Only the beep sound can play at over 100 strokes/minute.")
                   return
                }
            }
            self.updateSoundButtonLayout(type: .ding)
            self.startTempoTrainer()
        }else{
            self.updateSoundButtonLayout(type: .ding)
            TempoTrainerManager.shared.playSound(for: .ding)
        }
        
    }
    
    @IBAction func btnBeepAction (sender : UIButton){
        
        self.updateSoundButtonLayout(type: .beep)
        if self.btnStart.isSelected{//Means Already Playing
            self.startTempoTrainer()
        }else{
            TempoTrainerManager.shared.playSound(for: .beep)
        }
        
        
    }
    
    func updateSoundButtonLayout(type: SoundType){
        switch type {
        case .beep:
            self.setupBtnLayout(sender: btnDrop);
            self.setupBtnLayout(sender: btnDing);
            self.setupSelectedBtnLayout(sender: btnBeep);
            
            self.viewDrop.hideShadow()
            self.viewDing.hideShadow()
            self.viewBeep.showShadow(shadowOpacity: 0.5)
            
        case .ding:
            self.setupBtnLayout(sender: btnDrop);
            self.setupBtnLayout(sender: btnBeep);
            self.setupSelectedBtnLayout(sender: btnDing);
            
            self.viewDrop.hideShadow()
            self.viewDing.showShadow(shadowOpacity: 0.5)
            self.viewBeep.hideShadow()
            
        case .drop:
            self.setupBtnLayout(sender: btnDing);
            self.setupBtnLayout(sender: btnBeep);
            self.setupSelectedBtnLayout(sender: btnDrop);
            
            self.viewDrop.showShadow(shadowOpacity: 0.5)
            self.viewDing.hideShadow()
            self.viewBeep.hideShadow()
            
        }
        
        self.trainer.soundType = type
        self.setupSoundDuration()
        
        self.checkStrokeMaximumValue()
        self.checkLapIntervalMinimumValue()
    }
    
    
    @IBAction func StrokeRateAction(sender : UIButton){
        if txtSeconds.isEditing{
            txtStroke.becomeFirstResponder()
        }
        
        if self.trainer.type == .lapInterval{
            //Stop Trainer
            TempoTrainerManager.shared.stopTrainer()
            self.btnStart.isSelected = false
        }
        
        self.enableStrokeRate()
        self.disableLapInterval()
        
        self.checkStrokeMaximumValue()
        
        let x = ((ScreenSize.SCREEN_WIDTH/2.0)/2.0) - (self.viewSlider.frame.size.width/2.0)
        
        UIView.animate(withDuration: 0.4, delay: 0, options: UIView.AnimationOptions(), animations: { () -> Void in
            self.viewSlider.frame = CGRect(x: x, y: self.viewSlider.frame.origin.y,width: self.viewSlider.frame.size.width ,height: self.viewSlider.frame.size.height)
        }, completion: { (finished: Bool) -> Void in
            
        })
    }
    
    @IBAction func lapIntervalAction(sender : UIButton){
        if txtStroke.isEditing{
            txtSeconds.becomeFirstResponder()
        }
        
        if self.trainer.type == .strokeRate{
            //Stop Trainer
            TempoTrainerManager.shared.stopTrainer()
            self.btnStart.isSelected = false
        }
        
        self.enableLapInterval()
        self.disableStrokeRate()
        
        self.checkLapIntervalMinimumValue()
        
        let x = (((ScreenSize.SCREEN_WIDTH/2.0)/2.0) - (self.viewSlider.frame.size.width/2.0)) + (ScreenSize.SCREEN_WIDTH/2.0)
        
        UIView.animate(withDuration: 0.4, delay: 0, options: UIView.AnimationOptions(), animations: { () -> Void in
            self.viewSlider.frame = CGRect(x: x, y: self.viewSlider.frame.origin.y,width: self.viewSlider.frame.size.width ,height: self.viewSlider.frame.size.height)
        }, completion: { (finished: Bool) -> Void in
            
        })
        
        
    }
    
    @IBAction func startAction(_ sender: UIButton){
        if self.btnStart.isSelected{
            //Stop Trainer
            TempoTrainerManager.shared.stopTrainer()
            self.btnStart.isSelected = false
        }else{
            self.startTempoTrainer()
        }
    }
    
    func startTempoTrainer(){
        switch trainer.type {
        case .strokeRate:
            let strokesPerMinute = Int(txtStroke.text!) ?? 0
            if strokesPerMinute > 0{
                if strokesPerMinute > 100{//because over 100 the sound should be beep only as per client requirements
                    self.trainer.soundType = .beep
                    self.updateSoundButtonLayout(type: .beep)
                }
                
                self.trainer.strokesPerMinute = strokesPerMinute
                TempoTrainerManager.shared.startPlaySound(for: self.trainer)
                self.btnStart.isSelected = true
            }
            
        case .lapInterval:
            let secondsPerLap = Int(txtSeconds.text!) ?? 0
            if secondsPerLap > 0{
                self.trainer.secondsPerLap = secondsPerLap
                TempoTrainerManager.shared.startPlaySound(for: self.trainer)
                self.btnStart.isSelected = true
            }
        }
    }
    
    @IBAction func homeAction(_ sender: UIButton){
        sideMenuController?.revealMenu()
    }
}

extension TempoTrainerViewController : UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //textField.font = .appMedium(with: 55.0)
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == txtStroke{
            previousStrokeText = textField.text!
            textField.text = ""
            IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
            self.placeholderToolBar.isHidden = false
            self.lblToolBarPlaceholder.text = "Stroke Rate"
            self.StrokeRateAction(sender: UIButton())
        }else{
            previousSecondsText = textField.text!
            textField.text = ""
            self.placeholderToolBar.isHidden = false
            self.lblToolBarPlaceholder.text = "Lap Interval"
            self.lapIntervalAction(sender: UIButton())
        }
        
        if textField.text!.trim().isEmpty{
            self.disableBtnStart()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == txtStroke{
            if textField.text!.trim().isEmpty{
                textField.text = previousStrokeText
            }
            
            //If stroke rate is grater than maximum stroke rate then set maximum stroke rate
            self.checkStrokeMaximumValue()
            
        }else if textField == txtSeconds{
            if textField.text!.trim().isEmpty{
                textField.text = previousSecondsText
            }
            
            self.checkLapIntervalMinimumValue()
        }
        
        if !(textField.text!.trim().isEmpty){
            self.enableBtnStart()
        }
        
        if self.btnStart.isSelected{//Means Already Playing
            self.startTempoTrainer()
        }
    }
    
}

