//
//  PJLLViewController.swift
//  lexicalAnalysisTool
//
//  Created by pjpjpj on 2018/6/8.
//  Copyright © 2018年 #incloud. All rights reserved.
//

import Cocoa

class PJLLViewController: NSViewController {

    @IBOutlet var inputView: NSTextView!
    @IBOutlet var outputView: NSTextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    private func initView() {
        outputView.isEditable = false
    }
    
    @IBAction private func selectFile(_ sender: NSButton) {
        let panel = NSOpenPanel.init()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        
        let finded : Int = panel.runModal().rawValue
        if finded == NSApplication.ModalResponse.OK.rawValue {
            for url in panel.urls {
                let codeData = try? Data.init(contentsOf: url)
                let codeString = String(data: codeData!, encoding: String.Encoding.utf8)
                PJLLOneTool.shared().inputString = codeString!
                inputView.string = codeString!
                outputView.string = ""
            }
        }
    }
    
    @IBAction func firstCollect(_ sender: NSButton) {
        var finalString = ""
        let keys = PJLLOneTool.shared().firstCollect.keys
        for key in keys {
            let values = PJLLOneTool.shared().firstCollect[key]
            var keyString = "\(key) : "
            var index = 0
            for value in values! {
                if index == (values?.count)! - 1 {
                    keyString = keyString + "[ \(value) ]"
                } else {
                    keyString = keyString + "[ \(value) ]、"
                }
                index += 1
            }
            finalString = finalString + keyString + "\n"
        }
        outputView.string = finalString
    }
    
    @IBAction func followCollect(_ sender: NSButton) {
        var finalString = ""
        let keys = PJLLOneTool.shared().followCollect.keys
        for key in keys {
            let values = PJLLOneTool.shared().followCollect[key]
            var keyString = "\(key) : "
            var index = 0
            for value in values! {
                if index == (values?.count)! - 1 {
                    keyString = keyString + "[ \(value) ]"
                } else {
                    keyString = keyString + "[ \(value) ]、"
                }
                index += 1
            }
            finalString = finalString + keyString + "\n"
        }
        outputView.string = finalString
    }
    
    @IBAction func selectCollect(_ sender: NSButton) {
    }
    
    @IBAction func analysisTable(_ sender: NSButton) {
    }
    
    @IBAction func comeoutProcess(_ sender: NSButton) {
    }
    
    
    
}
