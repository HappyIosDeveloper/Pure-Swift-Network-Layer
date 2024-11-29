//
//  RequestBodyManager.swift
//  pure swift networking
//
//  Created by Ahmadreza on 9/6/23.
//

import Foundation

class RequestBodyManager {
    
    var request: RequestManager
    
    init(for request: RequestManager) {
        self.request = request
    }
    
    var body: [String : Any]? {
        var result: [String : Any]?
        switch request {
        case .refreshToken:
            result = [
                "key": "value"
            ]
        default:
            break
        }
        return result
    }
}
