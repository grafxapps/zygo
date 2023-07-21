//
//  RBBluetoothManager.swift
//  Zygo
//
//  Created by Priya Gandhi on 10/02/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol ZBluetoothManagerDelegates {
    func availableDevices(devices: [BTDevice])
    func didConnectDevice(devices: BTDevice)
}

final class ZBluetoothManager: NSObject {
    
    static let shared = ZBluetoothManager()
    private override init() {
        
    }
    
    private var centralManager: CBCentralManager?
    
    var currentPeripheral: CBPeripheral?
    var discoveredPeripherals = [BTDevice]()
    var delegate :  ZBluetoothManagerDelegates?
    
    
    func startScanning(){
        self.discoveredPeripherals.removeAll()
        
        if centralManager == nil{
            let centralQueue: DispatchQueue = DispatchQueue(label: "com.Zygo.centralQueueName", attributes: .concurrent)
            centralManager = CBCentralManager(delegate: self, queue: centralQueue)
        }else{
            if centralManager?.state == .poweredOn{
                centralManager?.scanForPeripherals(withServices: [CBUUID(string: "68999001-8008-968F-E311-6150405558B3"), CBUUID(string: "EEF1D96D-594C-4C53-B1C6-244A1DFDE6D8")])//, options: [CBCentralManagerScanOptionSolicitedServiceUUIDsKey : true])
                //centralManager?.scanForPeripherals(withServices: nil, options: nil)
            }
        }
        
    }
    
    func stopScanning(){
        centralManager?.stopScan()
        //Helper.shared.log += "\n\n\(Date()): Stop scanning"
    }
    
    func connect(device: CBPeripheral){
        currentPeripheral = device
        currentPeripheral?.delegate = self
        centralManager?.connect(currentPeripheral!)
        //Helper.shared.log += "\n\n\(Date()): Connecting to peripgeral \(device.identifier)"
    }
    
    func disconnect(device: CBPeripheral){
        print("Disconnect Device: \(device)")
        centralManager?.cancelPeripheralConnection(device)
        //Helper.shared.log += "\n\n\(Date()): disconneting to peripgeral \(device.identifier)"
    }
    
}

//MARK:- Delegates
extension ZBluetoothManager : CBCentralManagerDelegate, CBPeripheralDelegate{
    
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
            self.discoveredPeripherals.removeAll(keepingCapacity: true)
            
        case .poweredOn:
            print("Bluetooth status is POWERED ON")
            self.discoveredPeripherals.removeAll()
            centralManager?.scanForPeripherals(withServices: [CBUUID(string: "68999001-8008-968F-E311-6150405558B3"), CBUUID(string: "EEF1D96D-594C-4C53-B1C6-244A1DFDE6D8")])//, options: [CBCentralManagerScanOptionSolicitedServiceUUIDsKey : true])
        
        @unknown default:
            print("New State")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(peripheral.name ?? "Unknown Name")
        print(RSSI.doubleValue)
        
        
        if let index = self.discoveredPeripherals.firstIndex(where: { $0.device.identifier == peripheral.identifier }){
            self.discoveredPeripherals.remove(at: index)
            self.discoveredPeripherals.insert(BTDevice(device: peripheral, rssi: RSSI, services: [:]), at: index)
        }else{
            self.discoveredPeripherals.append(BTDevice(device: peripheral, rssi: RSSI, services: [:]))
        }
        
        DispatchQueue.main.async {
            if let del = self.delegate{
                del.availableDevices(devices: self.discoveredPeripherals)
            }
        }
        
        
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let device = self.discoveredPeripherals.filter({ $0.device.identifier.uuidString == peripheral.identifier.uuidString }).first{
            self.delegate?.didConnectDevice(devices: device)
        }    
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if let device = self.discoveredPeripherals.filter({ $0.device.identifier.uuidString == peripheral.identifier.uuidString }).first{
            self.delegate?.didConnectDevice(devices: device)
        }    
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
    }
    
    func pad(string : String, toSize: Int) -> String {
        var padded = string
        for _ in 0..<(toSize - string.count) {
            padded = "0" + padded
        }
        return padded
    }
}
