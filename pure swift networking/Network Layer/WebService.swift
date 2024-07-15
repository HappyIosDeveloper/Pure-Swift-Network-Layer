//
//  WebService.swift
//  pure swift networking
//
//  Created by Ahmadreza on 9/6/23.
//

import Foundation

class WebService: NSObject {
        
    private var provider: NetworkProvider
    
    init(provider: NetworkProvider = NetworkProvider()) {
        self.provider = provider
    }
    
    func getNameData(name: String) async throws -> NameResponse {
        return try await provider.request(for: .name(name: name), type: NameResponse.self)
    }
    
    func refreshToken() async throws -> RefreshTokenResponse {
        return try await provider.request(for: RequestManager.refreshToken, type: RefreshTokenResponse.self)
    }
}
