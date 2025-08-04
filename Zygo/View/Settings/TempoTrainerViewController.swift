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
    
    private var strokeRatePicker: UIPickerView!
    private var lapIntervalPicker: UIPickerView!
    
    private let viewModel = WorkoutPlayerViewModel()
    
    //MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Helper.shared.log(event: .TABPACING, params: [:])
        
        self.setupPicker()
        
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
        //self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.isNavigationBarHidden = true
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
    func setupPicker(){
        strokeRatePicker = UIPickerView()
        strokeRatePicker.dataSource = self
        strokeRatePicker.delegate = self
        strokeRatePicker.selectRow(49, inComponent: 0, animated: false)
        
        self.txtStroke.inputView = strokeRatePicker
        
        lapIntervalPicker = UIPickerView()
        lapIntervalPicker.dataSource = self
        lapIntervalPicker.delegate = self
        lapIntervalPicker.selectRow(45, inComponent: 0, animated: false)
        
        self.txtSeconds.inputView = lapIntervalPicker
    }
    
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
    
    func calculateTempoDuration(){
        
        if !Helper.shared.isTestUser{
            if !SubscriptionManager.shared.isValidSubscription(){//If not valid subscription
                return
            }
        }
        
        guard let startDate = TempoTrainerManager.shared.startTime else{
            return
        }
        
        var strokeValue = TempoTrainerManager.shared.currentTrainer?.strokesPerMinute ?? 0
        if strokeValue <= 0{
            strokeValue = 50
        }
        
        //check if user end this tempo trainer after 5 minutes then get it as a workout
        let startSeconds = startDate.timeIntervalSince1970
        let endSeconds = DateHelper.shared.currentLocalDateTime.timeIntervalSince1970
        let durationSeconds = endSeconds - startSeconds
        let maxSeconds = 5.0 * 60.0
        if durationSeconds > maxSeconds{
            //Hit API to record workout
            self.viewModel.completeWorkout(0, Int(durationSeconds), Int(durationSeconds)) { (isCompleted, workoutLogId) in
                TempoTrainerManager.shared.startTime = nil
                Helper.shared.log(event: .ENDWORKOUT, params: [:])
                if isCompleted{
                    print("Workout completed successfully!!")
                    let info = PreferenceManager.shared.trackingInfo
                    if info.isDistanceTracking || info.isTempoTracking || self.viewModel.arrAchievements.count > 0{
                        let feedbackVC = FeedbackSheetViewController(nibName: "FeedbackSheetViewController", bundle: nil, workoutItem: WorkoutDTO(["id":0]), achievements: self.viewModel.arrAchievements, workoutLogId: workoutLogId, timeElapsed: Int(durationSeconds))
                        feedbackVC.isNoWorkout = true
                        feedbackVC.noWorkoutStrokeValue = strokeValue
                        feedbackVC.delegate = self
                        feedbackVC.modalPresentationStyle = .overFullScreen
                        self.present(feedbackVC, animated: true, completion: nil)
                    }                    
                }
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
            self.calculateTempoDuration()
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
            self.calculateTempoDuration()
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
    
    func stopTempTrainer(){
        //Stop Trainer
        self.calculateTempoDuration()
        TempoTrainerManager.shared.stopTrainer()
        self.btnStart.isSelected = false
        Helper.shared.stopDemoTime()
        Helper.shared.log(event: .TEMPOTRAINERSTOP, params: [:])
    }
    
    @IBAction func startAction(_ sender: UIButton){
        if self.btnStart.isSelected{
            //Stop Trainer
            self.stopTempTrainer()
        }else{
            
            /*Helper.shared.resetDemoModeTime()
            if Helper.shared.isDemoMode{
                if Helper.shared.isDemoLimitComplete(){
                    let alert = CustomAlertWithCloseVC(nibName: "CustomAlertWithCloseVC", bundle: nil, title: Constants.appName, message: "Start your free trial to access all of our content.", buttonTitle: "Subscribe") { (isYes) in
                        if isYes{
                            //Push To Subscribe screen
                            Helper.shared.pushToSubscriptionScreen(from: self)
                        }
                    }
                    
                    alert.transitioningDelegate = self
                    alert.modalPresentationStyle = .custom
                    self.present(alert, animated: true, completion: nil)
                    return
                }
            }*/
            
            Helper.shared.log(event: .TEMPOTRAINERSTART, params: [:])
            Helper.shared.stopDemoTime()
            Helper.shared.startDemoTime()
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
                TempoTrainerManager.shared.startTime = DateHelper.shared.currentLocalDateTime
                
                /*if Helper.shared.isDemoMode{
                    TempoTrainerManager.shared.demoCompletion = {
                        TempoTrainerManager.shared.stopTrainer()
                        self.btnStart.isSelected = false
                        Helper.shared.stopDemoTime()
                        
                        let alert = CustomAlertWithCloseVC(nibName: "CustomAlertWithCloseVC", bundle: nil, title: Constants.appName, message: "Start your free trial to access all of our content.", buttonTitle: "Subscribe") { (isYes) in
                            if isYes{
                                //Push To Subscribe screen
                                Helper.shared.pushToSubscriptionScreen(from: self)
                            }
                        }
                        
                        alert.transitioningDelegate = self
                        alert.modalPresentationStyle = .custom
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                }*/
                
                self.btnStart.isSelected = true
            }
            
        case .lapInterval:
            let secondsPerLap = Int(txtSeconds.text!) ?? 0
            if secondsPerLap > 0{
                self.trainer.secondsPerLap = secondsPerLap
                TempoTrainerManager.shared.startPlaySound(for: self.trainer)
                TempoTrainerManager.shared.startTime = DateHelper.shared.currentLocalDateTime
                /*if Helper.shared.isDemoMode{
                    TempoTrainerManager.shared.demoCompletion = {
                        TempoTrainerManager.shared.stopTrainer()
                        self.btnStart.isSelected = false
                        Helper.shared.stopDemoTime()
                        
                        let alert = CustomAlertWithCloseVC(nibName: "CustomAlertWithCloseVC", bundle: nil, title: Constants.appName, message: "Start your free trial to access all of our content.", buttonTitle: "Subscribe") { (isYes) in
                            if isYes{
                                //Push To Subscribe screen
                                Helper.shared.pushToSubscriptionScreen(from: self)
                            }
                        }
                        
                        alert.transitioningDelegate = self
                        alert.modalPresentationStyle = .custom
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                }*/
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
            IQKeyboardManager.shared.toolbarConfiguration.placeholderConfiguration.showPlaceholder = false
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
            
            let selectedrow = strokeRatePicker.selectedRow(inComponent: 0) + 1
            self.txtStroke.text = "\(selectedrow)"
            
            //If stroke rate is grater than maximum stroke rate then set maximum stroke rate
            self.checkStrokeMaximumValue()
            
        }else if textField == txtSeconds{
            
            if textField.text!.trim().isEmpty{
                textField.text = previousSecondsText
            }
            
            
            let selectedrow = lapIntervalPicker.selectedRow(inComponent: 0) + 5
            self.txtSeconds.text = "\(selectedrow)"
            
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


extension TempoTrainerViewController: UIPickerViewDataSource, UIPickerViewDelegate{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == lapIntervalPicker{
            return 995
        }
        return 120
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == lapIntervalPicker{
            return "\(row+5)"
        }
        return "\(row+1)"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == lapIntervalPicker{
            self.txtSeconds.text = "\(row+5)"
        }else{
            self.txtStroke.text = "\(row+1)"
        }
    }
}

extension TempoTrainerViewController: UIViewControllerTransitioningDelegate{
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentingAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissingAnimator()
    }
    
}

extension TempoTrainerViewController: FeedbackSheetViewControllerDelegates{
    
    func feedbackDone() {
        
    }
}
