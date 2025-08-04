//
//  RenameBluetoothIDVM.swift
//  Zygo
//
//  Created by Som Parkash on 19/01/25.
//  Copyright © 2025 Somparkash. All rights reserved.
//

import UIKit

final class RenameBluetoothIDVM: NSObject {

    private let userService = UserServices()
    
    func updateBTName(name: String, completion: @escaping () -> Void){
        self.userService.updateBT(name: name) { error in
            completion()
            if error != nil{
                print("BT Name Update error: \(error!)")
            }
        }
    }
    
}
