//
//  RequestURLManager.swift
//  pure swift networking
//
//  Created by Ahmadreza on 9/6/23.
//
import Foundation

class RequestURLManager {
    
    var request: RequestManager
    
    init(for request: RequestManager) {
        self.request = request
    }
    
    var urlString: String {
        switch request {
        case .name:
            return "https://api.genderize.io/"
        case .refreshToken:
            return "token/refresh"
        }
    }
}
