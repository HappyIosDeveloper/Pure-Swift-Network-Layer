//
//  Connectivity.swift
//  pure swift networking
//
//  Created by Ahmadreza on 9/6/23.
//

import Alamofire
import Foundation

class Connectivity {
    
    let networkReachabilityManager = Alamofire.NetworkReachabilityManager(host: "www.google.com")
    
    private var isUnitTesting: Bool {
        return Bundle.main.executableURL!.absoluteString.contains("XCTestDevices")
    }

    func checkForReachability(completion: @escaping (Bool) -> Void) {
        if isUnitTesting {
            completion(true)
        }
        networkReachabilityManager?.startListening(onUpdatePerforming: { status in
            print("Network Status: \(status)")
            isNetworkConnectionReachable = status == .notReachable ? false : true
            switch status {
            case .unknown, .reachable(_):
                completion(true)
            case .notReachable:
                completion(false)
            }
        })
    }
    
    func updateNetworkConnectivityStatus() {
        networkReachabilityManager?.startListening(onUpdatePerforming: { status in
            isNetworkConnectionReachable = status == .notReachable ? false : true
        })
    }
}
