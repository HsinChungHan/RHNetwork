//
//  UrlsessionDataTaskWithProgress.swift
//  
//
//  Created by Chung Han Hsin on 2024/4/4.
//

import Foundation

public class UrlsessionDataTaskWithProgress: UploadDataTaskWithProgress {
    public init() {}
    
    public func uploadDataTaskWithProgress(didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64, completion: (Float) -> Void) {
        let uploadProgress = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
        completion(uploadProgress)
    }
}
