//
//  ViewController.swift
//  TouchBarLeague
//
//  Created by Marcin Slusarek on 13/05/2019.
//  Copyright © 2019 Marcin Slusarek. All rights reserved.
//

import Cocoa
import Foundation
import AppKit
import TouchBarHelper
import ObjectMapper
import Alamofire

private let kBearIdentifier = NSTouchBarItem.Identifier("io.a2.Bear")
private let kPandaIdentifier = NSTouchBarItem.Identifier("io.a2.Panda")
private let kGroupIdentifier = NSTouchBarItem.Identifier("io.a2.Group")

class ViewController: NSViewController, NSTouchBarDelegate {

    let findLolPathCommand = "ps x -o comm= | grep 'LeagueClientUx$'"
    
    var lolPath: String?
    var groupTouchBar = NSTouchBar()
    
    var groupTouchBarA: NSTouchBar {
        let groupTouchBar = NSTouchBar()
        groupTouchBar.defaultItemIdentifiers = [kBearIdentifier, kPandaIdentifier]
        groupTouchBar.delegate = self
        self.groupTouchBar = groupTouchBar
        
        return self.groupTouchBar
    }
    
    fileprivate func authenticateLcu() {
        lolPath = "\(shell(findLolPathCommand))"
        lolPath = lolPath?.components(separatedBy: "/RADS")[0]
        let lockfile = shell("head \"\(lolPath ?? "")/lockfile\"")
        print(lockfile)
        let credentials = lockfile.split(separator: ":")
        let header = "Basic \("riot:\(credentials[3])".toBase64())"
        let acceptHeader = HTTPHeader(name: "Accept", value: "application/json")
        let headers = HTTPHeaders([HTTPHeader(name: "Authorization", value: header), acceptHeader])
        print(header)
        //62621
        RequestWrapper.requestGETURL(Constants.endpoints.getCurrentSummoner(withPort: String(credentials[2])), headers: headers, success: { (JSONResponse) in
            print("success")
            if let summoner = Mapper<CurrentSummoner>().map(JSONString: JSONResponse) {
                print(summoner.summonerId!)
            }
        }, failure: { (error) in
            print("failed...")
            print(error)
        })
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DFRSystemModalShowsCloseBoxWhenFrontMost(true)
        
        let panda = NSCustomTouchBarItem(identifier: kPandaIdentifier)
        panda.view = NSButton(title: "🤬", target: self, action: #selector(self.present(_:)))
        NSTouchBarItem.addSystemTrayItem(panda)
        DFRElementSetControlStripPresenceForIdentifier(kPandaIdentifier, true)
        
        authenticateLcu()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func shell(_ command: String) -> String {
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", command]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output: String = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
        
        return output
    }
    
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        if identifier == kBearIdentifier {
            let bear = NSCustomTouchBarItem(identifier: kBearIdentifier)
            bear.view = NSButton(title: "🙃", target: self, action: #selector(self.bear(_:)))
            return bear
        } else if (identifier == kPandaIdentifier) {
            let panda = NSCustomTouchBarItem(identifier: kPandaIdentifier)
            panda.view = NSButton(title: "🥺", target: self, action: #selector(self.bear(_:)))
            return panda
        } else {
            return nil
        }
    }
    
    @objc func bear(_ sender: Any?) {
        print("First button clicked")
    }
    
    @objc func present(_ sender: Any?) {
        if #available(macOS 10.14, *) {
            NSTouchBar.presentSystemModalTouchBar(self.groupTouchBarA, systemTrayItemIdentifier: kPandaIdentifier)
        } else {
            NSTouchBar.presentSystemModalFunctionBar(self.groupTouchBarA, systemTrayItemIdentifier: kPandaIdentifier)
        }
    }
}

