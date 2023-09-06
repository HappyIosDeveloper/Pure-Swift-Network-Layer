//
//  RequestURLManager.swift
//  pure swift networking
//
//  Created by Ahmadreza on 9/6/23.
//
import Foundation

class RequestURLManager {
    
    static var shared = RequestURLManager()
    
    func getURL(for request: RequestManager)-> String {
        switch request {
        case .name:
            return "https://api.genderize.io/"
        case .refreshToken:
            return "token/refresh"
        }
    }
}
