//
//  RHNetworkTests_EndToEndTests.swift
//
//
//  Created by Chung Han Hsin on 2024/1/23.
//

import XCTest
@testable import RHNetwork

final class RHNetworkAPITests_EndToEndTests: XCTestCase {
    func test_GET_request_matchesBlackPokemonsData() {
        guard
            let receivedData = getBlackPokemonsData(),
            let json = try? JSONSerialization.jsonObject(with: receivedData, options: []) as? [String: Any],
            let pokemon_species = json["pokemon_species"] as? [[String: Any]]
        else {
            XCTFail("Expected results, but got no pokemon_species!")
            return
        }
        XCTAssertEqual(pokemon_species.count, 51)
    }
    
    func test_GET_request_matchesPokemonsData() {
        guard
            let receivedData = getPokemonsData(),
            let json = try? JSONSerialization.jsonObject(with: receivedData, options: []) as? [String: Any],
            let counts = json["count"] as? Int,
            let pokemons = json["results"] as? [[String: Any]]
        else {
            XCTFail("Expected results, but got no pokemon_species!")
            return
        }
        XCTAssertEqual(counts, 1302)
        XCTAssertEqual(pokemons.count, 1302)
    }
    
    func test_GET_request_matchesPokemonImageData() {
        guard
            let receivedData = downloadPokemonImageData()
        else {
            XCTFail("Expected imageData, but got no imageData instead!")
            return
        }
        XCTAssertTrue(identifyImageData(receivedData))
    }
}

// MARK: - GET Black Pokemons
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
}

// MARK: - GET All Pokemons
private extension RHNetworkAPITests_EndToEndTests {
    struct PokemonsRequest: RequestType {
        var queryItems: [URLQueryItem] = [
            .init(name: "limit", value: "1302")
        ]
        var headers: [String : String]? { nil }
        var body: Data? { nil }
        var baseURL: URL { .init(string: "https://pokeapi.co/api/v2")! }
        var path: String { "/pokemon" }
        var method: HTTPMethod { .get }
    }
    
    func getPokemonsData(file: StaticString=#file, line: UInt=#line) -> Data? {
        let request = PokemonsRequest()
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

// MARK: - DOWNLOAD Pokemon Imgae Data
private extension RHNetworkAPITests_EndToEndTests {
    struct PokemonImageDataRequest: RequestType {
        var queryItems: [URLQueryItem] = []
        
        var headers: [String : String]? {
            [
                "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.183 Safari/537.36"
            ]
        }
        var body: Data? { nil }
        var baseURL: URL { .init(string: "https://raw.githubusercontent.com")! }
        var path: String { "/PokeAPI/sprites/master/sprites/pokemon/other/home/shiny/1.png" }
        var method: HTTPMethod { .get }
    }
    
    func downloadPokemonImageData(file: StaticString=#file, line: UInt=#line) -> Data? {
        let request = PokemonImageDataRequest()
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
    
    func identifyImageData(_ data: Data) -> Bool {
        let pngSignature: [UInt8] = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]
        let jpegSignature: [UInt8] = [0xFF, 0xD8]

        var buffer = [UInt8](repeating: 0, count: 8)
        data.copyBytes(to: &buffer, count: 8)

        if buffer.starts(with: pngSignature) || buffer.starts(with: jpegSignature) {
            return true
        }
        return false
    }
}

