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
   
    private func baseRequest<T: Codable>(for requestManager: RequestManager, type: T.Type, isErrorBannerEnabled: Bool = true) async throws -> T {
        do {
            let data = try await baseRequestAPICall(requestManager, isErrorBannerEnabled: isErrorBannerEnabled)
            logger(requestManager: requestManager, data: data)
            showErrorBanner(for: data, url: requestManager.urlRequest?.url?.absoluteString, isErrorBannerEnabled: isErrorBannerEnabled, isLoggingEnabled: false)
            return try baseRequestDecodeData(data, for: T.self)
        } catch {
            throw error
        }
    }

    
    private func baseRequestAPICall(_ requestManager: RequestManager, isErrorBannerEnabled: Bool = true) async throws -> Data {
        guard isNetworkConnectionReachable else { throw NetworkError.noConnection }
        var urlRequest = requestManager.urlRequest
        urlRequest?.timeoutInterval = timeOutDuration
        AF.session.configuration.timeoutIntervalForRequest = timeOutDuration
        return await withCheckedContinuation { continuation in
            AF.request(urlRequest!, interceptor: NetworkInterceptor(webService: self)).validate().responseData { [weak self] response in
                if let data = response.data {
                    continuation.resume(returning: data)
                } else if let errorData = response.error, let error = errorData.errorDescription {
                    print("\n*** json error for \(requestManager.urlRequest?.url?.absoluteString ?? "") => \(error)\n")
                    self?.handleBaseRequestAPICallError(errorData, response, isErrorBannerEnabled: isErrorBannerEnabled)
                    continuation.resume(returning: Data())
                } else {
                    self?.handleBaseRequestAPICallError(.sessionTaskFailed(error: response.error ?? NetworkError.decodingDataCorrupted), response, isErrorBannerEnabled: isErrorBannerEnabled)
                    continuation.resume(returning: Data())
                }
                return
            }
        }
    }
    
    private func handleBaseRequestAPICallError(_ error: AFError, _ response: AFDataResponse<Data>, isErrorBannerEnabled: Bool) {
        switch error {
        case .responseSerializationFailed(let reason):
            print("*** Error => responseSerializationFailed => ", reason)
        case .serverTrustEvaluationFailed:
            print("*** Certificate Pinning Error")
        case .sessionTaskFailed(let error):
            print("*** sessionTaskFailed Error:", error)
        default:
            print("*** other Error:", error)
        }
    }
    
    private func showErrorBanner(for data: Data?, url: String?, isErrorBannerEnabled: Bool, isLoggingEnabled: Bool) {
        if let data = data {
            do {
                
                // MARK: If you have a custom error model, you can parse it here
                //                let customError = try baseRequestDecodeData(data, for: ErrorModel.self)
                if isErrorBannerEnabled {
                    //                    let code = customError.result.status.code?.intValue ?? customError.result.status.statusCode?.intValue ?? 101
                    //                    if code != 200 {
                    print("*** FAILURE => for => \(String(describing: url))")
                    //                    mainThread {
                    //                            BannerManager.showMessage(messageText: "error".localized())
                    //                    }
                    //                    }
                }
            } catch {
                if isLoggingEnabled {
                    print("*** FAILURE => ERROR DESCRIPTION => \(String(describing: error.localizedDescription))")
                }
            }
        } else {
            if isLoggingEnabled {
                print("*** FAILURE => ERROR DESCRIPTION => There is no data to parse for \(url?.description ?? "?")")
            }
        }
    }


    private func baseRequestDecodeData<T: Codable>(_ data: Data, for type: T.Type, isLogEnabled: Bool = true) throws -> T {
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch DecodingError.dataCorrupted(let context) {
            if isLogEnabled {
                print("*** Decode Error - dataCorrupted : \(context)")
            }
            throw NetworkError.decodingDataCorrupted
        } catch DecodingError.keyNotFound(let key, let context) {
            if isLogEnabled {
                print("*** Decode Error - keyNotFound | Key '\(key)' not found: \(context.debugDescription)")
            }
            throw NetworkError.decodingKeyNotFound
        } catch DecodingError.valueNotFound(let value, let context) {
            if isLogEnabled {
                print("*** Decode Error - valueNotFound | Value '\(value)' not found: \(context.debugDescription)")
            }
            throw NetworkError.decodingValueNotFound
        } catch DecodingError.typeMismatch( _, let context) {
            if isLogEnabled {
                print("*** Decode Error - Type Mismatch | mismatch: \(context.debugDescription), coding Path: \(context.codingPath).")
            }
            throw NetworkError.decodingTypeMisMatch
        } catch {
            if isLogEnabled {
                print("*** error: \(error)")
            }
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
