//
//  ViewController.swift
//  lexicalAnalysisTool
//
//  Created by pjpjpj on 2018/4/14.
//  Copyright © 2018年 #incloud. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet weak var inputTextField: NSTextField!
   
    @IBOutlet weak var outputTextField: NSTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func selectFile(_ sender: Any) {
        let panel = NSOpenPanel.init()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        
        let finded : Int = panel.runModal().rawValue
        if finded == NSApplication.ModalResponse.OK.rawValue {
            for url in panel.urls {
                let codeData = try? Data.init(contentsOf: url)
                let codeString = String(data: codeData!, encoding: String.Encoding.utf8)
                print(codeString!)
                let analysisTool = PJAnalysisTool.init(inputCodeString: codeString!)
                analysisTool.longestWords()
            }
        }
    }
    
    @IBAction func lexicalAnyButton(_ sender: Any) {
        let analysisTool = PJAnalysisTool.init(inputCodeString: inputTextField.stringValue)
        analysisTool.longestWords()
    }
    
}

