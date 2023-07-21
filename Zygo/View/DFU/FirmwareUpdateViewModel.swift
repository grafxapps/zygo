//
//  FirmwareUpdateViewModel.swift
//  Zygo
//
//  Created by Som Parkash on 22/12/22.
//  Copyright © 2022 Somparkash. All rights reserved.
//

import UIKit

final class FirmwareUpdateViewModel: NSObject {
    
    var arrFirmwaresToUpdate: [FirmwareDTO] = []
    
    var arrStatus: [FirmwareStatusDTO] = []
    
    func createStatus(for target: TargetDeviceCode){
        
        if target == .ESP{
            arrStatus = [
                FirmwareStatusDTO(title: "Connection established", type: .Connected),
                FirmwareStatusDTO(title: "Setting up transfer", type: .SubscribeDevice),
                FirmwareStatusDTO(title: "Set target device", type: .SetTargetDevice),
                FirmwareStatusDTO(title: "Start transfer", type: .TransferRequestStart),
                FirmwareStatusDTO(title: "Transferring files", type: .TransferFile),
                FirmwareStatusDTO(title: "Confirming update", type: .TransferRequestStop),
                FirmwareStatusDTO(title: "Files successfully transferred to the radio", type: .FirmwareUpgraded)
            ]
            
        }else{
            arrStatus = [
                FirmwareStatusDTO(title: "Connection established", type: .Connected),
                FirmwareStatusDTO(title: "Setting up transfer", type: .SubscribeDevice),
                FirmwareStatusDTO(title: "Set target device", type: .SetTargetDevice),
                FirmwareStatusDTO(title: "Start transfer", type: .TransferRequestStart),
                FirmwareStatusDTO(title: "Transferring files", type: .TransferFile),
                FirmwareStatusDTO(title: "Confirming update", type: .TransferRequestStop),
                FirmwareStatusDTO(title: "Update completed successfully", type: .FirmwareUpgraded)
            ]
        }
    }
}

struct FirmwareStatusDTO{
    var title: String = ""
    var type: DFUStatusType = .Connecting
    var statusType: FirmwareStatusType = .pending
}

enum FirmwareStatusType{
    case completed
    case inprogress
    case pending
    case failed
}

enum DFUStatusType: Int{
    case Connecting = 0
    case Connected = 1
    case SubscribeDevice = 2
    case SetTargetDevice = 3
    case TransferRequestStart = 4
    case TransferFile = 5
    case TransferFileFailed = 6
    case TransferRequestStop = 7
    case FirmwareUpgraded = 8
    case FirmwareUpgradedFailed = 9
}
