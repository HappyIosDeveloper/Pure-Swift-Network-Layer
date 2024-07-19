//
//  NetworkInterceptor.swift
//  pure swift networking
//
//  Created by Ahmadreza on 9/6/23.
//

import Alamofire
import Foundation

// MARK: - Main Functions
class NetworkInterceptor: Alamofire.Interceptor {
    
    var maxRetry = 1
    private let lock = NSLock()
    private var requestsToRetry: [ (RetryResult) -> Void] = []
    
    override func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var request = urlRequest
        if let tokenHeader = request.headers.value(for: HTTPHeaderField.authorization.rawValue), !tokenHeader.isEmpty {
            request.headers.update(name: HTTPHeaderField.authorization.rawValue, value: "token")
        }
        completion(.success(request))
    }
    
    override func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        let requestURL = request.request?.urlRequest?.url?.absoluteString ?? ""
        let maxRetry = NetworkInterceptor.getMaxRetryCount(for: request.request?.url?.absoluteString)
        NetworkInterceptor.checkRequestForRetry(url: requestURL, retryCount: request.retryCount, maxRetry: maxRetry, statusCode: request.response?.statusCode ?? 0, error: error) { retryResult in
            completion(retryResult)
        } refreshToken: {
            self.refreshToken(request: request) { retryResult in
                completion(retryResult)
            }
        }
    }
}

// MARK: - Logics
extension NetworkInterceptor {
 
    static func getMaxRetryCount(for url: String?)-> Int {
        // You can use url to manage request counts
        if isNetworkConnectionReachable {
            return 0
        } else {
            return 1
        }
    }
    
    static func checkRequestForRetry(url: String, retryCount: Int, maxRetry: Int, statusCode: Int, error: Error, completion: @escaping (RetryResult) -> Void, refreshToken: @escaping ()-> Void) {
        if "token".isEmpty {
            completion(.doNotRetry)
        } else {
            if isNetworkConnectionReachable {
                print("*** REQUEST RETRIED \(retryCount) TIMES")
                if retryCount >= maxRetry && statusCode != 401 {
                    completion(.doNotRetry)
                } else if statusCode == 401 && !url.contains("token/refresh")  {
                    refreshToken()
                } else if statusCode == 401 && url.contains("token/refresh")  {
                    completion(.doNotRetry) // log out will handle from refresh token request itself, this one is for just in case.
                } else if 500..<600 ~= statusCode {
                    print("*** SERVER UNAVAILABLE ERROR")
                    completion(.doNotRetry)
                } else if let afError = error.asAFError, afError.isSessionTaskError {
                    completion(.retryWithDelay(TimeInterval(5)))
                } else {
                    completion(.retry)
                }
            } else {
                completion(.doNotRetry)
            }
        }
    }
}

// MARK: - API Calls
extension NetworkInterceptor {
    
    private func refreshToken(request: Request, completion: @escaping (RetryResult) -> Void) {
        lock.lock()
        defer {
            lock.unlock()
        }
        if request.task?.response is HTTPURLResponse {
            if isWebServiceRefreshingToken {
                completion(.retryWithDelay(5))
            } else {
                isWebServiceRefreshingToken = true
                callRefreshToken { [weak self] in
                    guard let self = self else { return }
                    self.lock.lock()
                    defer { self.lock.unlock() }
                    isWebServiceRefreshingToken = false
                    mainThreadAfter(seconds: 0.1) { // Some views might not updating without a small delay.
                        completion(.retry)
                    }
                } isForcedToShowFailedView: {
                    // show failed page
                } isForcedToLogOutUser: {
                    // DataManager.shared.removeEverything()
                    // show login page here
                }
            }
        } else {
            completion(.doNotRetry)
        }
    }
    
    private func callRefreshToken(isTokenRefreshed: @escaping ()-> Void, isForcedToShowFailedView: @escaping ()-> Void, isForcedToLogOutUser: @escaping ()-> Void) {
        Task { @MainActor in
            do {
                _ = try await WebService().refreshToken() // Or you could directly use the AF if you don't want to make the refrences complicated...
                isTokenRefreshed()
            } catch {
                isForcedToLogOutUser()
            }
        }
    }
}
