//
//  BluetoothManager.swift
//  Zygo
//
//  Created by Som Parkash on 30/10/22.
//  Copyright © 2022 Somparkash. All rights reserved.
//

import UIKit
import CoreBluetooth
import AVFAudio

struct BTDevice {
    var device: CBPeripheral!
    var rssi: NSNumber!
    var services: [ZygoService:BTService]
    
}

struct BTService{
    var uuid: CBUUID
    var service: CBService?
    var characteristics: [ZygoCharacteristic:BTCharacteristic] = [:]
}

struct BTCharacteristic{
    var uuid: CBUUID
    var characteristic: CBCharacteristic?
    var onRead: ((Data) -> Void)?
    var onWrite: (() -> Void)?
}

enum ZygoService: String{
    case data = "68999001-8008-968F-E311-6150405558B3"
    case OTA = "EEF1D96D-594C-4C53-B1C6-244A1DFDE6D8"
}

enum ZygoCharacteristic: String{
    case lapData = "6899900A-8008-968F-E311-6150405558B3"
    case hardwareData = "6899900B-8008-968F-E311-6150405558B3"
    case diagnosticData = "6899900C-8008-968F-E311-6150405558B3"
    case complieData = "6899900D-8008-968F-E311-6150405558B3"
    case status = "6899900E-8008-968F-E311-6150405558B3"
    case btName = "6899900F-8008-968F-E311-6150405558B3"
    
    case otaData = "EE408888-1F40-4CD8-9B89-CA8D45F8A5B0"
    case otaControl = "EED671AA-21C0-46A4-B722-270E3AE3D830"
}


final class BluetoothManager: NSObject {
    
    static let shared = BluetoothManager()
    
    private var centralManager: CBCentralManager?
    private var discoveredPeripherals: [BTDevice] = []
    private var currentSelectedDeviceIdentifier: UUID = UUID()
    private var timeOutTimer: Timer?
    
    private let packetSize: UInt32 = 480 // Legacy DFU does not support higher MTUs.
    
    private let defaulServices: [ZygoService:BTService] = [.data : BTService(uuid: CBUUID(string: ZygoService.data.rawValue)), .OTA : BTService(uuid: CBUUID(string: ZygoService.OTA.rawValue))]
    
    private let defaulCharacteristics: [ZygoService: [ZygoCharacteristic : BTCharacteristic]] = [
        .data : [
            .lapData : BTCharacteristic(uuid: CBUUID(string: ZygoCharacteristic.lapData.rawValue)),
            .hardwareData :BTCharacteristic(uuid: CBUUID(string: ZygoCharacteristic.hardwareData.rawValue)),
            .diagnosticData :BTCharacteristic(uuid: CBUUID(string: ZygoCharacteristic.diagnosticData.rawValue)),
            .complieData :BTCharacteristic(uuid: CBUUID(string: ZygoCharacteristic.complieData.rawValue)),
            .status :BTCharacteristic(uuid: CBUUID(string: ZygoCharacteristic.status.rawValue)),
            .btName :BTCharacteristic(uuid: CBUUID(string: ZygoCharacteristic.btName.rawValue))
        ],
        .OTA: [
            .otaData : BTCharacteristic(uuid: CBUUID(string: ZygoCharacteristic.otaData.rawValue)),
            .otaControl : BTCharacteristic(uuid: CBUUID(string: ZygoCharacteristic.otaControl.rawValue)),
        ]
    ]
    
    private var isAlreadyShowTurnOnPopup: Bool = false
    private var isAlreadyShowPermissionPopup: Bool = false
    
    override init() {
    }
    
    //MARK: -
    func wakeUpBLE(){
        _ = self.getCentralManager()
    }
    
    var isBluetoothTurnOn: Bool{
        let cManager = self.getCentralManager()
        return cManager.state == .poweredOn
    }
    
