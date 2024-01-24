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
}

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(HTTPClientError)
}

public protocol HTTPClient {
    func request(with request: RequestType, completion: @escaping (HTTPClientResult) -> Void)
}
