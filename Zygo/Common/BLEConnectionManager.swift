//
//  BLEConnectionManager.swift
//  Zygo
//
//  Created by Som Parkash on 12/12/22.
//  Copyright © 2022 Somparkash. All rights reserved.
//

import UIKit

final class BLEConnectionManager: NSObject {

    static let shared = BLEConnectionManager()
    
    private var scanningTimer: Timer?
    private var myDevices: [BTDevice] = []
    
    private var onDeviceConnected: (() -> Void)?
    
    private override init() {
        
    }
    
    
    func startAutoConnectScanning(onConnected: (() -> Void)? = nil){
        self.onDeviceConnected = onConnected
        self.setupScanningTimer()
    }
    
    func stopScanning(){
        stopTimer()
        BluetoothManager.shared.stopScanning()
    }
    
    
    private func setupScanningTimer(){
        self.stopTimer()
        self.scheduleScanning()
        self.myDevices.removeAll()
        //self.myDevices.append(contentsOf: BluetoothManager.shared.discoveredPeripherals)
        
        self.scanningTimer = Timer(timeInterval: 5, repeats: true, block: { [weak self] (timerObj) in
            print("Timer Scanning")
            self?.scheduleScanning()
        })
        
        RunLoop.current.add(self.scanningTimer!, forMode: .common)
    }
    
    private func stopTimer(){
        scanningTimer?.invalidate()
        scanningTimer = nil
    }
    
    private func scheduleScanning(){
        DispatchQueue.main.async {
            
            BluetoothManager.shared.startScanning { [weak self] nearByDevices in
                self?.myDevices = nearByDevices.sorted(by: { ($0.device.name ?? "" ).localizedCaseInsensitiveCompare($1.device.name ?? "") == .orderedAscending })
                //self?.tblBluetooth.reloadData()
                
                if self?.myDevices.count ?? 0 <= 0{
                    return
                }
                
                guard let device = self?.myDevices.first else{
                    return
                }
                
                self?.stopScanning()
                
                BluetoothManager.shared.connect(device, onConnect: { [weak self] connectedDevice in
                    BluetoothManager.shared.fetchAllServices(connectedDevice) { [weak self] servicesDevice in
                        BluetoothManager.shared.fetchAllCharacteristics(servicesDevice) { [weak self] charDevice in
                            
                            self?.onDeviceConnected?()
                        }
                    }
                    
                }) { [weak self] failedToConnectDevice in
                    self?.startAutoConnectScanning(onConnected: self?.onDeviceConnected)
                }
                
            }
            
            if !BluetoothManager.shared.isBluetoothPermissionGranted{
                self.stopTimer()
                return
            }
        }
    }
}
