//
//  String+Authentication.swift
//  TouchBarLeague
//
//  Created by Marcin Slusarek on 15/05/2019.
//  Copyright © 2019 Marcin Slusarek. All rights reserved.
//

import Foundation

extension String {
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
    
    func shell() -> String{
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", self]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output: String = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
            
        return output
    }
}
