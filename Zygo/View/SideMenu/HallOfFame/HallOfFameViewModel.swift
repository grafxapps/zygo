//
//  HallOfFameViewModel.swift
//  Zygo
//
//  Created by Som Parkash on 26/11/23.
//  Copyright © 2023 Somparkash. All rights reserved.
//

import UIKit

final class HallOfFameViewModel: NSObject {
    
    private let service = UserServices()
    
    var type: HallOfFameModel.FameType  = .distance
    var time: HallOfFameModel.FameTime  = .all
    
    var arrHallOfFame: [HallOfFameModel] = []
    
    func getHallOfFame(completion: @escaping (Bool) -> Void){
        Helper.shared.startLoading()
        self.service.getHallOfFame(type: type.rawValue, time: time.rawValue, completion: { error, arrHallOfFame in
            DispatchQueue.main.async {
                Helper.shared.stopLoading()
                
                if error != nil{
                    Helper.shared.alert(title: Constants.appName, message: error!)
                    completion(false)
                    return
                }
                
                self.arrHallOfFame.removeAll()
                self.arrHallOfFame.append(contentsOf: arrHallOfFame)
                completion(true)
            }
        })
    }
    
}
