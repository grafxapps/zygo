//
//  PlaylistTVC.swift
//  Zygo
//
//  Created by Som on 07/07/21.
//  Copyright © 2021 Somparkash. All rights reserved.
//

import UIKit

class PlaylistTVC: UITableViewCell {
    
    static let identifier = "PlaylistTVC"
    
    @IBOutlet weak var tblList: UITableView!
    @IBOutlet weak var btnViewMore: UIButton!
    @IBOutlet weak var viewMoreContentView: UIView!
    @IBOutlet weak var tblListHeightConstraint: NSLayoutConstraint!
    private var playlist: [PlayListDTO] = []
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.registerCustomCells()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func registerCustomCells(){
        self.tblList.register(UINib(nibName: PlaylistInfoTVC.identifier, bundle: nil), forCellReuseIdentifier: PlaylistInfoTVC.identifier)
    }
    
    func updateInforList(list: [PlayListDTO], isFull: Bool){
        self.playlist.removeAll()
        self.playlist.append(contentsOf: list)
        self.tblList.reloadData()
    }
    
    
    func updateViewMore(){
        self.tblListHeightConstraint.constant = self.tblList.contentSize.height
        self.contentView.layoutIfNeeded()
    }
    
}


extension PlaylistTVC: UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.playlist.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PlaylistInfoTVC.identifier) as! PlaylistInfoTVC
        cell.selectionStyle = .none
        tableView.separatorStyle = .none
        let item = self.playlist[indexPath.row]
        cell.setupPlaylistInfo(item: item)
        return cell
    }
    
}
