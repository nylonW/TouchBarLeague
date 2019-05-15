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

    //MARK: - Properties
    
    var groupTouchBar = NSTouchBar()
    
    var groupTouchBarA: NSTouchBar {
        let groupTouchBar = NSTouchBar()
        groupTouchBar.defaultItemIdentifiers = [kBearIdentifier, kPandaIdentifier]
        groupTouchBar.delegate = self
        self.groupTouchBar = groupTouchBar
        
        return self.groupTouchBar
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    //MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DFRSystemModalShowsCloseBoxWhenFrontMost(true)
        
        let panda = NSCustomTouchBarItem(identifier: kPandaIdentifier)
        panda.view = NSButton(title: "🤬", target: self, action: #selector(self.present(_:)))
        NSTouchBarItem.addSystemTrayItem(panda)
        DFRElementSetControlStripPresenceForIdentifier(kPandaIdentifier, true)
        print(LCU.shared)
    }
    
    //MARK: - Handlers
  
    
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

