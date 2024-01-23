//
//  RHNetworkTests_EndToEndTests.swift
//
//
//  Created by Chung Han Hsin on 2024/1/23.
//

import XCTest
@testable import RHNetwork

final class RHNetworkAPITests_EndToEndTests: XCTestCase {}
private extension RHNetworkAPITests_EndToEndTests {
    struct RequestTypeSpy: RequestType {
        var headers: [String : String]? { nil }
        var body: Data? { nil }
        var baseURL: URL { .init(string: "https://pokeapi.co/api/v2")! }
        var path: String { "pokemon-color/1" }
        var method: HTTPMethod { .get }
    }
    
    func getPikachuData(file: StaticString=#file, line: UInt=#line) -> Data? {
        let request = RequestTypeSpy()
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        var receivedData: Data?
        let exp = expectation(description: "wait for the response ...")
        client.request(with: request) { result in
            switch result {
            case let .success(data, _):
                receivedData = data
            default:
                XCTFail("Expected success, got \(result) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 30.0)
        return receivedData
    }
}
