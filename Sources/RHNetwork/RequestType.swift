//
//  RequestType.swift
//  
//
//  Created by Chung Han Hsin on 2024/1/23.
//

import Foundation

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case download = "DOWNLOAD"
}

public protocol RequestType {
    var baseURL: URL { get }
    var path: String { get }
    var queryItems: [URLQueryItem] { get set }
    var fullURL: URL { get }
    var method: HTTPMethod { get }
    var body: Data? { get }
    var headers: [String:String]? { get }
    var urlRequest: URLRequest { get }
}

public extension RequestType {
    var fullURL: URL {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        components?.path += path
        components?.queryItems = queryItems
        guard let url = components?.url else {
            fatalError("Invalid URL components: \(String(describing: components))")
        }
        return url
    }
    
    var urlRequest: URLRequest {
        var urlRequest = URLRequest(url: fullURL)
        urlRequest.httpMethod = method.rawValue
        urlRequest.httpBody = body
        urlRequest.allHTTPHeaderFields = headers
        return urlRequest
    }
}



