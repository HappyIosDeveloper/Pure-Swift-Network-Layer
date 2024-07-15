//
//  SpyNetworkProvider.swift
//  Tests
//
//  Created by Ahmadreza on 7/15/24.
//

import Alamofire
import Foundation
@testable import pure_swift_networking

/// This calss hijacks the base request functionality of the real NetworkProvider and loads responses from saved json files instead of making a real API call.
class SpyNetworkProvider: NetworkProvider {

    override func request<T>(for requestManager: RequestManager, type: T.Type, isErrorBannerEnabled: Bool = true) async throws -> T where T : Decodable, T : Encodable {
        return try await request(requestManager, isErrorBannerEnabled: isErrorBannerEnabled, type: type)
    }

    /// Checks if api call required a response and parses the response from a saved file from test target, otherwise throws an error.
    private func request<T: Decodable>(_ urlConvertible: URLRequestConvertible, isErrorBannerEnabled: Bool = true, type: T.Type) async throws -> T {
        let isException = try isURLAnException(url: urlConvertible, type: type)
        if isException {
            throw NetworkProvider.NetworkError.decodingDataCorrupted
        }
        let url = urlConvertible.urlRequest?.url?.absoluteString ?? ""
        var fileName = ""
        if url.contains("genderize.io/?name") {
            fileName = "nameResponse"
        } // continue the else if(s) here...
        let file = readFile(forName: fileName, fileType: "txt", type: type)!
        print("spy json for \(fileName) is => \(file)")
        return file
    }
}


// MARK: - Helper functions
extension SpyNetworkProvider {

    /// Some urls does not need to be parsed and could ignore
    private func isURLAnException<T: Decodable>(url: URLRequestConvertible, type: T.Type) throws -> Bool {
        let exceptions = ["not_required_api_call_1", "not_required_api_call_2"]
        if let parentheses = String(describing: url as! RequestManager).firstIndex(of: "(") {
            let requestName = String(describing: url as! RequestManager).prefix(upTo: parentheses)
            if exceptions.contains(requestName.description) {
                return true
            }
        }
        return false
    }

    private func readFile<T: Decodable>(forName name: String, fileType: String, type: T.Type) -> T? {
        do {
            let bundle = Bundle(for: SpyNetworkProvider.self)
            if let bundlePath = bundle.url(forResource: name, withExtension: fileType),
               let jsonData = try String(contentsOfFile: bundlePath.path).data(using: .utf8) {
                return try JSONDecoder().decode(type.self, from: jsonData)
            }
        } catch {
            print("reading file error:", error)
        }
        return nil
    }
}
