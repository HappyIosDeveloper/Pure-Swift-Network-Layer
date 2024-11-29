//
//  RequestHeaderManager.swift
//  pure swift networking
//
//  Created by Ahmadreza on 9/6/23.
//

import Foundation

class RequestHeaderManager {
 
    var request: RequestManager
    
    init(for request: RequestManager) {
        self.request = request
    }
    
    var header: [(value: String?, field: String)]? {
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
