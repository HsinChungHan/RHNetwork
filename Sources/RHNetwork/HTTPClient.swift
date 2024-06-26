//
//  HTTPClient.swift
//
//
//  Created by Chung Han Hsin on 2024/1/23.
//

import Foundation

public enum HTTPClientError: Error {
    case jsonToDataError
    case responseError
    case cannotFindDataOrResponse
    case HTTPMethodShouldBePOST
}

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(HTTPClientError)
}

public protocol HTTPClient {
    func request(with request: RequestType, completion: @escaping (HTTPClientResult) -> Void)
    func uploadDataTaskWithProgress(with request: RequestType, from data: Data?, completion: @escaping (HTTPClientResult) -> Void, taskID: String?, withProgressAction action: ((Float) -> Void)?)
    func registerProgressUpdate(for url: String, with action: @escaping (_ progress: Float) -> Void)
    var progressUpdateDict: [String: ((_ progress: Float) -> Void)] { get set }
}

