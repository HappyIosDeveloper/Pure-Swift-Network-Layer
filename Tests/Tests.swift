//
//  Tests.swift
//  Tests
//
//  Created by Ahmadreza on 7/15/24.
//

import XCTest
@testable import pure_swift_networking

final class Tests: XCTestCase {
    
    func testNamePopularityAPICall() async {
        do {
            let response = try await namePopularityAPICall()
            XCTAssertEqual(response.name, "ahmad")
            XCTAssertEqual(response.count, 273848)
            XCTAssertEqual(response.gender, .male)
        } catch {
            XCTFail("failed to parse data")
        }
    }
    
    private func namePopularityAPICall() async throws -> NameResponse {
        let spyProvicer = SpyNetworkProvider()
        let webService = WebService(provider: spyProvicer)
        return try await webService.getNameData(name: "Ahmad")
    }
}
