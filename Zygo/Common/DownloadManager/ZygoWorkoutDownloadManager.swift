//
//  ZygoWorkoutDownloadManager.swift
//  Zygo
//
//  Created by Som on 19/02/21.
//  Copyright © 2021 Priya Gandhi. All rights reserved.
//

import UIKit

final class ZygoWorkoutDownloadManager: NSObject {
    
    static let shared = ZygoWorkoutDownloadManager()
   
    var downloadComplete: ((Bool) -> Void)?
    var onProgress: ((String, CGFloat) -> Void)?
    
    private var _downloader: DownloadManager?
    private var downloader: DownloadManagerProtocol?
    {
        if let _ = _downloader {
        }
        else {
            _downloader = DownloadManager.sharedManager
        }
        
        return _downloader
    }
    
    
    private override init() {
        
    }
    
    
    func download(workout: WorkoutDTO){
        
        guard let audioURL = URL(string: workout.audioURL.getImageURL()) else{
            self.downloadComplete?(false)
            return
        }
        
        let workoutIdentifier = "\(workout.workoutId)"
        let filePath = self.getAudioPath(audioIdentifier: "\(workoutIdentifier).mp3")
            
        DatabaseManager.shared.saveWorkout(workoutItem: workout, audioLocalPath: filePath)
        
        let request = URLRequest(url: audioURL)
        
        downloader?.download(workoutIdentifier, request: request, filePath: filePath, progressBlock: { (identifier, progress) in
            print("Workout: \(identifier ?? ""), Progress: \(progress)")
        }, completionBlock: { (identifier, isCompleted) in
            if isCompleted{
                DatabaseManager.shared.updateWorkoutDownload(status: .downloaded, workoutIdentifier: identifier ?? "")
                DispatchQueue.main.async {
                    self.downloadComplete?(true)
                }
                
            }else{
                DatabaseManager.shared.updateWorkoutDownload(status: .cancelled, workoutIdentifier: identifier ?? "")
                DispatchQueue.main.async {
                    self.downloadComplete?(false)
                }
            }
            
        })
        
    }
    
    func cancelFirmwareDownloads(firmware: FirmwareDTO){
        let firmwareIdentifier = "\(firmware.targetDevice.rawValue)\(firmware.version)"
        downloader?.cancelDownload(firmwareIdentifier)
    }
    
    func download(firmware: FirmwareDTO, onProgress: ((String, CGFloat) -> Void)? = nil, onDownloadComplete: ((Bool) -> Void)? = nil ){
        
        self.downloadComplete = onDownloadComplete
        self.onProgress = onProgress
        
        guard let audioURL = URL(string: firmware.fileURL) else{
            self.downloadComplete?(false)
            return
        }
        
        let firmwareIdentifier = "\(firmware.targetDevice.rawValue)\(firmware.version)"
    
        let filePath = self.getFirmwarePath(firmwareIdentifier: "\(firmwareIdentifier)")
            
        //DatabaseManager.shared.saveWorkout(workoutItem: workout, audioLocalPath: filePath)
        
        let request = URLRequest(url: audioURL)
        
        downloader?.download(firmwareIdentifier, request: request, filePath: filePath, progressBlock: { (identifier, progress) in
            print("Firmware: \(identifier ?? ""), Progress: \(progress)")
            self.onProgress?(identifier ?? "", progress)
        }, completionBlock: { (identifier, isCompleted) in
            if isCompleted{
                //DatabaseManager.shared.updateWorkoutDownload(status: .downloaded, workoutIdentifier: identifier ?? "")
                DispatchQueue.main.async {
                    self.downloadComplete?(true)
                }
                
            }else{
               // DatabaseManager.shared.updateWorkoutDownload(status: .cancelled, workoutIdentifier: identifier ?? "")
                DispatchQueue.main.async {
                    self.downloadComplete?(false)
                }
            }
            
        })
        
    }
    
    func getAudioPath(audioIdentifier : String) -> String{
        
        let fileManager = FileManager.default
        let videoPath = (self.getDirectoryPath() as NSString).appendingPathComponent("DownloadedAudios")
        
        if !fileManager.fileExists(atPath:videoPath )
        {
            try?fileManager.createDirectory(atPath: videoPath, withIntermediateDirectories: false, attributes: nil)
        }
        
        let savedVideoFolderPath =  (videoPath as NSString).appendingPathComponent(audioIdentifier)
        
        return savedVideoFolderPath
    }
    
    func getFirmwarePath(firmwareIdentifier: String) -> String{
        
        let fileManager = FileManager.default
        let videoPath = (self.getDirectoryPath() as NSString).appendingPathComponent("DownloadedFirmwares")
        
        if !fileManager.fileExists(atPath:videoPath )
        {
            try?fileManager.createDirectory(atPath: videoPath, withIntermediateDirectories: false, attributes: nil)
        }
        
        let savedVideoFolderPath =  (videoPath as NSString).appendingPathComponent(firmwareIdentifier)
        
        return savedVideoFolderPath
    }
    
    func getDirectoryPath()  ->String{
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentDirectory = paths[0]
        return documentDirectory
    }
    
    
}