    var isBluetoothPermissionGranted: Bool {
        if #available(iOS 13.1, *) {
            return CBCentralManager.authorization == .allowedAlways
        } else if #available(iOS 13.0, *) {
            return CBCentralManager().authorization == .allowedAlways
        }
        
        // Before iOS 13, Bluetooth permissions are not required
        return true
    }
    
    private func getCentralManager() -> CBCentralManager{
        if self.centralManager != nil{
            return self.centralManager!
        }else{
            let centralQueue: DispatchQueue = DispatchQueue(label: "com.Zygo.BLECentralManager", attributes: .concurrent)
            self.centralManager = CBCentralManager(delegate: self, queue: centralQueue, options: [CBCentralManagerOptionShowPowerAlertKey: true])
            return self.centralManager!
        }
    }
    
    //MARK: - Scanning
    private var onScanning: (([BTDevice]) -> Void)?
    func startScanning(onScanning: (([BTDevice]) -> Void)? = nil){
        self.onScanning = onScanning
        let cManager = self.getCentralManager()
        if cManager.state == .poweredOn{
            
            //Check Authorization State
            if isBluetoothPermissionGranted{
                cManager.scanForPeripherals(withServices: [CBUUID(string: ZygoService.data.rawValue), CBUUID(string: ZygoService.OTA.rawValue)])
            }else{
                
                if UIApplication.topViewController() is UIAlertController{
                    return
                }
                if self.isAlreadyShowPermissionPopup{
                    return
                }
                
                self.isAlreadyShowPermissionPopup = true
                Helper.shared.alertYesNoActions(title: Constants.appName, message: "Please grant bluetooth permission from settings menu.", yesActionTitle: "Settings", noActionTitle: "Close") { isSettings in
                    if isSettings{
                        Helper.shared.openUrl(url: URL(string: UIApplication.openSettingsURLString))
                    }
                }
            }
            
        }else{
            //Turn On Yours Bluetooth from settings
            if UIApplication.topViewController() is UIAlertController{
                return
            }
            
            if self.isAlreadyShowTurnOnPopup{
                return
            }
            
            self.isAlreadyShowTurnOnPopup = true
            
            Helper.shared.alert(title: Constants.appName, message: "Please turn on Bluetooth in Settings.") {
            }
        }
    }
    
    func stopScanning(){
        let cManager = self.getCentralManager()
        cManager.stopScan()
    }
    
    //MARK: - Device
    private var onConnect: ((BTDevice) -> Void)?
    private var onFailedToConnect: ((BTDevice) -> Void)?
    func connect(_ device: BTDevice, onConnect: ((BTDevice) -> Void)? = nil, onFailedToConnect: ((BTDevice) -> Void)? = nil){
        self.onConnect = onConnect
        self.onFailedToConnect = onFailedToConnect
        let cManager = self.getCentralManager()
        device.device.delegate = self
        cManager.connect(device.device)
    }
    
    var onDeviceDisconnect: (() -> Void)?
    private var onDisconnect: ((BTDevice) -> Void)?
    func disconnect(_ device: BTDevice, onDisconnect: ((BTDevice) -> Void)? = nil){
        self.onDisconnect = onDisconnect
        let cManager = self.getCentralManager()
        cManager.cancelPeripheralConnection(device.device)
    }
    
    func disconnectCurrentDevice(){
        guard let deviceIndex = self.discoveredPeripherals.firstIndex(where: { $0.device.identifier.uuidString == currentSelectedDeviceIdentifier.uuidString }) else{
            //Device Not Connted
            print("No Zygo Device connected")
            return
        }
        
        let deviceItem = self.discoveredPeripherals[deviceIndex]
        self.disconnect(deviceItem)
        
    }
    
    func isZygoDeviceConencted() -> Bool{
        //Check If any Zygo device is connnected or not
        guard let deviceIndex = self.discoveredPeripherals.firstIndex(where: { $0.device.identifier.uuidString == currentSelectedDeviceIdentifier.uuidString }) else{
            //Device Not Connted
            print("No Zygo Device connected")
            return false
        }
        
        
        if self.discoveredPeripherals[deviceIndex].device.state != .connected && self.discoveredPeripherals[deviceIndex].device.state != .connecting{
            return false
        }
        
        return true
    }
    
    func isBluetoothAudioConnected() -> Bool{
      let outputs = AVAudioSession.sharedInstance().currentRoute.outputs
      for output in outputs{
          if output.portType == .bluetoothA2DP || output.portType == .bluetoothHFP || output.portType == .bluetoothLE {
          return true
        }
      }
      return false
    }
    
    //MARK: - Services and Characteristics
    private var onServices: ((BTDevice) -> Void)?
    func fetchAllServices(_ device: BTDevice, onServices: ((BTDevice) -> Void)? = nil){
        self.onServices = onServices
        device.device.discoverServices([CBUUID(string: ZygoService.data.rawValue),CBUUID(string: ZygoService.OTA.rawValue)])
    }
    
    private var onCharacteristics: ((BTDevice) -> Void)?
    func fetchAllCharacteristics(_ device: BTDevice, onCharacteristics: ((BTDevice) -> Void)? = nil){
        self.onCharacteristics = onCharacteristics
        for serviceItem in device.services {
            if let service = device.services[serviceItem.key]?.service{
                let arrChar = device.services[serviceItem.key]?.characteristics.map({ $1.uuid }) ?? []
                device.device.discoverCharacteristics(arrChar, for: service)
            }
        }
    }
    
    //MARK: - BatteryStatus, Version info and Lap Data
    var allCharDataDispatchGroup: DispatchGroup?
    
    func readAllCharactersticsData(completion: @escaping (String, String) -> Void){
        
        allCharDataDispatchGroup = DispatchGroup()
        
        guard let deviceIndex = self.discoveredPeripherals.firstIndex(where: { $0.device.identifier.uuidString == currentSelectedDeviceIdentifier.uuidString }) else{
            DispatchQueue.main.async {
                completion("", "")
            }
            return
        }
        
        guard let dataService = self.discoveredPeripherals[deviceIndex].services[.data] else{
            return
        }
        
        
        var charData: String = ""
        var headsetSerialNumber: String = ""
        //lapData
        guard let lapDataChar = dataService.characteristics[.lapData]?.characteristic else{
            DispatchQueue.main.async {
                completion(charData, headsetSerialNumber)
            }
            return
        }
        
        self.allCharDataDispatchGroup?.enter()
        self.discoveredPeripherals[deviceIndex].services[.data]?.characteristics[.lapData]?.onRead = { [weak self] data in
            self?.discoveredPeripherals[deviceIndex].services[.data]?.characteristics[.lapData]?.onRead = nil
            print("Lap Data: \(data.hexString)")
            charData += "CHAR0: \(data.hexString)"
            headsetSerialNumber = data[8...15].hexString
            self?.allCharDataDispatchGroup?.leave()
        }
        self.discoveredPeripherals[deviceIndex].device.readValue(for: lapDataChar)
        
        //hardwareData
        guard let hardwareDataChar = dataService.characteristics[.hardwareData]?.characteristic else{
            DispatchQueue.main.async {
                completion(charData, headsetSerialNumber)
            }
            return
        }
        self.allCharDataDispatchGroup?.enter()
        self.discoveredPeripherals[deviceIndex].services[.data]?.characteristics[.hardwareData]?.onRead = { [weak self] data in
            self?.discoveredPeripherals[deviceIndex].services[.data]?.characteristics[.hardwareData]?.onRead = nil
            print("Harware Data: \(data.hexString)")
            charData += " CHAR1: \(data.hexString)"
            self?.allCharDataDispatchGroup?.leave()
        }
        self.discoveredPeripherals[deviceIndex].device.readValue(for: hardwareDataChar)
        
        //diagnosticData
        guard let diagnosticDataChar = dataService.characteristics[.diagnosticData]?.characteristic else{
            DispatchQueue.main.async {
                completion(charData, headsetSerialNumber)
            }
            return
        }
        self.allCharDataDispatchGroup?.enter()
        self.discoveredPeripherals[deviceIndex].services[.data]?.characteristics[.diagnosticData]?.onRead = { [weak self] data in
            self?.discoveredPeripherals[deviceIndex].services[.data]?.characteristics[.diagnosticData]?.onRead = nil
            print("Diagnostic Data: \(data.hexString)")
            charData += " CHAR2: \(data.hexString)"
            self?.allCharDataDispatchGroup?.leave()
        }
        self.discoveredPeripherals[deviceIndex].device.readValue(for: diagnosticDataChar)
        
        //complieData
        guard let complieDataChar = dataService.characteristics[.complieData]?.characteristic else{
            DispatchQueue.main.async {
                completion(charData, headsetSerialNumber)
            }
            return
        }
        
        self.allCharDataDispatchGroup?.enter()
        self.discoveredPeripherals[deviceIndex].services[.data]?.characteristics[.complieData]?.onRead = { [weak self] data in
            self?.discoveredPeripherals[deviceIndex].services[.data]?.characteristics[.complieData]?.onRead = nil
            print("Complie Data: \(data.hexString)")
            charData += " CHAR3: \(data.hexString)"
            self?.allCharDataDispatchGroup?.leave()
        }
        self.discoveredPeripherals[deviceIndex].device.readValue(for: complieDataChar)
        
        //status
        guard let statusDataChar = dataService.characteristics[.status]?.characteristic else{
            DispatchQueue.main.async {
                completion(charData, headsetSerialNumber)
            }
            return
        }
        
        self.allCharDataDispatchGroup?.enter()
        self.discoveredPeripherals[deviceIndex].services[.data]?.characteristics[.status]?.onRead = { [weak self] data in
            self?.discoveredPeripherals[deviceIndex].services[.data]?.characteristics[.status]?.onRead = nil
            print("Status Data: \(data.hexString)")
            charData += " CHAR4: \(data.hexString)"
            self?.allCharDataDispatchGroup?.leave()
        }
        self.discoveredPeripherals[deviceIndex].device.readValue(for: statusDataChar)
        
        //BT Name
        guard let statusDataChar = dataService.characteristics[.btName]?.characteristic else{
            DispatchQueue.main.async {
                completion(charData, headsetSerialNumber)
            }
            return
        }
        
        self.allCharDataDispatchGroup?.enter()
        self.discoveredPeripherals[deviceIndex].services[.data]?.characteristics[.btName]?.onRead = { [weak self] data in
            self?.discoveredPeripherals[deviceIndex].services[.data]?.characteristics[.btName]?.onRead = nil
            print("BTName Data: \(data.hexString)")
            charData += " CHAR5: \(data.hexString)"
            self?.allCharDataDispatchGroup?.leave()
        }
        self.discoveredPeripherals[deviceIndex].device.readValue(for: statusDataChar)
        
        
        self.allCharDataDispatchGroup?.notify(queue: .main){
            DispatchQueue.main.async {
                completion(charData, headsetSerialNumber)
            }
        }
    }
    
    
    func readZygo2TranmistterSerialNumber(completion: @escaping (String) -> Void){
        
        allCharDataDispatchGroup = DispatchGroup()
        
        guard let deviceIndex = self.discoveredPeripherals.firstIndex(where: { $0.device.identifier.uuidString == currentSelectedDeviceIdentifier.uuidString }) else{
            DispatchQueue.main.async {
                completion("")
            }
            return
        }
        
        guard let dataService = self.discoveredPeripherals[deviceIndex].services[.data] else{
            return
        }
        
        
        var charData: String = ""
        
        //hardwareData
        guard let hardwareDataChar = dataService.characteristics[.hardwareData]?.characteristic else{
            DispatchQueue.main.async {
                completion(charData)
            }
            return
        }
        self.allCharDataDispatchGroup?.enter()
        self.discoveredPeripherals[deviceIndex].services[.data]?.characteristics[.hardwareData]?.onRead = { data in
            self.discoveredPeripherals[deviceIndex].services[.data]?.characteristics[.hardwareData]?.onRead = nil
            print("Harware Data: \(data.hexString)")

            //For z2 it's transmitter serial number
            let transmitterSerialNumber = data[10...13].hexString
            print("Zygo 2 transmitterSerial Number: \(transmitterSerialNumber)")
            charData = "\(transmitterSerialNumber)"
            self.allCharDataDispatchGroup?.leave()
        }
        self.discoveredPeripherals[deviceIndex].device.readValue(for: hardwareDataChar)
        
        //diagnosticData
        guard let diagnosticDataChar = dataService.characteristics[.diagnosticData]?.characteristic else{
            DispatchQueue.main.async {
                completion(charData)
            }
            return
        }
        self.allCharDataDispatchGroup?.enter()
        self.discoveredPeripherals[deviceIndex].services[.data]?.characteristics[.diagnosticData]?.onRead = { data in
            self.discoveredPeripherals[deviceIndex].services[.data]?.characteristics[.diagnosticData]?.onRead = nil
            print("Diagnostic Data: \(data.hexString)")
            //For z2 it's transmitter serial number
            let transmitterSerialNumber = data[0...3].hexString
            print("Zygo 2 transmitterSerial Number: \(transmitterSerialNumber)")
            charData += "\(transmitterSerialNumber)"
            self.allCharDataDispatchGroup?.leave()
        }
        self.discoveredPeripherals[deviceIndex].device.readValue(for: diagnosticDataChar)
        
        self.allCharDataDispatchGroup?.notify(queue: .main){
            DispatchQueue.main.async {
                PreferenceManager.shared.transmitterSerialNumber = charData
                completion(charData)
            }
        }
    }
    
    func readHardwareInfo(completion: @escaping (BLEDeviceInfoDTO) -> Void){
        
        guard let deviceIndex = self.discoveredPeripherals.firstIndex(where: { $0.device.identifier.uuidString == currentSelectedDeviceIdentifier.uuidString }) else{
            DispatchQueue.main.async {
                completion(BLEDeviceInfoDTO([:]))
            }
            return
        }
        
        guard let charItem = self.discoveredPeripherals[deviceIndex].services[.data]?.characteristics[.hardwareData]?.characteristic else{
            DispatchQueue.main.async {
                completion(BLEDeviceInfoDTO([:]))
            }
            return
        }
        
        self.discoveredPeripherals[deviceIndex].services[.data]?.characteristics[.hardwareData]?.onRead = { data in
            
            self.discoveredPeripherals[deviceIndex].services[.data]?.characteristics[.hardwareData]?.onRead = nil
            //print("Device Info Data")
            if data.count < 1{
                DispatchQueue.main.async {
                    completion(BLEDeviceInfoDTO([:]))
                }
                return
            }
            
            print("Hardware Data: \(data.hexString)")
            
            let radioBattery = data[0]
            let headsetBattery = data[1]
            
            let headsetVersion = data[2...5].to(type: UInt16.self) ?? 0
            let headsetRevNum = data[4...5].to(type: UInt16.self) ?? 0
            
            let radioSTVersion = data[6...9].to(type: UInt16.self) ?? 0
            let radioSTRevNum = data[8...9].to(type: UInt16.self) ?? 0
            
            //For z2 it's transmitter serial number
            let radioSLVersion = data[10...13].to(type: UInt16.self) ?? 0
            
            let ESPVersion = data[14...17].to(type: UInt16.self) ?? 0
            let ESPVersionRevNum = data[16...17].to(type: UInt16.self) ?? 0
            
            print("headsetRevNum: \(headsetRevNum)")
            print("radioSTRevNum: \(radioSTRevNum)")
            print("ESPVersionRevNum: \(ESPVersionRevNum)")
             
            var totalRevNumber: UInt16 = 0
            var totalRevNumberCount: UInt16 = 0
            if headsetVersion > 0{
                totalRevNumber += headsetRevNum
                totalRevNumberCount += 1
            }
            
            if radioSTRevNum > 0{
                totalRevNumber += radioSTRevNum
                totalRevNumberCount += 1
            }
            
            if ESPVersionRevNum > 0{
                totalRevNumber += ESPVersionRevNum
                totalRevNumberCount += 1
            }
            
            
            let revNum = ceil(Double(totalRevNumber)/Double(totalRevNumberCount))
            var deviceVersion: ZygoDeviceVersion = .v1
            if revNum >= 2{
                deviceVersion = .v2
            }
            
            
            var versionItem = BLEVersionInfoDTO(headsetVersion: "\(headsetVersion)", radioSTVersion: "\(radioSTVersion)", radioSLVersion: "\(radioSLVersion)", ESPVersion: "\(ESPVersion)", zygoDeviceVersion: deviceVersion)
            
            if deviceVersion == .v2{
                versionItem.radioSLVersion = "\(radioSTVersion)"
                versionItem.radioSTVersion = "0"
            }
            
            let previourInfo = PreferenceManager.shared.deviceInfo
            
            var bleInfo = BLEDeviceInfoDTO([:])
            bleInfo.radioUpdateAt = Date()
            bleInfo.versionInfo = versionItem
            if radioBattery > 100{
                bleInfo.radioBatteryLevel = Int8(100)
            }else{
                bleInfo.radioBatteryLevel = Int8(radioBattery)
            }
            
            bleInfo.deviceIdentifier = self.discoveredPeripherals[deviceIndex].device.identifier.uuidString
            
            if headsetVersion != 0{
                bleInfo.headsetUpdateAt = Date()
                if headsetBattery > 100{
                    bleInfo.headsetBatteryLevel = Int8(100)
                }else{
                    bleInfo.headsetBatteryLevel = Int8(headsetBattery)
                }
            }else{
                bleInfo.headsetUpdateAt = previourInfo.headsetUpdateAt
                bleInfo.headsetBatteryLevel = previourInfo.headsetBatteryLevel
            }
            
            if !versionItem.isVersionZero(){
                bleInfo.radioUpdateAt = Date()
                PreferenceManager.shared.deviceInfo = bleInfo
            }
            
            print("Headset Version: \(headsetVersion)")
            print("Radio ST Version: \(radioSTVersion)")
            print("Radio SL Version: \(radioSLVersion)")
            print("ESP Version: \(ESPVersion)")
            DispatchQueue.main.async {
                completion(bleInfo)
            }
        }
        
        self.discoveredPeripherals[deviceIndex].device.readValue(for: charItem)
        
    }
    
    func readInternalHardwareInfo(completion: @escaping (BLEDeviceInfoDTO) -> Void){
        
        guard let deviceIndex = self.discoveredPeripherals.firstIndex(where: { $0.device.identifier.uuidString == currentSelectedDeviceIdentifier.uuidString }) else{
            DispatchQueue.main.async {
                completion(BLEDeviceInfoDTO([:]))
            }
            return
        }
        
        guard let charItem = self.discoveredPeripherals[deviceIndex].services[.data]?.characteristics[.hardwareData]?.characteristic else{
            DispatchQueue.main.async {
                completion(BLEDeviceInfoDTO([:]))
            }
            return
        }
        
        self.discoveredPeripherals[deviceIndex].services[.data]?.characteristics[.hardwareData]?.onRead = { data in
            
            self.discoveredPeripherals[deviceIndex].services[.data]?.characteristics[.hardwareData]?.onRead = nil
            //print("Device Info Data")
            if data.count < 1{
                DispatchQueue.main.async {
                    completion(BLEDeviceInfoDTO([:]))
                }
                return
            }
            
            self.updateHardwareData(data: data, completion: completion)
        }
        
        self.discoveredPeripherals[deviceIndex].device.readValue(for: charItem)
        
    }
    
    private func updateHardwareData(data: Data, completion: @escaping (BLEDeviceInfoDTO) -> Void){
        
        guard let deviceIndex = self.discoveredPeripherals.firstIndex(where: { $0.device.identifier.uuidString == currentSelectedDeviceIdentifier.uuidString }) else{
            DispatchQueue.main.async {
                completion(BLEDeviceInfoDTO([:]))
            }
            return
        }
        
        let radioBattery = data[0]
        let headsetBattery = data[1]
        
        let headsetVersion = data[2...5].to(type: UInt16.self) ?? 0
        let headsetRevNum = data[4...5].to(type: UInt16.self) ?? 0
        
        let radioSTVersion = data[6...9].to(type: UInt16.self) ?? 0
        let radioSTRevNum = data[8...9].to(type: UInt16.self) ?? 0
        
        //For z2 it's transmitter serial number
        let radioSLVersion = data[10...13].to(type: UInt16.self) ?? 0
        
        let ESPVersion = data[14...17].to(type: UInt16.self) ?? 0
        let ESPVersionRevNum = data[16...17].to(type: UInt16.self) ?? 0
         
        var totalRevNumber: UInt16 = 0
        var totalRevNumberCount: UInt16 = 0
        if headsetVersion > 0{
            totalRevNumber += headsetRevNum
            totalRevNumberCount += 1
        }
        
        if radioSTRevNum > 0{
            totalRevNumber += radioSTRevNum
            totalRevNumberCount += 1
        }
        
        if ESPVersionRevNum > 0{
            totalRevNumber += ESPVersionRevNum
            totalRevNumberCount += 1
        }
        
        
        let revNum = ceil(Double(totalRevNumber)/Double(totalRevNumberCount))
        var deviceVersion: ZygoDeviceVersion = .v1
        if revNum >= 2{
            deviceVersion = .v2
        }
        
        
        var versionItem = BLEVersionInfoDTO(headsetVersion: "\(headsetVersion)", radioSTVersion: "\(radioSTVersion)", radioSLVersion: "\(radioSLVersion)", ESPVersion: "\(ESPVersion)", zygoDeviceVersion: deviceVersion)
        
        if deviceVersion == .v2{
            versionItem.radioSLVersion = "\(radioSTVersion)"
            versionItem.radioSTVersion = "0"
        }
        
        let previourInfo = PreferenceManager.shared.deviceInfo
        
        var bleInfo = BLEDeviceInfoDTO([:])
        bleInfo.radioUpdateAt = Date()
        bleInfo.versionInfo = versionItem
        if radioBattery > 100{
            bleInfo.radioBatteryLevel = Int8(100)
        }else{
            bleInfo.radioBatteryLevel = Int8(radioBattery)
        }
        
        bleInfo.deviceIdentifier = self.discoveredPeripherals[deviceIndex].device.identifier.uuidString
        
        if headsetVersion != 0{
            bleInfo.headsetUpdateAt = Date()
            if headsetBattery > 100{
                bleInfo.headsetBatteryLevel = Int8(100)
            }else{
                bleInfo.headsetBatteryLevel = Int8(headsetBattery)
            }
        }else{
            bleInfo.headsetUpdateAt = previourInfo.headsetUpdateAt
            bleInfo.headsetBatteryLevel = previourInfo.headsetBatteryLevel
        }
        
        if !versionItem.isVersionZero(){
            bleInfo.radioUpdateAt = Date()
            PreferenceManager.shared.deviceInfo = bleInfo
        }
        
        print("Headset Version: \(headsetVersion)")
        print("Radio ST Version: \(radioSTVersion)")
        print("Radio SL Version: \(radioSLVersion)")
        print("ESP Version: \(ESPVersion)")
        DispatchQueue.main.async {
            completion(bleInfo)
        }
    }
    
    func readLapData(completion: @escaping (BLELapInfoDTO?) -> Void){
        
        guard let deviceIndex = self.discoveredPeripherals.firstIndex(where: { $0.device.identifier.uuidString == currentSelectedDeviceIdentifier.uuidString }) else{
            completion(nil)
            return
        }
        
        guard let charItem = self.discoveredPeripherals[deviceIndex].services[.data]?.characteristics[.lapData]?.characteristic else{
            completion(nil)
            return
        }
        
        self.discoveredPeripherals[deviceIndex].services[.data]?.characteristics[.lapData]?.onRead = { data in
            print("Device Lap Data \(data.hexString)")
            if data.count < 1{
                completion(nil)
                return
            }
            
            let numberOfLaps = data[0...1].to(type: UInt16.self) ?? 0
            let totalTime = data[2...5].to(type: UInt32.self) ?? 0
            let startStopStatus = Int8(data[6])
            let oldNewStatus = Int8(data[7])
            let serialNumber = data[8...15].hexString
            let lastReadTime = data[16...19].to(type: UInt32.self) ?? 0
            
            //Calculate Accurate lap Time if last lap is missed:
            var recordedTime: UInt32 = 0
            //if startStopStatus == 1{
            //As per new zygo version 2 we don't need to add ending lap cout. It's already counted by new device
            /*if numberOfLaps > 0{
                let timeInSeconds = totalTime/100
                recordedTime = timeInSeconds + (timeInSeconds/UInt32(numberOfLaps))
                numberOfLaps += 1
                // }
            }else{*/
            recordedTime = totalTime/100
            //}
            
            
            var lapInfo = BLELapInfoDTO([:])
            lapInfo.numberOfLaps = numberOfLaps
            lapInfo.totalTime = recordedTime
            lapInfo.startStopStatus = startStopStatus
            lapInfo.oldNewStatus = oldNewStatus
            lapInfo.serialNumber = serialNumber
            lapInfo.lastReadTime = lastReadTime
            print("Number Of laps in read lap data: \(numberOfLaps)")
            PreferenceManager.shared.lapInfo = lapInfo
            DispatchQueue.main.async {
                completion(lapInfo)
            }
            
            //Bytes 0-1:  Laps.  The number of laps counted
            //•Bytes 2-5:  Total time in 1/100thof seconds
            //•Byte 6:  Start-Stop
            //o0 –no bang found (first and last lapped missed)o1 –only start bang found (last lap missed)
            //o2 –only stop bang found (first lap missed)
            //o3 –start and stop bang found (first and last lap counted)
            //•Byte7:  old-newis 0 if old (preserved across a power fail) or 1 if new or 2 if no headset has been read by the radio since power on.  The app can translate “old” to “data from previous swim” (or something equivalent) to present to the user and “data from current swim” for “new.”
            //•Bytes 8-15:  serial number
            //•Bytes 16-19:  Hseconds is the number of seconds since the radio last successfully read the headset data
        }
        
        self.discoveredPeripherals[deviceIndex].device.readValue(for: charItem)
        
    }
    
    func readDiagnosticData(completion: @escaping (String?) -> Void){
        
        guard let deviceIndex = self.discoveredPeripherals.firstIndex(where: { $0.device.identifier.uuidString == currentSelectedDeviceIdentifier.uuidString }) else{
            completion(nil)
            return
        }
        
        guard let charItem = self.discoveredPeripherals[deviceIndex].services[.data]?.characteristics[.diagnosticData]?.characteristic else{
            completion(nil)
            return
        }
        
        self.discoveredPeripherals[deviceIndex].services[.data]?.characteristics[.diagnosticData]?.onRead = { data in
            print("Diagnostic Data \(data.hexString)")
            if data.count < 1{
                completion(nil)
                return
            }
            DispatchQueue.main.async {
                completion(data.hexString)
            }
            
        }
        
        self.discoveredPeripherals[deviceIndex].device.readValue(for: charItem)
        
    }
    
    func readDeviceStatus(onRead: ((String) -> Void)? = nil){
        
        guard let deviceIndex = self.discoveredPeripherals.firstIndex(where: { $0.device.identifier.uuidString == currentSelectedDeviceIdentifier.uuidString }) else{
            onRead?("")
            return
        }
        
        guard let charItem = self.discoveredPeripherals[deviceIndex].services[.data]?.characteristics[.status]?.characteristic else{
            onRead?("")
            return
        }
        
        self.discoveredPeripherals[deviceIndex].services[.data]?.characteristics[.status]?.onRead = { data in
            print("Device Status Data: \(data.hexString)")
            if data.count < 3{
                onRead?("")
                return
            }
            
            let errorCode = data[0...2].hexString
            var fullErrorCode: String = ""
            for index in 0..<errorCode.count{
                let range = NSRange(location: index, length: 1)
                let erCode = (errorCode as NSString).substring(with: range)
                fullErrorCode += "\(erCode)"
                if index % 2 != 0{
                    fullErrorCode += " "
                }
            }
            onRead?(fullErrorCode)
        }
        
        self.discoveredPeripherals[deviceIndex].device.readValue(for: charItem)
        
    }
    
    func readCommunicationMode(onRead: ((String) -> Void)? = nil){
        
        guard let deviceIndex = self.discoveredPeripherals.firstIndex(where: { $0.device.identifier.uuidString == currentSelectedDeviceIdentifier.uuidString }) else{
            onRead?("")
            return
        }
        
        guard let charItem = self.discoveredPeripherals[deviceIndex].services[.data]?.characteristics[.status]?.characteristic else{
            onRead?("")
            return
        }
        
        self.discoveredPeripherals[deviceIndex].services[.data]?.characteristics[.status]?.onRead = { data in
            print("Device Communication Mode: \(data.hexString)")
            if data.count < 4{
                onRead?("")
                return
            }
            
            let communicationMode = data[3...3].hexString
            onRead?(communicationMode)
        }
        
        self.discoveredPeripherals[deviceIndex].device.readValue(for: charItem)
        
    }
    
    func readBTName(onRead: ((String) -> Void)? = nil){
        
        guard let deviceIndex = self.discoveredPeripherals.firstIndex(where: { $0.device.identifier.uuidString == currentSelectedDeviceIdentifier.uuidString }) else{
            onRead?("")
            return
        }
        
        guard let charItem = self.discoveredPeripherals[deviceIndex].services[.data]?.characteristics[.btName]?.characteristic else{
            onRead?("")
            return
        }
        
        self.discoveredPeripherals[deviceIndex].services[.data]?.characteristics[.btName]?.onRead = { data in
            print("BTName Hex: \(data.hexString)")
            if data.count < 4{
                onRead?("")
                return
            }
            
            onRead?(self.hexStringtoAscii(hexString: data.hexString))
        }
        
        self.discoveredPeripherals[deviceIndex].device.readValue(for: charItem)
        
    }
    
    func updateBTName(name: String, onUpdate: ((Bool) -> Void)? = nil){
        
        guard let deviceIndex = self.discoveredPeripherals.firstIndex(where: { $0.device.identifier.uuidString == currentSelectedDeviceIdentifier.uuidString }) else{
            onUpdate?(false)
            return
        }
        
        guard let charItem = self.discoveredPeripherals[deviceIndex].services[.data]?.characteristics[.btName]?.characteristic else{
            onUpdate?(false)
            return
        }
        
        self.discoveredPeripherals[deviceIndex].services[.data]?.characteristics[.btName]?.onWrite = {
            onUpdate?(true)
        }
        
        let dataToWrite = name.data(using: .utf8)!//Data(from: name.asciiValues)
        self.discoveredPeripherals[deviceIndex].device.writeValue(dataToWrite, for: charItem, type: .withResponse)
        
    }
    
    func hexStringtoAscii(hexString : String) -> String {

        let pattern = "(0x)?([0-9a-f]{2})"
        let regex = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let nsString = hexString as NSString
        let matches = regex.matches(in: hexString, options: [], range: NSMakeRange(0, nsString.length))
        let characters = matches.map {
            Character(UnicodeScalar(UInt32(nsString.substring(with: $0.range(at: 2)), radix: 16)!)!)
        }
        return String(characters)
    }
    
    func disableHardwareDataNotification(){
        //Check If any Zygo device is connnected or not
        guard let deviceIndex = self.discoveredPeripherals.firstIndex(where: { $0.device.identifier.uuidString == currentSelectedDeviceIdentifier.uuidString }) else{
            //Device Not Connted
            print("No Zygo Device connected")
            return
        }
        
        let btDevice = self.discoveredPeripherals[deviceIndex]
        
        guard let controlChar = btDevice.services[.data]?.characteristics[.hardwareData]?.characteristic else{
            print("No Control Characteristic Found")
            return
        }
        
        btDevice.device.setNotifyValue(false, for: controlChar)
    }
    
    func enableHardwareDataNotification(completion: @escaping (BLEDeviceInfoDTO) -> Void){
        
        //Check If any Zygo device is connnected or not
        guard let deviceIndex = self.discoveredPeripherals.firstIndex(where: { $0.device.identifier.uuidString == currentSelectedDeviceIdentifier.uuidString }) else{
            //Device Not Connted
            print("No Zygo Device connected")
            return
        }
        
        let btDevice = self.discoveredPeripherals[deviceIndex]
        
        guard let controlChar = btDevice.services[.data]?.characteristics[.hardwareData]?.characteristic else{
            print("No Control Characteristic Found")
            return
        }
        
        self.discoveredPeripherals[deviceIndex].services[.data]?.characteristics[.hardwareData]?.onRead = { data in
            
            //print("Device Info Data")
            if data.count < 1{
                DispatchQueue.main.async {
                    completion(BLEDeviceInfoDTO([:]))
                }
                return
            }
            
            let radioBattery = data[0]
            let headsetBattery = data[1]
            let headsetVersion = data[2...5].to(type: UInt16.self) ?? 0
            let headsetRevNum = data[4...5].to(type: UInt16.self) ?? 0
            let radioSTVersion = data[6...9].to(type: UInt16.self) ?? 0
            let radioSTRevNum = data[8...9].to(type: UInt16.self) ?? 0
            let radioSLVersion = data[10...13].to(type: UInt16.self) ?? 0
            let radioSLVersionRevNum = data[12...13].to(type: UInt16.self) ?? 0
            let ESPVersion = data[14...17].to(type: UInt16.self) ?? 0
            let ESPVersionRevNum = data[16...17].to(type: UInt16.self) ?? 0
            
            var totalRevNumber: UInt16 = 0
            var totalRevNumberCount: UInt16 = 0
            if headsetVersion > 0{
                totalRevNumber += headsetRevNum
                totalRevNumberCount += 1
            }
            
            if radioSTRevNum > 0{
                totalRevNumber += radioSTRevNum
                totalRevNumberCount += 1
            }
            
            if radioSLVersionRevNum > 0{
                totalRevNumber += radioSLVersionRevNum
                totalRevNumberCount += 1
            }
            
            if ESPVersionRevNum > 0{
                totalRevNumber += ESPVersionRevNum
                totalRevNumberCount += 1
            }
            
            let revNum = totalRevNumber/totalRevNumberCount
            var deviceVersion: ZygoDeviceVersion = .v1
            if revNum >= 2{
                deviceVersion = .v2
            }
            
            let versionItem = BLEVersionInfoDTO(headsetVersion: "\(headsetVersion)", radioSTVersion: "\(radioSTVersion)", radioSLVersion: "\(radioSLVersion)", ESPVersion: "\(ESPVersion)", zygoDeviceVersion: deviceVersion)
            
            let previourInfo = PreferenceManager.shared.deviceInfo
            
            var bleInfo = BLEDeviceInfoDTO([:])
            bleInfo.radioUpdateAt = Date()
            bleInfo.versionInfo = versionItem
            if radioBattery > 100{
                bleInfo.radioBatteryLevel = Int8(100)
            }else{
                bleInfo.radioBatteryLevel = Int8(radioBattery)
            }
            
            bleInfo.deviceIdentifier = self.discoveredPeripherals[deviceIndex].device.identifier.uuidString
            
            if headsetVersion != 0{
                bleInfo.headsetUpdateAt = Date()
                if headsetBattery > 100{
                    bleInfo.headsetBatteryLevel = Int8(100)
                }else{
                    bleInfo.headsetBatteryLevel = Int8(headsetBattery)
                }
            }else{
                bleInfo.headsetUpdateAt = previourInfo.headsetUpdateAt
                bleInfo.headsetBatteryLevel = previourInfo.headsetBatteryLevel
            }
            
            if !versionItem.isVersionZero(){
                bleInfo.radioUpdateAt = Date()
                PreferenceManager.shared.deviceInfo = bleInfo
            }
            
            /*print("Headset Version: \(headsetVersion)")
            print("Radio ST Version: \(radioSTVersion)")
            print("Radio SL Version: \(radioSLVersion)")
            print("ESP Version: \(ESPVersion)")*/
            DispatchQueue.main.async {
                completion(bleInfo)
            }
        }
        
        btDevice.device.setNotifyValue(true, for: controlChar)
    }
    
    func disableLapDataNotification(){
        //Check If any Zygo device is connnected or not
        guard let deviceIndex = self.discoveredPeripherals.firstIndex(where: { $0.device.identifier.uuidString == currentSelectedDeviceIdentifier.uuidString }) else{
            //Device Not Connted
            print("No Zygo Device connected")
            return
        }
        
        let btDevice = self.discoveredPeripherals[deviceIndex]
        
        guard let controlChar = btDevice.services[.data]?.characteristics[.lapData]?.characteristic else{
            print("No Control Characteristic Found")
            return
        }
        
        btDevice.device.setNotifyValue(false, for: controlChar)
    }
    
    func hexStringToData(_ hex: String) -> Data? {
        var hexStr = hex
        var data = Data()

        // Ensure the hex string has an even number of characters
        if hexStr.count % 2 != 0 {
            return nil
        }

        while hexStr.count > 0 {
            let subIndex = hexStr.index(hexStr.startIndex, offsetBy: 2)
            let byteString = String(hexStr[..<subIndex])
            hexStr = String(hexStr[subIndex...])

            if let byte = UInt8(byteString, radix: 16) {
                data.append(byte)
            } else {
                return nil // Invalid hex string
            }
        }

        return data
    }
    
    func enableLapDataNotification(completion: @escaping (BLELapInfoDTO?) -> Void){
        
        //Check If any Zygo device is connnected or not
        guard let deviceIndex = self.discoveredPeripherals.firstIndex(where: { $0.device.identifier.uuidString == currentSelectedDeviceIdentifier.uuidString }) else{
            //Device Not Connted
            print("No Zygo Device connected")
            return
        }
        
        let btDevice = self.discoveredPeripherals[deviceIndex]
        
        guard let controlChar = btDevice.services[.data]?.characteristics[.lapData]?.characteristic else{
            print("No Control Characteristic Found")
            return
        }
        
        self.discoveredPeripherals[deviceIndex].services[.data]?.characteristics[.lapData]?.onRead = { data in
            print("Device Lap Data \(data.hexString)")
            if data.count < 1{
                completion(nil)
                return
            }
            
            let numberOfLaps = data[0...1].to(type: UInt16.self) ?? 0
            let totalTime = data[2...5].to(type: UInt32.self) ?? 0
            let startStopStatus = Int8(data[6])
            let oldNewStatus = Int8(data[7])
            
            let serialNumber = data[8...15].hexString
            let lastReadTime = data[16...19].to(type: UInt32.self) ?? 0
            
            //Calculate Accurate lap Time if last lap is missed:
            var recordedTime: UInt32 = 0
            //if startStopStatus == 1{
            //As per new zygo version 2 we don't need to add ending lap cout. It's already counted by new device
                /*if numberOfLaps > 0{
                    let timeInSeconds = totalTime/100
                    recordedTime = timeInSeconds + (timeInSeconds/UInt32(numberOfLaps))
                    numberOfLaps += 1
               // }
            }else{*/
            recordedTime = totalTime/100
            //}
            
            var lapInfo = BLELapInfoDTO([:])
            lapInfo.numberOfLaps = numberOfLaps
            lapInfo.totalTime = recordedTime
            lapInfo.startStopStatus = startStopStatus
            lapInfo.oldNewStatus = oldNewStatus
            lapInfo.serialNumber = serialNumber
            lapInfo.lastReadTime = lastReadTime
            print("Number Of laps in notification: \(numberOfLaps)")
            print("Last Read time: \(lastReadTime)")
            if lastReadTime == 0 || lastReadTime == 20{
                self.readInternalHardwareInfo { bleInfo in
                    if !PreferenceManager.shared.deviceInfo.versionInfo.isVersionZero(){
                        if PreferenceManager.shared.deviceInfo.versionInfo.headsetVersion != "0"{
                            var deviceInfo = PreferenceManager.shared.deviceInfo
                            deviceInfo.headsetUpdateAt = Date()
                            deviceInfo.radioUpdateAt = Date()
                            PreferenceManager.shared.deviceInfo = deviceInfo
                        }
                    }
                    
                    PreferenceManager.shared.lapInfo = lapInfo
                    DispatchQueue.main.async {
                        completion(lapInfo)
                    }
                }
            }else{
                if !PreferenceManager.shared.deviceInfo.versionInfo.isVersionZero(){
                    if PreferenceManager.shared.deviceInfo.versionInfo.headsetVersion != "0"{
                        var deviceInfo = PreferenceManager.shared.deviceInfo
                        deviceInfo.headsetUpdateAt = Date()
                        deviceInfo.radioUpdateAt = Date()
                        PreferenceManager.shared.deviceInfo = deviceInfo
                    }
                }
                
                PreferenceManager.shared.lapInfo = lapInfo
                DispatchQueue.main.async {
                    completion(lapInfo)
                }
            }
        }
        
        btDevice.device.setNotifyValue(true, for: controlChar)
    }
    
    //MARK: - DFU Process
    private var onDFUProgress: ((Float) -> Void)?
    private var onDFUStatusUpdate: ((DFUStatus) -> Void)?
    private var onDFUCompletion: ((Bool) -> Void)?
    private var firmwareURL: URL!
    private var tragatedDevice: TargetDeviceCode = .ESP
    
    func startTimeOutTimer(){
        self.stopScanning()
        self.timeOutTimer = Timer(timeInterval: 20.0, repeats: false, block: { timerObj in
            self.onDFUStatusUpdate?(.TimeOutError)
        })
        RunLoop.main.add(self.timeOutTimer!, forMode: .common)
    }
    
    func stopTimerOutTimer(){
        self.timeOutTimer?.invalidate()
        self.timeOutTimer = nil
    }
    
    
    func resetDFUProcess(){
        self.onDFUProgress = nil
        self.onDFUStatusUpdate = nil
        self.onDFUCompletion = nil
    }
    
    func startDFUProcess(firmwareURL: URL, target: TargetDeviceCode, progress: @escaping (Float) -> Void, statusUpdate: @escaping (DFUStatus) -> Void, completion: @escaping (Bool) -> Void){
        
        self.onDFUProgress = progress
        self.onDFUStatusUpdate = statusUpdate
        self.onDFUCompletion = completion
        self.firmwareURL = firmwareURL
        self.tragatedDevice = target
        
        //Check If any Zygo device is connnected or not
        guard let deviceIndex = self.discoveredPeripherals.firstIndex(where: { $0.device.identifier.uuidString == currentSelectedDeviceIdentifier.uuidString }) else{
            //Device Not Connted
            print("No Zygo Device connected")
            self.onDFUStatusUpdate?(.FirmwareUpgradedFailed)
            self.onDFUCompletion?(false)
            return
        }
        
        let btDevice = self.discoveredPeripherals[deviceIndex]
        
        guard let controlChar = btDevice.services[.OTA]?.characteristics[.otaControl]?.characteristic else{
            print("No Control Characteristic Found")
            self.onDFUStatusUpdate?(.FirmwareUpgradedFailed)
            self.onDFUCompletion?(false)
            return
        }
        
        
        self.discoveredPeripherals[deviceIndex].services[.OTA]?.characteristics[.otaControl]?.onRead = { data in
            
            self.stopTimerOutTimer()
            print("OTA Control Subscribe ACK: \(data)")
            
            if data.count < 1{
                self.discoveredPeripherals[deviceIndex].services[.OTA]?.characteristics[.otaControl]?.onRead = nil
                self.onDFUStatusUpdate?(.FailedToSubscribedRequest)
                self.onDFUCompletion?(false)
                return
            }
            
            let bleStatus = data.to(type: UInt8.self) ?? 0
            if bleStatus == 2{//Failed to subscribe request
                self.discoveredPeripherals[deviceIndex].services[.OTA]?.characteristics[.otaControl]?.onRead = nil
                self.onDFUStatusUpdate?(.FailedToSubscribedRequest)
                self.onDFUCompletion?(false)
                return
            }
            
            self.onDFUStatusUpdate?(.SubscribeDevice)
            let fileSize = Helper.shared.sizeForLocalFilePath(filePath: self.firmwareURL)
            print("File Actual Size: \(fileSize)")
            
            let targetVal = self.tragatedDevice.rawValue
            
            let writeData = NSMutableData()
            
            
            writeData.append(Data(from: targetVal))
            writeData.append(Data(from: UInt32(bigEndian:fileSize).byteSwapped))
            writeData.append(UInt8(0).data)
            
            self.sendTargetDevice(writeData as Data)
        }
        
        self.startTimeOutTimer()
        btDevice.device.setNotifyValue(true, for: controlChar)
    }
    
    private func sendTargetDevice(_ value: Data){
        guard let deviceIndex = self.discoveredPeripherals.firstIndex(where: { $0.device.identifier.uuidString == currentSelectedDeviceIdentifier.uuidString }) else{
            //Device Not Connted
            print("No Zygo Device connected")
            self.onDFUStatusUpdate?(.FirmwareUpgradedFailed)
            self.onDFUCompletion?(false)
            return
        }
        
        let btDevice = self.discoveredPeripherals[deviceIndex]
        
        guard let controlChar = btDevice.services[.OTA]?.characteristics[.otaControl]?.characteristic else{
            print("No Control Characteristic Found")
            self.onDFUStatusUpdate?(.FirmwareUpgradedFailed)
            self.onDFUCompletion?(false)
            return
        }
        
        self.discoveredPeripherals[deviceIndex].services[.OTA]?.characteristics[.otaControl]?.onWrite = {
            print("OTA Control Device Target Write")
            self.startTimeOutTimer()
        }
        
        self.discoveredPeripherals[deviceIndex].services[.OTA]?.characteristics[.otaControl]?.onRead = { data in
            print("OTA Control Device Target ACK: \(data)")
            
            if data.count < 1{
                self.discoveredPeripherals[deviceIndex].services[.OTA]?.characteristics[.otaControl]?.onRead = nil
                self.onDFUStatusUpdate?(.FailedToSetDeviceId)
                self.onDFUCompletion?(false)
                return
            }
            
            let bleStatus = data.to(type: UInt8.self) ?? 0
            if bleStatus == 4{//Failed to Set Device ID
                self.discoveredPeripherals[deviceIndex].services[.OTA]?.characteristics[.otaControl]?.onRead = nil
                self.onDFUStatusUpdate?(.FailedToSetDeviceId)
                self.onDFUCompletion?(false)
                return
            }
            
            self.stopTimerOutTimer()
            self.onDFUStatusUpdate?(.SetTargetDevice)
            self.readDeviceStatus()
            self.sendTransferRequest(.START)
        }
        
        print("Set Target Device: \(value.hexString)")
        btDevice.device.writeValue(value, for: controlChar, type: .withResponse)
        
    }
    
    private func sendTransferRequest(_ request: TransferRequestStatus){
        
        guard let deviceIndex = self.discoveredPeripherals.firstIndex(where: { $0.device.identifier.uuidString == currentSelectedDeviceIdentifier.uuidString }) else{
            //Device Not Connted
            print("No Zygo Device connected")
            self.onDFUStatusUpdate?(.FirmwareUpgradedFailed)
            self.onDFUCompletion?(false)
            return
        }
        
        self.discoveredPeripherals[deviceIndex].services[.OTA]?.characteristics[.otaControl]?.onWrite = nil
        let btDevice = self.discoveredPeripherals[deviceIndex]
        
        guard let controlChar = btDevice.services[.OTA]?.characteristics[.otaControl]?.characteristic else{
            print("No Control Characteristic Found")
            self.onDFUStatusUpdate?(.FirmwareUpgradedFailed)
            self.onDFUCompletion?(false)
            return
        }
        
        self.discoveredPeripherals[deviceIndex].services[.OTA]?.characteristics[.otaControl]?.onWrite = {
            print("OTA Control Request Write")
            
        }
        
        self.discoveredPeripherals[deviceIndex].services[.OTA]?.characteristics[.otaControl]?.onRead = { data in
            //self.discoveredPeripherals[deviceIndex].services[.OTA]?.characteristics[.otaControl]?.onRead = nil
            print("OTA Control Transfer Request Start ACK: \(data)")
            if data.count < 1{
                self.discoveredPeripherals[deviceIndex].services[.OTA]?.characteristics[.otaControl]?.onRead = nil
                self.onDFUStatusUpdate?(.FailedToStartTransferRequest)
                self.onDFUCompletion?(false)
                return
            }
            
            let bleStatus = data.to(type: UInt8.self) ?? 0
            if bleStatus == 6{//Failed to Start Transfer Request
                self.discoveredPeripherals[deviceIndex].services[.OTA]?.characteristics[.otaControl]?.onRead = nil
                self.onDFUStatusUpdate?(.FailedToStartTransferRequest)
                self.onDFUCompletion?(false)
                return
            }
            
            self.onDFUStatusUpdate?(.TransferRequestStart)
            self.setMTUSize()
        }
        
        let value = request.rawValue.data
        
        btDevice.device.writeValue(value, for: controlChar, type: .withResponse)
    }
    
    
    // Data may be sent in up-to-20-bytes packets.
    var offset: UInt32 = 0
    var bytesToSend: UInt32 = 0
    var fileData: Data!
    
    func setMTUSize(){
        
        guard let deviceIndex = self.discoveredPeripherals.firstIndex(where: { $0.device.identifier.uuidString == currentSelectedDeviceIdentifier.uuidString }) else{
            //Device Not Connted
            print("No Zygo Device connected")
            self.onDFUStatusUpdate?(.FirmwareUpgradedFailed)
            self.onDFUCompletion?(false)
            return
        }
        
        let btDevice = self.discoveredPeripherals[deviceIndex]
        
        btDevice.device.maximumWriteValueLength(for: .withResponse)
        print("Set MTU Size")
        //self.perform(#selector(self.transferFile), with: nil, afterDelay: 2.0)
        self.startTransferFileDelayTimer()
    }
    
    var delayTimer: Timer?
    func startTransferFileDelayTimer(){
        self.delayTimer?.invalidate()
        self.delayTimer = nil
        
        self.delayTimer = Timer(timeInterval: 2.0, repeats: false, block: { timerObj in
            self.transferFile()
        })
        
        RunLoop.main.add(self.delayTimer!, forMode: .common)
    }
    
    func transferFile(){
        
        do{
            
            guard let deviceIndex = self.discoveredPeripherals.firstIndex(where: { $0.device.identifier.uuidString == currentSelectedDeviceIdentifier.uuidString }) else{
                //Device Not Connted
                print("No Zygo Device connected")
                self.onDFUStatusUpdate?(.FirmwareUpgradedFailed)
                self.onDFUCompletion?(false)
                return
            }
            
            let btDevice = self.discoveredPeripherals[deviceIndex]
            
            guard let controlChar = btDevice.services[.OTA]?.characteristics[.otaData]?.characteristic else{
                print("No Control Characteristic Found")
                return
            }
            
            
            self.fileData = try Data(contentsOf: self.firmwareURL)
            
            // Data may be sent in up-to-20-bytes packets.
            self.offset = 0
            self.bytesToSend = UInt32(fileData.count)
            
            
            self.discoveredPeripherals[deviceIndex].services[.OTA]?.characteristics[.otaData]?.onWrite = {
                print("OTA Data File Write")
                self.startTimeOutTimer()
            }
            
            self.discoveredPeripherals[deviceIndex].services[.OTA]?.characteristics[.otaData]?.onRead = { data in
                print("OTA Data File Read")
            }
            
            self.discoveredPeripherals[deviceIndex].services[.OTA]?.characteristics[.otaControl]?.onRead = { data in
                print("OTA Control File Transfer ACK: \(data)")
                self.stopTimerOutTimer()
                let transferStatus = data.to(type: UInt8.self) ?? 0
                print(transferStatus)
                if transferStatus == 10{
                    //Terminate the process. And show error message to restart the device and start process again.
                    self.sendTransferRequestComplete()
                    self.discoveredPeripherals[deviceIndex].services[.OTA]?.characteristics[.otaControl]?.onRead = nil
                    self.onDFUStatusUpdate?(.FailedToSendData)
                    return
                }
                
                
                let totalBytes = UInt32(self.fileData.count)
                let currentProgress = 1 - (Float(self.bytesToSend)/Float(totalBytes))
                
                self.onDFUProgress?(currentProgress)
                print("Progress: \(currentProgress)")
                
                if self.bytesToSend <= 0{
                    //Send Request Status done
                    self.stopTimerOutTimer()
                    print("File Transfer Complete at: \(Date().timeIntervalSince1970)")
                    self.sendTransferRequestComplete()
                    return
                }
                
                let packetLength = min(self.bytesToSend, self.packetSize)
                let packet = self.fileData.subdata(in: Int(self.offset) ..< Int(self.offset + packetLength))
                
                //let packetUUID = controlChar.uuid.uuidString
                
                //print("Writing to characteristic \(packetUUID)...")
                //print("peripheral.writeValue(0x\(packet.hexString), for: \(packetUUID), type: .withResponse)")
                
                //peripheral.writeValue(packet, for: characteristic, type: .withoutResponse)
                btDevice.device.writeValue(packet, for: controlChar, type: .withResponse)
                
                self.offset += packetLength
                self.bytesToSend -= packetLength
            }
            
            self.onDFUStatusUpdate?(.TransferFile)
            print("File Transfer Start at: \(Date().timeIntervalSince1970)")
            //repeat {
            let packetLength = min(bytesToSend, packetSize)
            let packet = self.fileData.subdata(in: Int(offset) ..< Int(offset + packetLength))
            
            //let packetUUID = controlChar.uuid.uuidString
            
            //print("Writing to characteristic \(packetUUID)...")
            //print("peripheral.writeValue(0x\(packet.hexString), for: \(packetUUID), type: .withResponse)")
            
            //peripheral.writeValue(packet, for: characteristic, type: .withoutResponse)
            btDevice.device.writeValue(packet, for: controlChar, type: .withResponse)
            
            offset += packetLength
            bytesToSend -= packetLength
            
            if bytesToSend <= 0{
                //Send Request Status done
                self.sendTransferRequestComplete()
            }
            
            //} while bytesToSend > 0
            
            
            
        }catch{
            self.onDFUStatusUpdate?(.FirmwareUpgradedFailed)
            self.onDFUCompletion?(false)
            print("Failed to convert file to data")
        }
    }
    
    func terminateTransferFile(){
        self.bytesToSend = 0
    }
    
    private func fileTransferInChucks(fileData: Data, controlChar: CBCharacteristic, btDevice: BTDevice){
        let packetUUID = controlChar.uuid.uuidString
        print("Writing to characteristic \(packetUUID)...")
        //peripheral.writeValue(packet, for: characteristic, type: .withoutResponse)
        btDevice.device.writeValue(fileData, for: controlChar, type: .withoutResponse)
    }
    
    private func sendTransferRequestComplete(){
        
        self.stopTimerOutTimer()
        
        guard let deviceIndex = self.discoveredPeripherals.firstIndex(where: { $0.device.identifier.uuidString == currentSelectedDeviceIdentifier.uuidString }) else{
            //Device Not Connted
            print("No Zygo Device connected")
            self.onDFUStatusUpdate?(.FirmwareUpgradedFailed)
            self.onDFUCompletion?(false)
            return
        }
        
        self.discoveredPeripherals[deviceIndex].services[.OTA]?.characteristics[.otaControl]?.onWrite = nil
        let btDevice = self.discoveredPeripherals[deviceIndex]
        
        guard let controlChar = btDevice.services[.OTA]?.characteristics[.otaControl]?.characteristic else{
            print("No Control Characteristic Found")
            self.stopTimerOutTimer()
            self.onDFUStatusUpdate?(.FirmwareUpgradedFailed)
            self.onDFUCompletion?(false)
            return
        }
        
        self.discoveredPeripherals[deviceIndex].services[.OTA]?.characteristics[.otaControl]?.onWrite = {
            print("OTA Control Request Done Write")
            self.stopTimerOutTimer()
            self.onDFUStatusUpdate?(.TransferRequestStop)
        }
        
        self.discoveredPeripherals[deviceIndex].services[.OTA]?.characteristics[.otaControl]?.onRead = { data in
            self.stopTimerOutTimer()
            //self.discoveredPeripherals[deviceIndex].services[.OTA]?.characteristics[.otaControl]?.onRead = nil
            
            let transferStatus = data.to(type: UInt8.self) ?? 0
            print(transferStatus)
            if transferStatus == 8{//Failed to transfer done
                self.discoveredPeripherals[deviceIndex].services[.OTA]?.characteristics[.otaControl]?.onRead = nil
                self.onDFUCompletion?(false)
                self.onDFUStatusUpdate?(.FailedToTransferDone)
                return
            }
            
            if self.tragatedDevice == .ESP{
                //Here we should wait for device until 100% processing not completed
                
                print("OTA Control Request Done Read")
                let transferCompleteStatus = UInt8(data[0])
                if transferCompleteStatus == 0{
                    if data.count >= 2{
                        let progressCompleted = UInt8(data[1])
                        print("Process Completed: \(progressCompleted)%")
                        self.onDFUStatusUpdate?(.TransferProccess(value: progressCompleted))
                    }
                }else{
                    if transferCompleteStatus == 9{
                        
                    }else if transferCompleteStatus == 7{
                        
                        self.discoveredPeripherals[deviceIndex].services[.OTA]?.characteristics[.otaControl]?.onRead = nil
                            self.onDFUStatusUpdate?(.FirmwareUpgraded)
                            self.onDFUCompletion?(true)
                    }else{
                        
                        self.discoveredPeripherals[deviceIndex].services[.OTA]?.characteristics[.otaControl]?.onRead = nil
                        
                        self.onDFUStatusUpdate?(.FirmwareUpgradedFailed)
                        self.onDFUCompletion?(false)
                    }
                }
            }else{
                print("OTA Control Request Done Read")
                let transferCompleteStatus = UInt8(data[0])
                if transferCompleteStatus == 9{
                }else if transferCompleteStatus == 7{
                    self.discoveredPeripherals[deviceIndex].services[.OTA]?.characteristics[.otaControl]?.onRead = nil
                    
                    if self.tragatedDevice == .SILABS_HEADSET || self.tragatedDevice == .SILABS_Z2_HEADSET{
                        //Here Check Headset file Progress from radio to headset
                        self.checkHeadsetProgressStatusInternal()
                    }else{
                        self.onDFUStatusUpdate?(.FirmwareUpgraded)
                        self.onDFUCompletion?(true)
                    }
                }else{
                    self.discoveredPeripherals[deviceIndex].services[.OTA]?.characteristics[.otaControl]?.onRead = nil
                    self.onDFUStatusUpdate?(.FirmwareUpgradedFailed)
                    self.onDFUCompletion?(false)
                }
                
            }
            
        }
        
        let value = TransferRequestStatus.STOP.rawValue.data
        print("Transfer Done: \(value)")
        btDevice.device.writeValue(value, for: controlChar, type: .withResponse)
    }
    
    func checkHeadsetProgressStatusInternal(){
        self.checkHeadsetProgess { dfuStaus, progressStatus in
            DispatchQueue.main.async {
                print("DFU Status: \(dfuStaus)")
                if dfuStaus == 9{
                    print("Break Here")
                }
                    print("progressStatus Status: \(progressStatus)")
                    if progressStatus == 0 && dfuStaus < 7{//In Progress
                        self.onDFUStatusUpdate?(.HeadsetProgressStatus)
                    }else if progressStatus == 1{//In Progress
                        self.onDFUStatusUpdate?(.HeadsetProgressStatus)
                     }else if progressStatus == 2{//Pass
                        //Here we should wait for 10 seconds as per client suggested to get connected again.
                         self.startReconnectAfterTenSeconds()
                    }else if progressStatus == 4{//Fail
                        self.onDFUStatusUpdate?(.FirmwareUpgradedFailed)
                        self.onDFUCompletion?(false)
                    }else if progressStatus == 5{//Time Out
                        self.onDFUStatusUpdate?(.TimeOutError)
                    }else{//Unknown
                        self.onDFUStatusUpdate?(.FirmwareUpgraded)
                        self.onDFUCompletion?(true)
                    }
            }
            
        }
    }
    
    var headsetReconnectTimer: Timer?
    func startReconnectAfterTenSeconds(){
        self.stopReconnectAfterTenSeconds()
        
        self.headsetReconnectTimer = Timer(timeInterval: 10.0, repeats: false, block: { timerObj in
            self.startReadLastSyncTimer()
        })
        
        RunLoop.main.add(headsetReconnectTimer!, forMode: .common)
    }
    
    func stopReconnectAfterTenSeconds(){
        headsetReconnectTimer?.invalidate()
        headsetReconnectTimer = nil
    }
    
    var readLastSyncTimer: Timer?
    func startReadLastSyncTimer(){
        self.stopReadLastSyncTimer()
        self.readLastSyncTimer = Timer(timeInterval: 1.0, repeats: true, block: { timerOBJ in
            self.readLapData { lapInfo in
                if lapInfo?.lastReadTime ?? 100 <= 30{
                    self.stopReadLastSyncTimer()
                    self.onDFUStatusUpdate?(.FirmwareUpgraded)
                    self.onDFUCompletion?(true)
                }
            }
        })
        
        RunLoop.main.add(self.readLastSyncTimer!, forMode: .common)
    }
    
    func stopReadLastSyncTimer(){
        readLastSyncTimer?.invalidate()
        readLastSyncTimer = nil
    }
    
    func getHeadsetProgressStatus(){
        self.checkHeadsetProgess { dfuStaus, progressStatus in
            DispatchQueue.main.async {
                print("DFU Status: \(dfuStaus)")
                if dfuStaus == 9{
                    print("Break Here")
                }
                print("progressStatus Status: \(progressStatus)")
                if progressStatus == 0 && dfuStaus < 7{//In Progress
                    self.onDFUStatusUpdate?(.HeadsetProgressStatus)
                }else if progressStatus == 1{//In Progress
                    self.onDFUStatusUpdate?(.HeadsetProgressStatus)
                 }else if progressStatus == 2{//Pass
                     //Here we should wait for 10 seconds as per client suggested to get connected again.
                      self.startReconnectAfterTenSeconds()
                }else if progressStatus == 4{//Fail
                    self.onDFUStatusUpdate?(.FirmwareUpgradedFailed)
                    self.onDFUCompletion?(false)
                }else if progressStatus == 5{//Time Out
                    self.onDFUStatusUpdate?(.TimeOutError)
                }else{//Unknown
                    self.onDFUStatusUpdate?(.FirmwareUpgraded)
                    self.onDFUCompletion?(true)
                }
            }
            
        }
    }
    
    func checkHeadsetProgess(completion: @escaping (Int16, Int16) -> Void){
        
        guard let deviceIndex = self.discoveredPeripherals.firstIndex(where: { $0.device.identifier.uuidString == currentSelectedDeviceIdentifier.uuidString }) else{
            completion(0,0)
            return
        }
        
        guard let charItem = self.discoveredPeripherals[deviceIndex].services[.data]?.characteristics[.status]?.characteristic else{
            completion(0,0)
            return
        }
        
        self.discoveredPeripherals[deviceIndex].services[.data]?.characteristics[.status]?.onRead = { data in
            print("Device Status Data: \(data.hexString)")
            if data.count < 1{
                completion(0,0)
                return
            }
            
            if data.count >= 3{
                let dfuStatus = Int16(data[0])
                let updateStatus = Int16(data[2])
                completion(dfuStatus,updateStatus)
            }else{
                let dfuStatus = Int16(data[0])
                completion(dfuStatus,0)
            }
        }
        
        self.discoveredPeripherals[deviceIndex].device.readValue(for: charItem)
    }
    
    func setCommunicationNormal(completion: @escaping (Bool) -> Void){
        
        guard let deviceIndex = self.discoveredPeripherals.firstIndex(where: { $0.device.identifier.uuidString == currentSelectedDeviceIdentifier.uuidString }) else{
            completion(false)
            return
        }
        
        guard let charItem = self.discoveredPeripherals[deviceIndex].services[.data]?.characteristics[.status]?.characteristic else{
            completion(false)
            return
        }
        
        if let value = "35CC4330".hexadecimal{
            self.discoveredPeripherals[deviceIndex].device.writeValue(value, for: charItem, type: .withResponse)
        }
        
        completion(true)
    }
    
    func setCommunicationQuick(completion: @escaping (Bool) -> Void){
        
        guard let deviceIndex = self.discoveredPeripherals.firstIndex(where: { $0.device.identifier.uuidString == currentSelectedDeviceIdentifier.uuidString }) else{
            completion(false)
            return
        }
        
        guard let charItem = self.discoveredPeripherals[deviceIndex].services[.data]?.characteristics[.status]?.characteristic else{
            completion(false)
            return
        }
        
        if let value = "35CC4331".hexadecimal{
            self.discoveredPeripherals[deviceIndex].device.writeValue(value, for: charItem, type: .withResponse)
        }
        
        completion(true)
    }
}

