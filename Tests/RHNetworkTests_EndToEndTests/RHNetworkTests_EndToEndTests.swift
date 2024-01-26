//
//  RHNetworkTests_EndToEndTests.swift
//
//
//  Created by Chung Han Hsin on 2024/1/23.
//

import XCTest
@testable import RHNetwork

final class RHNetworkAPITests_EndToEndTests: XCTestCase {
    func test_request_matchesBlackPokemonsData() {
        if 
            let receivedData = getBlackPokemonsData(),
            let json = try? JSONSerialization.jsonObject(with: receivedData, options: []) as? [String: Any] 
        {
            guard let pokemon_species = json["pokemon_species"] as? [[String: Any]] else {
                XCTFail("Expected pokemon_species, but got no pokemon_species!")
                return
            }
            print(pokemon_species[0])
            XCTAssertEqual(pokemon_species.count, 51)
        }
    }
}

private extension RHNetworkAPITests_EndToEndTests {
    struct BlackPokemonsRequest: RequestType {
        var queryItems: [URLQueryItem] = []
        var headers: [String : String]? { nil }
        var body: Data? { nil }
        var baseURL: URL { .init(string: "https://pokeapi.co/api/v2")! }
        var path: String { "/pokemon-color/black" }
        var method: HTTPMethod { .get }
    }
    
    func getBlackPokemonsData(file: StaticString=#file, line: UInt=#line) -> Data? {
        let request = BlackPokemonsRequest()
        // ephemeral: we don't need to cahce for session-related data
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
    
        // ephemeral: we don't need to cahce for session-related data
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
