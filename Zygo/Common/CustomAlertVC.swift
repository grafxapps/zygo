//
//  CustomAlertVC.swift
//  TalkIt
//
//  Created by Wegile on 20/04/21.
//

import UIKit

class CustomAlertVC: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    
    @IBOutlet weak var btnExit: UIButton!
    
    @IBOutlet weak var bgImage: UIImageView!
    
    private var mTitle: String = ""
    private var mMessage: String = ""
    
    private var completionHandler: ((Bool) -> Void)?
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, title: String, message: String, completion: @escaping (Bool) -> Void) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.mTitle = title
        self.mMessage = message
        self.completionHandler = completion
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UIViewcontroller LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /*self.bgImage.alpha = 0.0
        UIView.animate(withDuration: 1.0) {
            self.bgImage.alpha = 0.5
        }*/
    }
    
    
    //MARK: - Setups
    func setupUI(){
        
        self.lblTitle.text = self.mTitle
        self.lblMessage.text = self.mMessage
        
        self.btnExit.layer.cornerRadius = 10.0
        self.btnExit.layer.masksToBounds = true
    }
    
    //MARK: - UIButton Actions
    @IBAction func exitAction(){
        self.bgImage.alpha = 0.0
        self.dismiss(animated: true) {
            self.completionHandler?(true)
        }
    }
}
