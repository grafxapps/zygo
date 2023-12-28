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
            .status :BTCharacteristic(uuid: CBUUID(string: ZygoCharacteristic.status.rawValue))
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
            print("Device Info Data")
            if data.count < 1{
                DispatchQueue.main.async {
                    completion(BLEDeviceInfoDTO([:]))
                }
                return
            }
            
            let radioBattery = data[0]
            let headsetBattery = data[1]
            let headsetVersion = data[2...5].to(type: UInt16.self) ?? 0
            let radioSTVersion = data[6...9].to(type: UInt16.self) ?? 0
            let radioSLVersion = data[10...13].to(type: UInt16.self) ?? 0
            let ESPVersion = data[14...17].to(type: UInt16.self) ?? 0
            
            let versionItem = BLEVersionInfoDTO(headsetVersion: "\(headsetVersion)", radioSTVersion: "\(radioSTVersion)", radioSLVersion: "\(radioSLVersion)", ESPVersion: "\(ESPVersion)")
            
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
            let totalTime = data[2...5].to(type: UInt16.self) ?? 0
            let startStopStatus = Int8(data[6])
            let oldNewStatus = Int8(data[7])
            let serialNumber = data[8...15].to(type: UInt16.self) ?? 0
            let lastReadTime = data[16...19].to(type: UInt16.self) ?? 0
            
            var lapInfo = BLELapInfoDTO([:])
            lapInfo.numberOfLaps = numberOfLaps
            lapInfo.totalTime = totalTime
            lapInfo.startStopStatus = startStopStatus
            lapInfo.oldNewStatus = oldNewStatus
            lapInfo.serialNumber = serialNumber
            lapInfo.lastReadTime = lastReadTime
            
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
    
    func readDeviceStatus(){
        
        guard let deviceIndex = self.discoveredPeripherals.firstIndex(where: { $0.device.identifier.uuidString == currentSelectedDeviceIdentifier.uuidString }) else{
            return
        }
        
        guard let charItem = self.discoveredPeripherals[deviceIndex].services[.data]?.characteristics[.status]?.characteristic else{
            return
        }
        
        self.discoveredPeripherals[deviceIndex].services[.data]?.characteristics[.status]?.onRead = { data in
            print("Device Status Data: \(data.hexString)")
            if data.count < 1{
                return
            }
        }
        
        self.discoveredPeripherals[deviceIndex].device.readValue(for: charItem)
        
    }
    
    //MARK: - DFU Process
    private var onDFUProgress: ((Float) -> Void)?
    private var onDFUStatusUpdate: ((DFUStatus) -> Void)?
    private var onDFUCompletion: ((Bool) -> Void)?
    private var firmwareURL: URL!
    private var tragatedDevice: TargetDeviceCode = .ESP
    
    func startTimeOutTimer(){
        self.stopScanning()
        self.timeOutTimer = Timer(timeInterval: 5.0, repeats: false, block: { timerObj in
            self.onDFUStatusUpdate?(.TimeOutError)
        })
        RunLoop.main.add(self.timeOutTimer!, forMode: .common)
    }
    
    func stopTimerOutTimer(){
        self.timeOutTimer?.invalidate()
        self.timeOutTimer = nil
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
            self.onDFUStatusUpdate?(.SubscribeDevice)
            if data.count < 1{
                self.onDFUStatusUpdate?(.FirmwareUpgradedFailed)
                self.onDFUCompletion?(false)
                return
            }
            
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
                    self.onDFUStatusUpdate?(.TransferFileFailed)
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
                    
                    if self.tragatedDevice == .SILABS_HEADSET{
                        //Here Check Headset file Progress from radio to headset
                        self.getHeadsetProgressStatus()
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
    
    func getHeadsetProgressStatus(){
        self.checkHeadsetProgess { dfuStaus, progressStatus in
            DispatchQueue.main.async {
                print("DFU Status: \(dfuStaus)")
                if dfuStaus == 9{
                    print("Break Here")
                }
                print("progressStatus Status: \(progressStatus)")
                if progressStatus == 1{//In Progress
                 }else if progressStatus == 2{//Pass
                    self.onDFUStatusUpdate?(.FirmwareUpgraded)
                    self.onDFUCompletion?(true)
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
            self?.onDisconnect?(device)
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
            if strongSelf.discoveredPeripherals[deviceIndex].services[.OTA]?.characteristics.filter({ $0.value.characteristic != nil }).count ?? 0 == 2 && strongSelf.discoveredPeripherals[deviceIndex].services[.data]?.characteristics.filter({ $0.value.characteristic != nil }).count ?? 0 == 5{
                self?.onCharacteristics?(strongSelf.discoveredPeripherals[deviceIndex])
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        print("Received Data for Char: \(characteristic.uuid.uuidString)")
        guard let valueData = characteristic.value else{
            return
        }
        
        print("Received Data: \(valueData.hexString)")
        
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
}

struct BLEVersionInfoDTO{
    var headsetVersion: String = ""
    var radioSTVersion: String = ""
    var radioSLVersion: String = ""
    var ESPVersion: String = ""
    
    init(headsetVersion: String, radioSTVersion: String, radioSLVersion: String, ESPVersion: String) {
        self.headsetVersion = headsetVersion
        self.radioSTVersion = radioSTVersion
        self.radioSLVersion = radioSLVersion
        self.ESPVersion = ESPVersion
    }
    
    init(_ dict: [String: Any]) {
        self.headsetVersion = dict["headsetVersion"] as? String ?? ""
        self.radioSTVersion = dict["radioSTVersion"] as? String ?? ""
        self.radioSLVersion = dict["radioSLVersion"] as? String ?? ""
        self.ESPVersion = dict["ESPVersion"] as? String ?? ""
    }
    
    func toDict() -> [String: Any]{
        return [
            "headsetVersion": self.headsetVersion,
            "radioSTVersion": self.radioSTVersion,
            "radioSLVersion": self.radioSLVersion,
            "ESPVersion": self.ESPVersion
        ]
    }
    
    func isVersionZero() -> Bool{
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
    var totalTime: UInt16 = 0
    var startStopStatus: Int8 = 0
    var oldNewStatus: Int8 = 0
    var serialNumber: UInt16 = 0
    var lastReadTime: UInt16 = 0
    
    init(_ dict: [String: Any]) {
        self.numberOfLaps = dict["numberOfLaps"] as? UInt16 ?? 0
        self.totalTime = dict["totalTime"] as? UInt16 ?? 0
        self.startStopStatus = dict["startStopStatus"] as? Int8 ?? 0
        self.oldNewStatus = dict["oldNewStatus"] as? Int8 ?? 0
        self.serialNumber = dict["serialNumber"] as? UInt16 ?? 0
        self.lastReadTime = dict["lastReadTime"] as? UInt16 ?? 0
    }
    
    func getTotalNumberOfLaps() -> UInt16{
        
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
        
    }
    
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
