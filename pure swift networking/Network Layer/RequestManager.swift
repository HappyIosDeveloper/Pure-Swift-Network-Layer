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
        guard let url = try? RequestURLManager.shared.getURL(for: self).asURL() else { return URLRequest(url: URL(string: "FAILED TO ENCODE THIS URL => \(self.urlRequest?.url?.absoluteString ?? "?")")!)}
        var urlRequest = URLRequest(url: url)
        var urlComponents = URLComponents(string: "\(urlRequest)")
        if let parameters = RequestQueryParamManager.shared.getQueryParam(for: self) {
            var param = [URLQueryItem]()
            parameters.keys.forEach({ (key) in param.append(URLQueryItem(name: key, value: "\(parameters[key]!)")) })
            if !param.isEmpty {
                urlComponents?.queryItems = param
            }
        }
        urlRequest = URLRequest(url: (urlComponents?.url)!)
        if let body = RequestBodyManager.shared.getBody(for: self) {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body)
        }
        urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.contentType.rawValue)
        if let headers = RequestHeaderManager.shared.getHeader(for: self) {
            for header in headers {
                if let value = header.value {
                    urlRequest.setValue(value, forHTTPHeaderField: header.field)
                }
            }
        }
        urlRequest.httpMethod = getMethod().rawValue
        return urlRequest
    }
}

extension RequestManager {
    
    func getMethod()-> HTTPMethod {
        switch self {
        case .refreshToken:
            return .post
        default:
            return .get
        }
    }
}