//MARK: - Central Manager Delegates
extension BluetoothManager: CBCentralManagerDelegate{
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        switch central.state {
        case .unknown:
            print("Bluetooth status is UNKNOWN")
        case .resetting:
            print("Bluetooth status is RESETTING")
        case .unsupported:
            print("Bluetooth status is UNSUPPORTED")
        case .unauthorized:
            print("Bluetooth status is UNAUTHORIZED")
        case .poweredOff:
            print("Bluetooth status is POWERED OFF")
            //self.discoveredPeripherals.removeAll(keepingCapacity: true)
        case .poweredOn:
            print("Bluetooth status is POWERED ON")
            self.startScanning(onScanning: self.onScanning)
        @unknown default:
            print("New State")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let index = self.discoveredPeripherals.firstIndex(where: { $0.device.identifier == peripheral.identifier }){
            self.discoveredPeripherals.remove(at: index)
            self.discoveredPeripherals.insert(BTDevice(device: peripheral, rssi: RSSI, services: self.defaulServices), at: index)
        }else{
            self.discoveredPeripherals.append(BTDevice(device: peripheral, rssi: RSSI, services: self.defaulServices))
        }
        
        DispatchQueue.main.async {
            self.onScanning?(self.discoveredPeripherals)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        guard let device = self.discoveredPeripherals.filter({ $0.device.identifier.uuidString == peripheral.identifier.uuidString }).first else{
            return
        }
        
        self.currentSelectedDeviceIdentifier = peripheral.identifier
        
        DispatchQueue.main.async { [weak self] in
            self?.onConnect?(device)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        guard let device = self.discoveredPeripherals.filter({ $0.device.identifier.uuidString == peripheral.identifier.uuidString }).first else{
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.onFailedToConnect?(device)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        if self.currentSelectedDeviceIdentifier.uuidString == peripheral.identifier.uuidString{
            self.currentSelectedDeviceIdentifier = UUID()
        }
        
        guard let device = self.discoveredPeripherals.filter({ $0.device.identifier.uuidString == peripheral.identifier.uuidString }).first else{
            return
        }
        DispatchQueue.main.async { [weak self] in
            print("Device disconnected.......")
            self?.onDFUStatusUpdate?(.DeviceDisconnected)
            //self?.onDFUCompletion?(false)
            self?.onDisconnect?(device)
            self?.onDeviceDisconnect?()
            //NotificationCenter.default.post(name: .didHideMenu, object: nil)
        }
    }
}

//MARK: - CBPeripheral Delegate
extension BluetoothManager: CBPeripheralDelegate{
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("Services: \(peripheral.services ?? [])")
        
        guard let deviceIndex = self.discoveredPeripherals.firstIndex(where: { $0.device.identifier.uuidString == peripheral.identifier.uuidString }) else{
            return
        }
        
        for service in peripheral.services ?? []{
            
            guard let serviceItem = ZygoService(rawValue: service.uuid.uuidString) else{
                return
            }
            
            self.discoveredPeripherals[deviceIndex].services[serviceItem]?.service = service
            self.discoveredPeripherals[deviceIndex].services[serviceItem]?.characteristics = self.defaulCharacteristics[serviceItem] ?? [:]
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else{
                return
            }
            self?.onServices?(strongSelf.discoveredPeripherals[deviceIndex])
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        print("Characteristics: \(service.characteristics ?? [])")
        
        guard let deviceIndex = self.discoveredPeripherals.firstIndex(where: { $0.device.identifier.uuidString == peripheral.identifier.uuidString }) else{
            return
        }
        
        guard let serviceItem = ZygoService(rawValue: service.uuid.uuidString) else{
            return
        }
        
        for characteristic in service.characteristics ?? []{
            
            guard let charItem = ZygoCharacteristic(rawValue: characteristic.uuid.uuidString) else{
                return
            }
            
            self.discoveredPeripherals[deviceIndex].services[serviceItem]?.characteristics[charItem]?.characteristic = characteristic
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else{
                return
            }
            if strongSelf.discoveredPeripherals[deviceIndex].services[.OTA]?.characteristics.filter({ $0.value.characteristic != nil }).count ?? 0 == 2 && strongSelf.discoveredPeripherals[deviceIndex].services[.data]?.characteristics.filter({ $0.value.characteristic != nil }).count ?? 0 == 6{
                self?.onCharacteristics?(strongSelf.discoveredPeripherals[deviceIndex])
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        //print("Received Data for Char: \(characteristic.uuid.uuidString)")
        guard let valueData = characteristic.value else{
            return
        }
        
        //print("Received Data: \(valueData.hexString)")
        
        guard let deviceIndex = self.discoveredPeripherals.firstIndex(where: { $0.device.identifier.uuidString == peripheral.identifier.uuidString }) else{
            return
        }
        
        if let charItem = ZygoCharacteristic(rawValue: characteristic.uuid.uuidString){
            self.discoveredPeripherals[deviceIndex].services[.data]?.characteristics[charItem]?.onRead?(valueData)
            self.discoveredPeripherals[deviceIndex].services[.OTA]?.characteristics[charItem]?.onRead?(valueData)
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("Write Data for Char: \(characteristic.uuid.uuidString)")
        
        guard let deviceIndex = self.discoveredPeripherals.firstIndex(where: { $0.device.identifier.uuidString == peripheral.identifier.uuidString }) else{
            return
        }
        
        if let charItem = ZygoCharacteristic(rawValue: characteristic.uuid.uuidString){
            self.discoveredPeripherals[deviceIndex].services[.OTA]?.characteristics[charItem]?.onWrite?()
            self.discoveredPeripherals[deviceIndex].services[.data]?.characteristics[charItem]?.onWrite?()
        }
    }
    
    func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
        print("Device is READY for write without response")
    }
}

//MARK: - BLE Notification Delegates
extension BluetoothManager{
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("didUpdateNotificationStateFor")
    }
}

enum TargetDeviceCode: UInt8{
    case ESP = 18
    case ST = 19
    case SILABS_RADIO = 20
    case SILABS_HEADSET = 21
    case SILABS_Z2_RADIO = 22
    case SILABS_Z2_HEADSET = 23
}

enum TransferRequestStatus: UInt8{
    case START = 16
    case STOP = 17
}

enum DFUStatus{
    case SubscribeDevice
    case SetTargetDevice
    case TransferRequestStart
    case TransferFile
    case TransferProccess(value: UInt8)
    case TransferFileFailed
    case TransferRequestStop
    case FirmwareUpgraded
    case FirmwareUpgradedFailed
    case HeadsetProgressStatus
    case TimeOutError
    case DeviceDisconnected
    case FailedToSubscribedRequest
    case FailedToSetDeviceId
    case FailedToStartTransferRequest
    case FailedToSendData
    case FailedToTransferDone
}

enum ZygoDeviceVersion: String{
    case v1
    case v2
}

struct BLEVersionInfoDTO{
    var headsetVersion: String = ""
    var radioSTVersion: String = ""
    var radioSLVersion: String = ""
    var ESPVersion: String = ""
    var zygoDeviceVersion: ZygoDeviceVersion = .v2
    
    init(headsetVersion: String, radioSTVersion: String, radioSLVersion: String, ESPVersion: String, zygoDeviceVersion: ZygoDeviceVersion) {
        self.headsetVersion = headsetVersion
        self.radioSTVersion = radioSTVersion
        self.radioSLVersion = radioSLVersion
        self.ESPVersion = ESPVersion
        self.zygoDeviceVersion = zygoDeviceVersion
    }
    
    init(_ dict: [String: Any]) {
        self.headsetVersion = dict["headsetVersion"] as? String ?? ""
        self.radioSTVersion = dict["radioSTVersion"] as? String ?? ""
        self.radioSLVersion = dict["radioSLVersion"] as? String ?? ""
        self.ESPVersion = dict["ESPVersion"] as? String ?? ""
        if let deviceVersion = dict["zygoDeviceVersion"] as? String{
            self.zygoDeviceVersion = ZygoDeviceVersion(rawValue: deviceVersion) ?? .v2
        }
    }
    
    func toDict() -> [String: Any]{
        return [
            "headsetVersion": self.headsetVersion,
            "radioSTVersion": self.radioSTVersion,
            "radioSLVersion": self.radioSLVersion,
            "ESPVersion": self.ESPVersion,
            "zygoDeviceVersion": self.zygoDeviceVersion.rawValue
        ]
    }
    
    func isVersionZero() -> Bool{
        //(radioSTVersion == "0" || radioSTVersion == "") && (radioSLVersion == "0" || radioSLVersion == "") && (headsetVersion == "0" || headsetVersion == "") && (ESPVersion == "0" || ESPVersion == "")
        if radioSTVersion == "0" && radioSLVersion == "0" && headsetVersion == "0" && ESPVersion == "0"{
            return true
        }else{
            return false
        }
    }
}

struct BLEDeviceInfoDTO{
    
    var headsetBatteryLevel: Int8 = 0
    var radioBatteryLevel: Int8 = 0
    var versionInfo: BLEVersionInfoDTO = BLEVersionInfoDTO([:])
    var headsetUpdateAt: Date?
    var radioUpdateAt: Date?
    var deviceIdentifier: String = ""
    
    init(_ dict: [String: Any]) {
        self.headsetBatteryLevel = dict["headsetBatteryLevel"] as? Int8 ?? 0
        self.radioBatteryLevel = dict["radioBatteryLevel"] as? Int8 ?? 0
        let versionDict = dict["versionInfo"] as? [String:Any] ?? [:]
        self.versionInfo = BLEVersionInfoDTO(versionDict)
        if let headsetDate = dict["headsetUpdateAt"] as? String{
            if !headsetDate.isEmpty{
                self.headsetUpdateAt = headsetDate.convertToFormat("yyyy-MM-dd HH:mm:ss")
            }
        }
        
        if let radioDate = dict["radioUpdateAt"] as? String{
            if !radioDate.isEmpty{
                self.radioUpdateAt = radioDate.convertToFormat("yyyy-MM-dd HH:mm:ss")
            }
        }
        self.deviceIdentifier = dict["deviceIdentifier"] as? String ?? ""
    }
    
    func toDict() -> [String: Any]{
        return [
            "headsetBatteryLevel": self.headsetBatteryLevel,
            "radioBatteryLevel": self.radioBatteryLevel,
            "versionInfo": self.versionInfo.toDict(),
            "headsetUpdateAt": self.headsetUpdateAt?.convertToFormat("yyyy-MM-dd HH:mm:ss") ?? "",
            "radioUpdateAt": self.radioUpdateAt?.convertToFormat("yyyy-MM-dd HH:mm:ss") ?? "",
            "deviceIdentifier": self.deviceIdentifier
        ]
    }
    
}

struct BLELapInfoDTO{
    
    var numberOfLaps: UInt16 = 0
    var totalTime: UInt32 = 0
    var startStopStatus: Int8 = 0
    var oldNewStatus: Int8 = 0
    var serialNumber: String = ""
    var lastReadTime: UInt32 = 0
    
    init(_ dict: [String: Any]) {
        self.numberOfLaps = dict["numberOfLaps"] as? UInt16 ?? 0
        self.totalTime = dict["totalTime"] as? UInt32 ?? 0
        self.startStopStatus = dict["startStopStatus"] as? Int8 ?? 0
        self.oldNewStatus = dict["oldNewStatus"] as? Int8 ?? 0
        self.serialNumber = dict["serialNumber"] as? String ?? ""
        self.lastReadTime = dict["lastReadTime"] as? UInt32 ?? 0
    }
    
    /*func getTotalNumberOfLaps() -> UInt16{
        
        var numberOfLaps = self.numberOfLaps
        if numberOfLaps <= 0{
            return 0 
        }
        
        let startStopStatus = self.startStopStatus
        
        if startStopStatus == 0{
            numberOfLaps += 2
        }else if startStopStatus == 1{
            numberOfLaps += 1
        }else if startStopStatus == 2{
            numberOfLaps += 1
        }
        
        return numberOfLaps
        
    }*/
    
    func toDict() -> [String: Any]{
        return [
            "numberOfLaps": self.numberOfLaps,
            "totalTime": self.totalTime,
            "startStopStatus": self.startStopStatus,
            "oldNewStatus": self.oldNewStatus,
            "serialNumber": self.serialNumber,
            "lastReadTime": self.lastReadTime
        ]
    }
    
}

extension StringProtocol {
    var asciiValues: [UInt8] { compactMap(\.asciiValue) }
}
