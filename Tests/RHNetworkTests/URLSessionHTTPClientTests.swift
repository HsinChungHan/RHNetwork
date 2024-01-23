//
//  URLSessionHTTPClientTests.swift
//
//
//  Created by Chung Han Hsin on 2024/1/23.
//

import XCTest
@testable import RHNetwork


class URLSessionHTTPClientTests: XCTestCase {
    override class func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
    }
    
    override class func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequests()
    }
    
    func test_request_failsOnGetRequestError() {
        let requestedError = anyError
        let expectedError = HTTPClientError.responseError
        let receivedError = makeErrorResult(with: anyGETRequest, data: nil, response: nil, error: requestedError) as? NSError
        XCTAssertEqual(receivedError?.domain, expectedError._domain)
        XCTAssertEqual(receivedError?.code, expectedError._code)
    }
    
    func test_request_failsOnPostRequestError() {
        let requestedError = anyError
        let expectedError = HTTPClientError.responseError
        let receivedError = makeErrorResult(with: anyPOSTRequest, data: nil, response: nil, error: requestedError)
        XCTAssertEqual(receivedError, expectedError)
    }
    
    func test_request_succeedsWithEmptyDataOnGetHTTPURLResponseWithNilData() {
        let response = anyGETHttpURLResponse
        let receivedValues = makeValueResult(with: anyGETRequest, data: nil, response: response, error: nil)
        let emptyData = Data()
        // if data is nil, URLProtocol will send a 0 byte data automatically
        XCTAssertEqual(receivedValues?.data, emptyData)
        XCTAssertEqual(receivedValues?.response.url, response.url)
        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
    }
    
    func test_request_succeedsWithEmptyDataOnPostHTTPURLResponseWithNilData() {
        let response = anyPOSTHttpURLResponse
        let receivedValues = makeValueResult(with: anyPOSTRequest, data: nil, response: response, error: nil)
        let emptyData = Data()
        XCTAssertEqual(receivedValues?.data, emptyData)
        XCTAssertEqual(receivedValues?.response.url, response.url)
        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
    }
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

// MARK: - factory methods
private extension URLSessionHTTPClientTests {
    var anyError: NSError {
        .init(domain: "any error", code: 0, userInfo: nil)
    }
    
    var anyData: Data { .init("any data".utf8) }
    
    var anyGETRequest: RequestSpy { .init(path: "testGet", method: .get, body: nil) }
    var anyPOSTRequest: RequestSpy { .init(path: "testPost", method: .post, body: anyData) }
    
    var anyGETHttpURLResponse: HTTPURLResponse {
        HTTPURLResponse(url: anyGETRequest.fullURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    var anyPOSTHttpURLResponse: HTTPURLResponse {
        HTTPURLResponse(url: anyPOSTRequest.fullURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    func makeSUT(file: StaticString=#file, line: UInt=#line) -> HTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeak(sut, file: file, line: line)
        return sut
    }
    
    func makeResult(with request: RequestType, data: Data?, response: URLResponse?, error: Error?, file: StaticString=#file, line: UInt=#line) -> HTTPClientResult {
        URLProtocolStub.stub(data: data, response: response, error: error)
        let sut = makeSUT(file: file, line: line)
        let expect = expectation(description: "Wait for completion ...")
        var receivedResult: HTTPClientResult!
        sut.request(with: request) { result in
            receivedResult = result
            expect.fulfill()
        }
        wait(for: [expect], timeout: 1.0)
        return receivedResult
    }
    
    func makeErrorResult(with request: RequestType, data: Data?, response: URLResponse?, error: Error?, file: StaticString=#file, line: UInt=#line) -> HTTPClientError? {
        URLProtocolStub.stub(data: data, response: response, error: error)
        let result = makeResult(with: request, data: data, response: response, error: error, file: file, line: line)
        switch result {
        case let .failure(error):
            return error
        default:
            XCTFail("Expected failure, got \(result) instead", file: file, line: line)
            return nil
        }
    }
    
    func makeValueResult(with request: RequestType, data: Data?, response: URLResponse?, error: Error?, file: StaticString=#file, line: UInt=#line) -> (data: Data, response: HTTPURLResponse)? {
        URLProtocolStub.stub(data: data, response: response, error: error)
        let result = makeResult(with: request, data: data, response: response, error: error, file: file, line: line)
        switch result {
        case let .success(data, response):
            return (data, response)
        default:
            XCTFail("Expected failure, got \(result) instead", file: file, line: line)
            return nil
        }
    }
}
