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
}
