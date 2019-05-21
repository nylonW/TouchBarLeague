//
//  AppDelegate.swift
//  TouchBarLeague
//
//  Created by Marcin Slusarek on 13/05/2019.
//  Copyright © 2019 Marcin Slusarek. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    class func allowsAnyHTTPSCertificate(forHost host: String?) -> Bool {
        return true
    }
    
    @IBAction func quitAction(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

