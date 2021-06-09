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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    private func configureView() {
        self.tableView.register(UINib(nibName: SideMenuTVC.identifier, bundle: nil), forCellReuseIdentifier: SideMenuTVC.identifier)
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
            let url = URL(string: Constants.shop)
            Helper.shared.openUrl(url: url)
        case .aboutZygo:
            let url = URL(string: Constants.about)
            Helper.shared.openUrl(url: url)
        case .privacyPolicy:
            let url = URL(string: Constants.privacyPolicy)
            Helper.shared.openUrl(url: url)
        case .termsService:
            let url = URL(string: Constants.termsOfService)
            Helper.shared.openUrl(url: url)
        }
        
        sideMenuController?.hideMenu()
    }
    
    func getCurrentNavigationController() -> UINavigationController?{
        
        guard let contentNav = sideMenuController?.contentViewController as? UINavigationController else{
            return nil
        }
        
        guard let tabBarVC = contentNav.topViewController as? UITabBarController else{
            return nil
        }
        
        return tabBarVC.selectedViewController?.navigationController
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
        let cell = tableView.dequeueReusableCell(withIdentifier: SideMenuTVC.identifier, for: indexPath) as! SideMenuTVC
        let row = indexPath.row
        let item = self.viewModel.arrMenu[row]
        cell.lblTitle.text = item.rawValue
        cell.btnSelect.tag = indexPath.row
        cell.btnSelect.addTarget(self, action: #selector(self.selectAction(_:)), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let row = indexPath.row
        
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
