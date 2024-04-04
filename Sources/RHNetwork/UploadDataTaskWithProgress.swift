//
//  File.swift
//  
//
//  Created by Chung Han Hsin on 2024/4/3.
//

import Foundation

public protocol UploadDataTaskWithProgress {
    func uploadDataTaskWithProgress(didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64, completion: (Float) -> Void)
}
