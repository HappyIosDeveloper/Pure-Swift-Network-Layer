//
//  RequestBodyManager.swift
//  pure swift networking
//
//  Created by Ahmadreza on 9/6/23.
//

import Foundation

class RequestBodyManager {
    
    static var shared = RequestBodyManager()

    func getBody(for request: RequestManager)-> [String : Any]? {
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
