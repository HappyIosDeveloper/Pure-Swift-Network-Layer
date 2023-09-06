//
//  RequestQueryParamManager.swift
//  pure swift networking
//
//  Created by Ahmadreza on 9/6/23.
//

import Foundation

class RequestQueryParamManager {
    
    static var shared = RequestQueryParamManager()

    func getQueryParam(for request: RequestManager)-> [String: Any]? {
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
