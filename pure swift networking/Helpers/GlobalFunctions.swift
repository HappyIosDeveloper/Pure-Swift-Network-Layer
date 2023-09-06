//
//  GlobalFunctions.swift
//  pure swift networking
//
//  Created by Ahmadreza on 9/6/23.
//

import Foundation

func mainThread(function: @escaping ()-> Void) {
    DispatchQueue.main.async(execute: function)
}

func mainThreadAfter(seconds: Double, function: @escaping ()-> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: function)
}
