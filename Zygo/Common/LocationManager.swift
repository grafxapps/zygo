//
//  LocationManager.swift
//  Zygo
//
//  Created by Som on 26/02/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit
import CoreLocation

final class LocationManager: NSObject, CLLocationManagerDelegate {
    
    static let shared = LocationManager()
    //var locationMgr : CLLocationManager? = CLLocationManager()
    var locationMgr: CLLocationManager? = CLLocationManager()
    
    var currentLocation : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var isCreateRegion: Bool = true
    var isLocationManagerStarted = false
    var isOnceLocationGet = false
    
    private var backgroundUpdateTask: UIBackgroundTaskIdentifier!
    
    private override init() {
        
    }
    
    var onUpdate: ((CLLocationCoordinate2D?) -> Void)?
    var onStop: (() -> Void)?
    
    func startLoction(){
        DispatchQueue.main.async {
            self.isOnceLocationGet = false
            
            if !PreferenceManager.shared.isUserLogin{
                return
            }
            
            if self.isLocationManagerStarted{
                return
            }
            
            self.locationMgr?.requestWhenInUseAuthorization()
            
            self.locationMgr?.delegate = self
            if (CLLocationManager.locationServicesEnabled()){
                switch CLLocationManager.authorizationStatus() {
                case .authorizedAlways, .authorizedWhenInUse:
                    self.locationMgr?.desiredAccuracy = kCLLocationAccuracyBest
                    //locationMgr.pausesLocationUpdatesAutomatically = true//To Save battery
                    self.locationMgr?.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
                    self.locationMgr?.distanceFilter = kCLDistanceFilterNone;
                    
                    //let status = CLLocationManager.authorizationStatus()
                    //if status == .authorizedAlways  || status == .authorizedWhenInUse{
                    self.isLocationManagerStarted = true
                    self.locationMgr?.startUpdatingLocation()
                case  .denied:
                    print("Location Denied")
                    self.stopLocation()
                    self.onUpdate?(nil)
                    
                    Helper.shared.alertYesNoActions(title: "Settings", message: "Allow location from settings", yesActionTitle: "Settings", noActionTitle: "Cancel") { (isYes) in
                        if isYes{
                            Helper.shared.openUrl(url: URL(string: UIApplication.openSettingsURLString))
                        }
                    }
                default:
                    print("No Location Access")
                }
            }
        }
    }
    
    func stopLocation(){
        self.locationMgr?.stopUpdatingLocation()
        self.isLocationManagerStarted = false
        self.onStop?()
    }
    
    
    func distanceFrom(location: CLLocationCoordinate2D) -> Double{
        let distanceInMeters = CLLocation(latitude: self.currentLocation.latitude, longitude: self.currentLocation.longitude).distance(from: CLLocation(latitude: location.latitude, longitude: location.longitude))
        
        let oneMeterInMile = 0.000621371
        return (distanceInMeters * oneMeterInMile)
        
    }
    
    func getAddressFromLatLong(Latitude: Double, withLongitude Longitude: Double, completion: @escaping (Address?) -> Void) {
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        let lat: Double = Latitude
        let lon: Double = Longitude
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = lat
        center.longitude = lon
        
        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
        ceo.reverseGeocodeLocation(loc, completionHandler:
                                    {(placemarks, error) in
                                        
                                        if (error != nil){
                                            completion(nil)
                                            return
                                        }
                                        
                                        let pm = placemarks! as [CLPlacemark]
                                        
                                        var addressItem = Address([:])
                                        
                                        if pm.count > 0 {
                                            let pm = placemarks![0]
                                            
                                            var addressString : String = ""
                                            if pm.name != nil {
                                                addressString = addressString + pm.name! + ", "
                                                addressItem.house = pm.name!.capitalized
                                            }
                                            
                                            if pm.locality != nil {
                                                addressString = addressString + pm.locality! + ", "
                                                addressItem.city = pm.locality!
                                            }
                                            
                                            if pm.administrativeArea != nil {
                                                addressString = addressString + pm.administrativeArea! + ", "
                                                addressItem.state = pm.administrativeArea!
                                            }
                                            
                                            if pm.country != nil {
                                                //addressString = addressString + pm.country! + ", "
                                                addressItem.country = pm.country!
                                            }
                                            
                                            if pm.postalCode != nil {
                                                addressString = addressString + pm.postalCode!
                                                addressItem.zipcode = pm.postalCode!
                                            }
                                            
                                            if pm.location != nil{
                                                addressItem.geoPoint = CLLocationCoordinate2D(latitude: pm.location!.coordinate.latitude, longitude: pm.location!.coordinate.longitude)
                                            }
                                            
                                            //self.lblAddress.text = addressString
                                            addressItem.streetAddress = addressString
                                            completion(addressItem)
                                        }else{
                                            completion(nil)
                                            return
                                        }
                                    })
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if isOnceLocationGet{
            return;
        }
        
        isOnceLocationGet = true
        let locValue:CLLocationCoordinate2D = locations.last?.coordinate ?? CLLocationCoordinate2DMake(0.0, 0.0)
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        self.currentLocation = locValue
        self.onUpdate?(locValue)
        self.stopLocation()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print("error::: \(error)")
        self.stopLocation()
        self.onUpdate?(nil)
        
        if let cErr = error as? CLError{
            if cErr.code == CLError.denied{
                Helper.shared.alertYesNoActions(title: "Settings", message: "Allow location from settings", yesActionTitle: "Settings", noActionTitle: "Cancel") { (isYes) in
                    if isYes{
                        Helper.shared.openUrl(url: URL(string: UIApplication.openSettingsURLString))
                    }
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            if PreferenceManager.shared.isUserLogin{
                self.stopLocation()
                self.startLoction()
            }
        }else if status == .denied{
            print("Location Denied")
            self.stopLocation()
            self.onUpdate?(nil)
            
            Helper.shared.alertYesNoActions(title: "Settings", message: "Allow location from settings", yesActionTitle: "Settings", noActionTitle: "Cancel") { (isYes) in
                if isYes{
                    Helper.shared.openUrl(url: URL(string: UIApplication.openSettingsURLString))
                }
            }
        }
    }
    
}


struct Address {
    
    var house: String = ""
    var country: String = ""
    var geoPoint : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    var city: String = ""
    var state: String = ""
    var streetAddress: String = ""
    var zipcode: String = ""
    
    init(_ addressDict: [String:Any]) {
        self.city = addressDict["City"] as? String ?? ""
        
        if let latLong = addressDict["LatLong"] as? String{
            let arrLatLong = latLong.split(separator: ",")
            let lat : Double = Double(String(arrLatLong.first ?? "0")) ?? 0
            let longi : Double = Double(String(arrLatLong.last ?? "0")) ?? 0
            self.geoPoint =  CLLocationCoordinate2D(latitude: lat, longitude: longi)
        }
        
        self.state = addressDict["State"] as? String ?? ""
        self.streetAddress = addressDict["Address2"] as? String ?? ""
        self.zipcode = addressDict["ZipCode"] as? String ?? ""
        self.country = addressDict["Country"] as? String ?? ""
        self.house = addressDict["Address1"] as? String ?? ""
    }
    
    func toDict() -> [String : Any]{
        
        return [
            "Address1":self.house,
            "Country":self.country,
            "LatLong":"\(self.geoPoint.latitude),\(self.geoPoint.longitude)",
            "City":self.city,
            "State":self.state,
            "Address2":self.streetAddress,
            "ZipCode":self.zipcode
        ]
    }
    
}
