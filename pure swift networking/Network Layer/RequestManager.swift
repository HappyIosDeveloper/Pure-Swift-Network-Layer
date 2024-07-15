//
//  RequestManager.swift
//  pure swift networking
//
//  Created by Ahmadreza on 9/6/23.
//

import Alamofire
import Foundation

enum HTTPHeaderField: String {
    case authorization = "Authorization"
    case contentType = "Content-Type"
    case clientId = "clientId"
    case clientSecret = "clientSecret"
    case scope = "scope"
}

enum ContentType: String {
    case json = "application/json"
}

enum RequestManager: URLRequestConvertible {

    case name(name: String)
    case refreshToken
    
    // MARK: Base Functions
    func asURLRequest() throws -> URLRequest {
        let url = try RequestURLManager.shared.getURL(for: self).asURL()
        let errorURL = URLRequest(url: URL(string: "FAILED TO ENCODE URL")!)
        var urlRequest = URLRequest(url: url)
        guard var urlComponents = URLComponents(string: urlRequest.description) else { return errorURL }
        if let parameters = RequestQueryParamManager.shared.getQueryParam(for: self), !parameters.isEmpty {
            var params = [URLQueryItem]()
            parameters.keys.forEach { key in
                params.append(URLQueryItem(name: key, value: parameters[key] as? String ?? ""))
            }
            urlComponents.queryItems = params
            if let url = urlComponents.url {
                urlRequest = URLRequest(url: url)
            } else {
                print("failed to create URLRequest")
            }
        }
        if let body = RequestBodyManager.shared.getBody(for: self) {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body)
        }
        urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.contentType.rawValue)
        if let headers = RequestHeaderManager.shared.getHeader(for: self) {
            for header in headers where header.value != nil {
                urlRequest.setValue(header.value ?? "", forHTTPHeaderField: header.field)
            }
        }
        urlRequest.httpMethod = method.rawValue
        return urlRequest
    }
}

// MARK: - Http Method
extension RequestManager {
    
    var method: HTTPMethod {
        return switch self {
        case .refreshToken: .post
        default: .get
        }
    }
}
