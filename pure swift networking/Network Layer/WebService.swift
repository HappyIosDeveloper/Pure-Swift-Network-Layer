//
//  WebService.swift
//  pure swift networking
//
//  Created by Ahmadreza on 9/6/23.
//

import Alamofire
import Foundation

class WebService: NSObject {
    
    private let timeOutDuration: Double = 30
    
    func getNameData(name: String) async throws -> NameResponse {
        return try await baseRequest(for: .name(name: name), type: NameResponse.self)
    }
    
    func refreshToken() async throws -> RefreshTokenResponse {
        return try await baseRequest(for: RequestManager.refreshToken, type: RefreshTokenResponse.self)
    }
}

// MARK: - Base Functions
extension WebService {
    
    private func baseRequest<T: Codable>(for requestManager: RequestManager, type: T.Type, shouldShowBackendError: Bool = true) async throws -> T {
        do {
            let data = try await baseRequestAPICall(requestManager, shouldShowBackendError: shouldShowBackendError)
            logger(requestManager: requestManager, data: data)
            return try baseRequestDecodeData(data, for: T.self)
        } catch {
            print("*** Failed to get data from  => ", requestManager.urlRequest?.url?.debugDescription ?? "?")
            throw error
        }
    }
    
    private func baseRequestAPICall(_ requestManager: RequestManager, shouldShowBackendError: Bool = true) async throws -> Data {
        guard isNetworkConnectionReachable else { throw NetworkError.noConnection }
        var urlRequest = requestManager.urlRequest
        urlRequest?.timeoutInterval = timeOutDuration
        AF.session.configuration.timeoutIntervalForRequest = timeOutDuration
        return try await withUnsafeThrowingContinuation { continuation in
            AF.request(urlRequest!, interceptor: NetworkInterceptor(webService: self)).validate().responseData { [weak self] response in
                if let data = response.data {
                    continuation.resume(returning: data)
                } else if let error = response.error {
                    mainThread {
                        self?.handleBaseRequestAPICallError(error, response, shouldShowBackendError: shouldShowBackendError)
                    }
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: NetworkError.gettingDataError)
                }
                return
            }
        }
    }
    
    private func handleBaseRequestAPICallError(_ error: AFError, _ response: AFDataResponse<Data>, shouldShowBackendError: Bool) {
        switch error {
        case .responseSerializationFailed(let reason):
            print("*** Error => responseSerializationFailed => ", reason)
            if shouldShowBackendError {
                //                BannerManager.showMessage(messageText: "error")
            }
        case .serverTrustEvaluationFailed:
            print("*** Certificate Pinning Error")
            if shouldShowBackendError {
                //                BannerManager.showMessage(messageText: "error")
            }
        case .sessionTaskFailed(let error):
            print("*** sessionTaskFailed Error:", error)
            if error.localizedDescription.contains("timed out") && shouldShowBackendError {
                //                BannerManager.showMessage(messageText: "error")
            }
        default:
            //            if let data = response.data {
            //                do {
            //                    let customError = try baseRequestDecodeData(data, for: ErrorModel.self)
            //                    print("*** FAILURE => ERROR DESCRIPTION => \(String(describing: response.request?.urlRequest?.url?.absoluteString))")
            //                    if shouldShowBackendError {
            //                       BannerManager.showMessage(messageText: customError.message)
            //                    }
            //                } catch {
            //                    print("*** FAILURE => ERROR DESCRIPTION => \(String(describing: error.localizedDescription))")
            //                }
            //            } else {
            print("*** FAILURE => ERROR DESCRIPTION => \(String(describing: error.errorDescription))")
            //            }
        }
    }
    
    private func baseRequestDecodeData<T: Codable>(_ data: Data, for type: T.Type) throws -> T {
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch DecodingError.dataCorrupted(let context) {
            print("*** Decode Error - dataCorrupted : \(context)")
            throw NetworkError.decodingDataCorrupted
        } catch DecodingError.keyNotFound(let key, let context) {
            print("*** Decode Error - keyNotFound | Key '\(key)' not found: \(context.debugDescription)")
            throw NetworkError.decodingKeyNotFound
        } catch DecodingError.valueNotFound(let value, let context) {
            print("*** Decode Error - valueNotFound | Value '\(value)' not found: \(context.debugDescription)")
            throw NetworkError.decodingValueNotFound
        } catch DecodingError.typeMismatch(let type, let context) {
            print("*** Decode Error - Type Mismatch | type: '\(type)' mismatch: \(context.debugDescription)")
            throw NetworkError.decodingTypeMisMatch
        } catch {
            print("*** error: \(error)")
            throw NetworkError.decodingUnknown
        }
    }
    
    private func logger(requestManager: RequestManager, data: Data) {
        print("\n\n")
        let urlRequest = requestManager.urlRequest
        print("*** REQUEST => \(urlRequest?.httpMethod ?? "?") | \(urlRequest?.url?.absoluteString ?? "?")")
        if let header = urlRequest?.headers {
            print("*** REQUEST HEADER => \(header)")
        }
        if let body = String(data: ((urlRequest?.httpBody) ?? "".data(using: .utf8))!, encoding:.utf8), body.description != "" {
            print("*** REQUEST BODY =>  \(body)")
        }
        if let utf8Text = String(data: data, encoding: .utf8) {
            print("\n*** json for \(requestManager.urlRequest?.url?.absoluteString ?? "") => \(utf8Text)\n")
        } else {
            print("*** error parsing response to json")
        }
    }
    
    enum NetworkError: Error {
        case decodingDataCorrupted
        case decodingKeyNotFound
        case decodingValueNotFound
        case decodingTypeMisMatch
        case decodingUnknown
        case noConnection
        case gettingDataError
        case generalDecodingError
    }
}
