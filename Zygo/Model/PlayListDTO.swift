//
//  PlayListDTO.swift
//  Zygo
//
//  Created by Som on 07/07/21.
//  Copyright © 2021 Somparkash. All rights reserved.
//

import UIKit

struct PlayListDTO{
    
    var albumName: String = ""
    var artistName: String = ""
    var fileName: String = ""
    var songTitle: String = ""
    var image: String = ""
    var smallImage: String = ""
    
    init(_ dict: [String: Any]) {
        
        self.albumName = dict["album_name"] as? String ?? ""
        self.artistName = dict["artist_name"] as? String ?? ""
        self.fileName = dict["file_name"] as? String ?? ""
        self.songTitle = dict["song_title"] as? String ?? ""
        self.image = dict["image"] as? String ?? ""
        self.smallImage = dict["small_image"] as? String ?? ""
    }
}
