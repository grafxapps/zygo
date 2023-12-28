//
//  MenuViewController.swift
//  Zygo
//
//  Created by Som on 29/01/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit
import SideMenuSwift

class Preferences {
    static let shared = Preferences()
    var enableTransitionAnimation = false
}

class MenuViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.showsVerticalScrollIndicator = false
            tableView.separatorStyle = .none
        }
    }
    
    private let viewModel = SideMenuViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //SideMenuController.preferences.basic.position == .under
        configureView()
        
        sideMenuController?.cache(viewControllerGenerator: {
            self.storyboard?.instantiateViewController(withIdentifier: "SettingsViewController")
        }, with: "2")
        
        sideMenuController?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if Helper.shared.isDemoMode{
            self.viewModel.arrMenu.removeAll()
            self.viewModel.arrMenu = [.settings, .instructors, .help, .customerSupport, .walkieTalkie, .hallOfFame, .demoSubscribe]
            
        }else{
            self.viewModel.arrMenu.removeAll()
            self.viewModel.arrMenu = [.settings, .instructors, .help, .customerSupport, .walkieTalkie, .hallOfFame]
        }
        
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    private func configureView() {
        self.tableView.register(UINib(nibName: SideMenuTVC.identifier, bundle: nil), forCellReuseIdentifier: SideMenuTVC.identifier)
        self.tableView.register(UINib(nibName: SideMenuDemoTVC.identifier, bundle: nil), forCellReuseIdentifier: SideMenuDemoTVC.identifier)
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        view.layoutIfNeeded()
    }
    
    //MARK: - UIButton Actions
    @IBAction func backAction(_ sender: UIButton){
        sideMenuController?.hideMenu()
    }
    
    @objc func selectAction(_ sender: UIButton){
        let row = sender.tag
        let sItem = self.viewModel.arrMenu[row]
        switch sItem {
        case .profile:
            let settingsVC = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
            self.getCurrentNavigationController()?.pushViewController(settingsVC, animated: true)
        case .tempoTrainer:
            let tempoVC = self.storyboard?.instantiateViewController(withIdentifier: "TempoTrainerViewController") as! TempoTrainerViewController
            self.getCurrentNavigationController()?.pushViewController(tempoVC, animated: true)
        case .settings:
            let settingsVC = self.storyboard?.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
            self.getCurrentNavigationController()?.pushViewController(settingsVC, animated: true)
            
        case .shopZygo:
            Helper.shared.log(event: .SHOPZYGO, params: [:])
            let url = URL(string: Constants.shop)
            Helper.shared.openUrl(url: url)
        case .aboutZygo:
            Helper.shared.log(event: .ABOUTUS, params: [:])
            let url = URL(string: Constants.about)
            Helper.shared.openUrl(url: url)
        case .help:
            let helpVC = self.storyboard?.instantiateViewController(withIdentifier: "HelpVC") as! HelpVC
            self.getCurrentNavigationController()?.pushViewController(helpVC, animated: true)
        case .privacyPolicy:
            Helper.shared.log(event: .PRIVACYPOLICY, params: [:])
            let url = URL(string: Constants.privacyPolicy)
            Helper.shared.openUrl(url: url)
        case .termsService:
            Helper.shared.log(event: .TERMOFSERVICE, params: [:])
            let url = URL(string: Constants.termsOfService)
            Helper.shared.openUrl(url: url)
        case .instructors:
            Helper.shared.log(event: .INSTRUCTOR, params: [:])
            let instructorsVC = UIStoryboard(name: "Instructor", bundle: nil).instantiateViewController(withIdentifier: "InstructorsListViewController") as! InstructorsListViewController
            self.getCurrentNavigationController()?.pushViewController(instructorsVC, animated: true)
        case .demoSubscribe:
            print("Demo")
        case .customerSupport:
            print("Support")
            Helper.shared.log(event: .CUSTOMERSUPPORT, params: [:])
            let helpVC = self.storyboard?.instantiateViewController(withIdentifier: "CustomerSupportVC") as! CustomerSupportVC
            self.getCurrentNavigationController()?.pushViewController(helpVC, animated: true)
        case .referFriend:
            print("Refer A Friend")
            
        case .walkieTalkie:
            let walkieVC = self.storyboard?.instantiateViewController(withIdentifier: "WalkieTalkieVC") as! WalkieTalkieVC
            self.getCurrentNavigationController()?.pushViewController(walkieVC, animated: true)
        case .hallOfFame:
            let fameVC = self.storyboard?.instantiateViewController(withIdentifier: "HallOfFameVC") as! HallOfFameVC
            self.getCurrentNavigationController()?.pushViewController(fameVC, animated: true)
        }
        
        //self.perform(#selector(self.hide), with: nil, afterDelay: 0.2)
    }
    
    @objc func hide(){
        sideMenuController?.hideMenu()
    }
    
    func getCurrentNavigationController() -> UINavigationController?{
        
        
        return self.navigationController
        
        /*guard let contentNav = sideMenuController?.contentViewController as? UINavigationController else{
            return nil
        }
        
        guard let tabBarVC = contentNav.topViewController as? UITabBarController else{
            return nil
        }
        
        return tabBarVC.selectedViewController?.navigationController*/
    }
    
    @objc func subscribeAction(){
        if let vc = self.getCurrentNavigationController(){
            let storyBoard = UIStoryboard(name: "Registration", bundle: nil)
            let navigationController = storyBoard.instantiateViewController(withIdentifier: "SubscriptionViewController") as! SubscriptionViewController
            navigationController.isFromDemoMode = true
            vc.pushViewController(navigationController, animated: true)
        }
        
        //self.perform(#selector(self.hide), with: nil, afterDelay: 0.2)
    }
}

