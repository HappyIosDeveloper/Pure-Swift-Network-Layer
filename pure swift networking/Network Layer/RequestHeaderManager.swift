//
//  RequestHeaderManager.swift
//  pure swift networking
//
//  Created by Ahmadreza on 9/6/23.
//

import Foundation

class RequestHeaderManager {
    
    static var shared = RequestHeaderManager()
    
    func getHeader(for request: RequestManager)-> [(value: String?, field: String)]? {
        var result: [(value: String?, field: String)]?
        switch request {
        case .refreshToken:
            result = [
                (value: "value", field: "key"),
            ]
        default:
            break
//            result = [(value: "token", field: HTTPHeaderField.authorization.rawValue)]
        }
        return result
    }
}
