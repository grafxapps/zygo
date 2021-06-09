import UIKit
import CoreData

protocol DownloadManagerProtocol
{
    func cancelAllDownloads()
    func cancelDownload(_ identifier: String?)
    func download(_ identifier: String?, request: URLRequest?, filePath: String?, progressBlock: @escaping (_ identifier: String?, _ progress: CGFloat) -> Void, completionBlock: @escaping (_ identifier: String?, _ completed: Bool) -> Void)
    func downloadIsDownloading(_ identifier: String?, progressBlock: @escaping (_ identifier: String?, _ progress: CGFloat) -> Void, completionBlock: @escaping (_ identifier: String?, _ completed: Bool) -> Void) -> Bool
}

class DownloadManager: NSObject, URLSessionDelegate, URLSessionDownloadDelegate, DownloadManagerProtocol
{
    private var session: URLSession?
    private var downloads: [String: DownloadManagerDownload] = [:]

    static var sharedManager: DownloadManager = {
        return DownloadManager()
    }()

    override init()
    {
        super.init()

        let configuration = URLSessionConfiguration.background(withIdentifier: "com.cityworks.iOS.DownloadManager")
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        downloads = [:]
    }

    func cancelAllDownloads()
    {
        for (_, value) in downloads {
            cancelDownload(value.identifier)
        }
    }

    func cancelDownload(_ identifier: String?)
    {
        // Get the download.
        let download = downloads[identifier ?? ""]

        // Make sure the download exists.
        if download != nil {
            // Cancel the download.
            download?.downloadTask?.cancel()

            // Remove the download from the current downloads.
            downloads.removeValue(forKey: identifier ?? "")

            // Call the completion block.
            if let completionBlock = download?.completionBlock {
                completionBlock(identifier, false)
            }
        }
    }

    func download(_ identifier: String?, request: URLRequest?, filePath: String?, progressBlock: @escaping (String?, CGFloat) -> Void, completionBlock: @escaping (String?, Bool) -> Void)
    {
        // Create the download task.
        var downloadTask: URLSessionDownloadTask? = nil
        if let request = request {
            downloadTask = session?.downloadTask(with: request)
        }

        // Set the identifier.
        downloadTask?.taskDescription = identifier

        // Setup the download information.
        let download = DownloadManagerDownload()
        download.completionBlock = completionBlock
        download.downloadTask = downloadTask
        download.filePath = filePath ?? ""
        download.identifier = identifier ?? ""
        download.progress = 0.0
        download.progressBlock = progressBlock

        // Add to downloads.
        for (k, v) in [
            identifier ?? "": download
        ] { downloads[k] = v }

        // Start the download.
        downloadTask?.resume()
    }

    func downloadIsDownloading(_ identifier: String?, progressBlock: @escaping (String?, CGFloat) -> Void, completionBlock: @escaping (String?, Bool) -> Void) -> Bool
    {
        var ret = false

        // Get the download.
        let download = downloads[identifier ?? ""]

        if download != nil {
            download?.completionBlock = completionBlock

            download?.progressBlock = progressBlock

            // Initially call progress block so you can have current progress.
            if let progressBlock = download?.progressBlock {
                progressBlock(identifier, download?.progress ?? 0)
            }

            ret = true
        }

        return ret
    }

    // MARK: - NSURLSessionDelegate
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)
    {
        // Get the download.
        let download = downloads[downloadTask.taskDescription ?? ""]

        // Update progress.
        if download != nil {
            if download?.progressBlock != nil {
                // Calculate the progress.
                var progress = CGFloat(totalBytesWritten) / CGFloat(totalBytesExpectedToWrite)

                // Handle no expected bytes values.
                if progress < 0 {
                    progress = CGFloat(totalBytesWritten % 1000000) / 1000000.0
                }

                // Save the progress.
                download?.progress = progress

                // Call progress block.
                if let progressBlock = download?.progressBlock {
                    progressBlock(download?.identifier, progress)
                }
            }
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64)
    {
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL)
    {
        // Get the download.
        let download = downloads[downloadTask.taskDescription ?? ""]

        if download != nil {
            // Move the file to the specified path.
            do {
                try FileManager.default.moveItem(at: location, to: URL(fileURLWithPath: download?.filePath ?? ""))
            }
            catch {}

            // Call completion block.
            if let completionBlock = download?.completionBlock {
                completionBlock(download?.identifier, true)
            }

            // Remove from current downloads.
            downloads.removeValue(forKey: download?.identifier ?? "")
        }
    }
}
