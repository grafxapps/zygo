//
//  DownloadsViewController.swift
//  Zygo
//
//  Created by Priya Gandhi on 24/01/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit

class DownloadsViewController: UIViewController {
    @IBOutlet weak var tblDownloads : UITableView!
    private let downloadIdentifier = "DownloadsTVC"
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerTVC()
    }
        //MARK:- Setup
      func registerTVC()  {
          tblDownloads.register(UINib.init(nibName: downloadIdentifier, bundle: nil), forCellReuseIdentifier: downloadIdentifier);
          
      }
    

}

extension DownloadsViewController : UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : DownloadsTVC = tableView.dequeueReusableCell(withIdentifier: downloadIdentifier) as! DownloadsTVC
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
}
