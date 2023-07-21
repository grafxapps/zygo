//
//  BluetoothViewController.swift
//  Zygo
//
//  Created by Priya Gandhi on 02/02/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit
import CoreBluetooth

class BluetoothViewController: UIViewController, ZBluetoothManagerDelegates {
    
    @IBOutlet weak var tblBluetooth : UITableView!
    @IBOutlet weak var lblNoData : UILabel!
    
    var scanningTimer: Timer?
    var myDevices: [BTDevice] = []
    
    //MARK: - UIViewcontroller LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupScanningTimer()
        self.registerCustomCells()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ZBluetoothManager.shared.delegate = self
    }
    
    deinit {
        self.stopTimer()
    }
    
    
    //MARK:- Setup
    func registerCustomCells()  {
        tblBluetooth.separatorStyle = .none
        tblBluetooth.register(UINib.init(nibName: BluetoothTVC.identifier, bundle: nil), forCellReuseIdentifier: BluetoothTVC.identifier);
    }
    
    func setupScanningTimer(){
        self.stopTimer()
        self.scheduleScanning()
        self.myDevices.removeAll()
        //self.myDevices.append(contentsOf: ZBluetoothManager.shared.discoveredPeripherals)
        
        self.scanningTimer = Timer(timeInterval: 15, repeats: true, block: { [weak self] (timerObj) in
            print("Timer Scanning")
            self?.scheduleScanning()
        })
        
        RunLoop.current.add(self.scanningTimer!, forMode: .common)
    }
    
    func stopTimer(){
        scanningTimer?.invalidate()
        scanningTimer = nil
    }
    
    func scheduleScanning(){
        DispatchQueue.main.async {
            
            if !BluetoothManager.shared.isBluetoothPermissionGranted{
                self.stopTimer()
                return
            }
            
            BluetoothManager.shared.startScanning { [weak self] nearByDevices in
                self?.myDevices = nearByDevices.sorted(by: { ($0.device.name ?? "" ).localizedCaseInsensitiveCompare($1.device.name ?? "") == .orderedAscending })
                self?.tblBluetooth.reloadData()
            }
            //ZBluetoothManager.shared.startScanning()
        }
    }
    
    func availableDevices(devices: [BTDevice]) {
        DispatchQueue.main.async {
            self.myDevices = devices.sorted(by: { ($0.device.name ?? "" ).localizedCaseInsensitiveCompare($1.device.name ?? "") == .orderedAscending })
            self.tblBluetooth.reloadData()
        }
    }
    
    func didConnectDevice(devices: BTDevice) {
        DispatchQueue.main.async {
            self.tblBluetooth.reloadData()
        }
    }
    
    //MARK: - UIButton Actions
    @IBAction func backAction(_ sender: UIButton){
        self.stopTimer()
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension BluetoothViewController : UITableViewDataSource, UITableViewDelegate, PairVCDelegates{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myDevices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : BluetoothTVC = tableView.dequeueReusableCell(withIdentifier: BluetoothTVC.identifier) as! BluetoothTVC
        let peripheral = self.myDevices[indexPath.row]
        cell.selectionStyle = .none
        
        if peripheral.device.state == .connected{
            cell.lblStatus.text = "Connected"
            cell.lblStatus.textColor = UIColor.appBlueColor()
            cell.statusImageView.image = UIImage(named: "icon_bluetooth_enable")
        }else{
            cell.lblStatus.text = "Pair"
            cell.lblStatus.textColor = UIColor.lightGray
            cell.statusImageView.image = UIImage(named: "icon_bluetooth_disable")
        }
        
        cell.lblTitle.text = peripheral.device.name ?? "Unknown"
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = PairVC(nibName: "PairVC", bundle: nil)
        vc.device = self.myDevices[indexPath.row]
        vc.modalPresentationStyle = .overFullScreen
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75.0
    }
    
    func didPair(_ device: BTDevice) {
        BluetoothManager.shared.connect(device, onConnect: { [weak self] connectedDevice in
            self?.tblBluetooth.reloadData()
            BluetoothManager.shared.fetchAllServices(connectedDevice) { [weak self] servicesDevice in
                self?.tblBluetooth.reloadData()
                BluetoothManager.shared.fetchAllCharacteristics(servicesDevice) { charDevice in
                    self?.tblBluetooth.reloadData()
                }
            }
            
        }) { [weak self] failedToConnectDevice in
            self?.tblBluetooth.reloadData()
        }
    }
    
    func didUnPair(_ device: BTDevice) {
        BluetoothManager.shared.disconnect(device) { [weak self] disconnectedDevice in
            self?.tblBluetooth.reloadData()
        }
    }
}
