//
//  URLSessionHTTPClientTests.swift
//
//
//  Created by Chung Han Hsin on 2024/1/23.
//

import XCTest
@testable import RHNetwork

class URLSessionHTTPClientTests: XCTestCase {
}

// MARK: - Define
private extension URLSessionHTTPClientTests {
    struct RequesAndResponeStub {
        let data: Data?
        let response: URLResponse?
        let error: Error?
    }
    
    
    class URLProtocolStub: URLProtocol {
        private static var stub: RequesAndResponeStub?
        
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = RequesAndResponeStub.init(data: data, response: response, error: error)
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            guard
                let stub = URLProtocolStub.stub
            else {
                client?.urlProtocolDidFinishLoading(self)
                return
            }
            
            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = stub.response {
                // 測試不需要 cache
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            // 最後結束 loading
            client?.urlProtocolDidFinishLoading(self)
        }
        
        // It should be implemented, or the system will crash during runtime
        override func stopLoading() {}
    }
    
    struct RequestSpy: RequestType {
        var baseURL: URL { URL.init(string: "https://any-url")! }
        var headers: [String : String]? { nil }
        var path: String
        var method: HTTPMethod
        var body: Data?
        init(path: String, method: HTTPMethod, body: Data?) {
            self.path = path
            self.method = method
            self.body = body
        }
    }
}
}