extension MenuViewController: SideMenuControllerDelegate {
    func sideMenuController(_ sideMenuController: SideMenuController,
                            animationControllerFrom fromVC: UIViewController,
                            to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BasicTransitionAnimator(options: .transitionFlipFromLeft, duration: 0.6)
    }
    
    func sideMenuController(_ sideMenuController: SideMenuController, willShow viewController: UIViewController, animated: Bool) {
        print("View controller will show [\(viewController)]")
    }
    
    func sideMenuController(_ sideMenuController: SideMenuController, didShow viewController: UIViewController, animated: Bool) {
        print("View controller did show [\(viewController)]")
    }
    
    func sideMenuControllerWillHideMenu(_ sideMenuController: SideMenuController) {
        print("Menu will hide")
    }
    
    func sideMenuControllerDidHideMenu(_ sideMenuController: SideMenuController) {
        print("Menu did hide.")
        NotificationCenter.default.post(name: .didHideMenu, object: nil)
    }
    
    func sideMenuControllerWillRevealMenu(_ sideMenuController: SideMenuController) {
        print("Menu will reveal.")
    }
    
    func sideMenuControllerDidRevealMenu(_ sideMenuController: SideMenuController) {
        print("Menu did reveal.")
    }
}

extension MenuViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.arrMenu.count
    }
    
    // swiftlint:disable force_cast
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.viewModel.arrMenu[indexPath.row] == .demoSubscribe{
            let cell = tableView.dequeueReusableCell(withIdentifier: SideMenuDemoTVC.identifier) as! SideMenuDemoTVC
            cell.btnSubscribe.addTarget(self, action: #selector(self.subscribeAction), for: .touchUpInside)
            cell.selectionStyle = .none
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: SideMenuTVC.identifier, for: indexPath) as! SideMenuTVC
            let row = indexPath.row
            let item = self.viewModel.arrMenu[row]
            cell.lblTitle.text = item.rawValue
            cell.btnSelect.tag = indexPath.row
            cell.btnSelect.addTarget(self, action: #selector(self.selectAction(_:)), for: .touchUpInside)
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let row = indexPath.row
        if self.viewModel.arrMenu[indexPath.row] == .demoSubscribe{
            return
        }
        //sideMenuController?.setContentViewController(with: "\(row)", animated: Preferences.shared.enableTransitionAnimation)
        //sideMenuController?.hideMenu()
        
        if indexPath.row == 2{//Settings
            Helper.shared.logout()
        }
        
        if let identifier = sideMenuController?.currentCacheIdentifier() {
            print("View Controller Cache Identifier: \(identifier)")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.viewModel.arrMenu[indexPath.row] == .demoSubscribe{
            return UITableView.automaticDimension
        }
        /*let headerHeight: CGFloat = 60.0
        let screenHeight: CGFloat = ScreenSize.SCREEN_HEIGHT
        //let statusBar = view.safeAreaLayoutGuide.layoutFrame.minY
        
        let window = UIApplication.shared.windows[0]
        let topPadding = window.safeAreaInsets.top
        let bottomPadding = window.safeAreaInsets.bottom
        
        var itemHeight = (screenHeight - (headerHeight + topPadding + bottomPadding))/CGFloat(self.viewModel.arrMenu.count)
        if itemHeight < 80.0{
            itemHeight = 80.0
        }*/
        
        return 70
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
}
