//
//  RequestQueryParamManager.swift
//  pure swift networking
//
//  Created by Ahmadreza on 9/6/23.
//

import Foundation

class RequestQueryParamManager {
    
    var request: RequestManager
    
    init(for request: RequestManager) {
        self.request = request
    }
    
    var queryParam: [String: Any]? {
        switch request {
        case .name(let name):
            return [
                "name": name
            ]
        default:
            return nil
        }
    }
}
