import UIKit

typealias DownloadManagerDownloadProgressBlock = (String?, CGFloat) -> Void
typealias DownloadManagerDownloadCompletionBlock = (String?, Bool) -> Void

class DownloadManagerDownload: NSObject
{
    var completionBlock: DownloadManagerDownloadCompletionBlock?
    var downloadTask: URLSessionDownloadTask?
    var filePath = ""
    var identifier = ""
    var progress: CGFloat = 0.0
    var progressBlock: DownloadManagerDownloadProgressBlock?
}

