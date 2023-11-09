//
//  PlaylistInfoTVC.swift
//  Zygo
//
//  Created by Som on 07/07/21.
//  Copyright © 2021 Somparkash. All rights reserved.
//

import UIKit
import SDWebImage

class PlaylistInfoTVC: UITableViewCell {
    
    static let identifier = "PlaylistInfoTVC"
    
    @IBOutlet weak var playlistImageView: UIImageView!
    @IBOutlet weak var lblSongName: UILabel!
    @IBOutlet weak var lblArtistName: UILabel!
    @IBOutlet weak var lblAlbumName: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setupPlaylistInfo(item: PlayListDTO){
        self.lblSongName.text = item.songTitle
        self.lblArtistName.text = item.artistName
        if item.albumName.isEmpty{
            self.lblAlbumName.text = " "
        }else{
            self.lblAlbumName.text = item.albumName
        }
        
        
        self.playlistImageView.image = nil
        if !item.image.isEmpty{
            self.playlistImageView.sd_setImage(with: URL(string: item.smallImage), placeholderImage: nil, options: .refreshCached, completed: nil)
        }
    }
}
