//
//  PreFirmwareUpdateViewModel.swift
//  Zygo
//
//  Created by Som Parkash on 15/12/22.
//  Copyright © 2022 Somparkash. All rights reserved.
//

import UIKit

final class PreFirmwareUpdateViewModel: NSObject {
    
    private let service = BLEServices()
    
    var arrFirmwares: [FirmwareDTO] = []
    var bleDeviceInfor: BLEDeviceInfoDTO?
    
    func getFirmwareDetail(isErrorMessage: Bool = true, completion: @escaping (Bool) -> Void){
        
        
        Helper.shared.startLoading()
        self.service.fetchFirmwareDetails { [weak self] error, responseDict in
            
            DispatchQueue.main.async {
                Helper.shared.stopLoading()
                if error != nil{
                    if isErrorMessage{
                        Helper.shared.alert(title: Constants.appName, message: error!)
                    }
                    completion(false)
                    return
                }
                
                if responseDict.keys.count <= 0 && error == nil{
                    completion(false)
                    return
                }
                
                
                self?.arrFirmwares.removeAll()
                if let radioESPDict = responseDict["radioesp"] as? [String: Any]{
                    var item = FirmwareDTO(radioESPDict)
                    if URL(string: item.fileURL) != nil{
                        item.targetDevice = .ESP
                        self?.arrFirmwares.append(item)
                    }
                }
                
                if let radioSTDict = responseDict["radiost"] as? [String: Any]{
                    var item = FirmwareDTO(radioSTDict)
                    if URL(string: item.fileURL) != nil{
                        item.targetDevice = .ST
                        self?.arrFirmwares.append(item)
                    }
                }
                
                if let radioSLDict = responseDict["radiosl"] as? [String: Any]{
                    var item = FirmwareDTO(radioSLDict)
                    if URL(string: item.fileURL) != nil{
                        item.targetDevice = .SILABS_RADIO
                        self?.arrFirmwares.append(item)
                    }
                }
                
                
                
                if let headsetDict = responseDict["headset"] as? [String: Any]{
                    var item = FirmwareDTO(headsetDict)
                    if URL(string: item.fileURL) != nil{
                        item.targetDevice = .SILABS_HEADSET
                        self?.arrFirmwares.append(item)
                    }
                }
                
                completion(true)
            }
            
        }
    }
    
    func setupFirmwareDataWithDeviceVersions(infoItem: BLEVersionInfoDTO){
        
        if let espIndex = self.arrFirmwares.firstIndex(where: { $0.targetDevice == .ESP}){
            let espItem = self.arrFirmwares[espIndex]
            if espItem.version == infoItem.ESPVersion || infoItem.ESPVersion == "0"{
                self.arrFirmwares.remove(at: espIndex)
            }
        }
        
        if let stIndex = self.arrFirmwares.firstIndex(where: { $0.targetDevice == .ST}){
            let stItem = self.arrFirmwares[stIndex]
            if stItem.version == infoItem.radioSTVersion || infoItem.radioSTVersion == "0"{
                self.arrFirmwares.remove(at: stIndex)
            }
        }
        
        
        if let slIndex = self.arrFirmwares.firstIndex(where: { $0.targetDevice == .SILABS_RADIO}){
            let slItem = self.arrFirmwares[slIndex]
            if slItem.version == infoItem.radioSLVersion || infoItem.radioSLVersion == "0"{
                self.arrFirmwares.remove(at: slIndex)
            }
        }
        
        
        if let headsetIndex = self.arrFirmwares.firstIndex(where: { $0.targetDevice == .SILABS_HEADSET}){
            let headsetItem = self.arrFirmwares[headsetIndex]
            if headsetItem.version == infoItem.headsetVersion || infoItem.headsetVersion == "0"{
                self.arrFirmwares.remove(at: headsetIndex)
            }
        }
        
    }
    
}



struct FirmwareDTO{
    
    var fileURL: String = ""
    var targetDevice: TargetDeviceCode = .ESP
    var version: String = ""
    var newText: String = ""
    var skipText: String = ""
    
    init(_ dict: [String: Any]) {
        self.fileURL = dict["file"] as? String ?? ""
        self.version = dict["version"] as? String ?? ""
        self.newText = dict["WhatsNewInThisVersion"] as? String ?? ""
        self.skipText = dict["SkipMessage"] as? String ?? ""
        
    }
}
