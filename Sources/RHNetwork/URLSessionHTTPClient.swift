//
//  URLSessionHTTPClient.swift
//
//
//  Created by Chung Han Hsin on 2024/1/23.
//

import Foundation

public class URLSessionHTTPClient: NSObject, HTTPClient {
    public var progressUpdateDict: [String : ((Float) -> Void)] = [:]
        
    var session: URLSession!
    private let uploadDataTaskWithProgress: UploadDataTaskWithProgress?
    public init(uploadDataTaskWithProgress: UploadDataTaskWithProgress) {
        self.uploadDataTaskWithProgress = uploadDataTaskWithProgress
        super.init()
        self.session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }
    
    public init(session: URLSession, uploadDataTaskWithProgress: UploadDataTaskWithProgress? = nil) {
        self.session = session
        self.uploadDataTaskWithProgress = uploadDataTaskWithProgress
    }
    
    public func request(with request: RequestType, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: request.urlRequest) { data, response, error in
            if let _ = error {
                completion(.failure(.responseError))
                return
            }
            guard
                let data,
                let response = response as? HTTPURLResponse
            else {
                completion(.failure(.cannotFindDataOrResponse))
                return
            }
            completion(.success(data, response))
        }.resume()
    }
    
    public func uploadDataTaskWithProgress(with request: RequestType, from data: Data?, completion: @escaping (HTTPClientResult) -> Void) {
        if request.urlRequest.httpMethod != HTTPMethod.post.rawValue {
            completion(.failure(.HTTPMethodShouldBePOST))
            return
        }
        
        /*
         當使用 URLSession 的上傳任務（特別是 uploadTask(with:from:) 或 uploadTask(with:fromFile:)）時，的確不應該在 URLRequest 中直接設置 httpBody。這是因為上傳任務會從方法的 from 參數或檔案中取得要上傳的數據，而不是從 URLRequest 的 httpBody 中。

         因此在 RequestType 協議擴展中設置 urlRequest.httpBody = body 是對於普通的資料請求（如 dataTask）來說是沒有問題的，因為這些請求類型通常需要在請求體中攜帶數據。然而，當進行檔案上傳操作時，這樣做就不適合了。
         */
        session.uploadTask(with: request.urlRequest, from: data) { data, response, error in
            if let _ = error {
                completion(.failure(.responseError))
                return
            }
            guard
                let data,
                let response = response as? HTTPURLResponse
            else {
                completion(.failure(.cannotFindDataOrResponse))
                return
            }
            completion(.success(data, response))
        }.resume()
    }
    
    public func registerProgressUpdate(for url: String, with action: @escaping (Float) -> Void) {
        progressUpdateDict[url] = action
    }
}

extension URLSessionHTTPClient: URLSessionTaskDelegate {
    public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        guard let url = task.currentRequest?.url?.absoluteString else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.uploadDataTaskWithProgress?.uploadDataTaskWithProgress(didSendBodyData: bytesSent, totalBytesSent: totalBytesSent, totalBytesExpectedToSend: totalBytesExpectedToSend) { progress in
                guard let progressUpdateClosure = self.progressUpdateDict[url] else { return }
                progressUpdateClosure(progress)
            }
        }
    }
}
