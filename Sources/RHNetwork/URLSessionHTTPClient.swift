//
//  URLSessionHTTPClient.swift
//
//
//  Created by Chung Han Hsin on 2024/1/23.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    public init(session: URLSession = .shared) {
        self.session = session
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
}
