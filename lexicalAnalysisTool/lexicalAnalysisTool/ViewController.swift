//
//  ViewController.swift
//  lexicalAnalysisTool
//
//  Created by pjpjpj on 2018/4/14.
//  Copyright © 2018年 #incloud. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    @IBOutlet weak var inputTextField: NSTextField!
    @IBOutlet weak var outputTableView: NSTableView!

    var tokenArray = Array<[String : String]>()
    
    let typeID = "type"
    let wordID = "word"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputTextField.delegate = self as? NSTextFieldDelegate
        outputTableView.delegate = self
        outputTableView.dataSource = self
        
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
                tokenArray = analysisTool.lexicalAnalysis()
                
                outputTableView.reloadData()
            }
        }
    }
    
    @IBAction func lexicalAnyButton(_ sender: Any) {
        let analysisTool = PJAnalysisTool.init(inputCodeString: inputTextField.stringValue)
        tokenArray = analysisTool.lexicalAnalysis()
        outputTableView.reloadData()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return tokenArray.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        
        return nil
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let idString = tableColumn?.identifier
        
        if idString!.rawValue == "AutomaticTableColumnIdentifier.0" {
            var cellView = tableView.makeView(withIdentifier: idString!, owner: self)
            if (cellView != nil) {
                cellView = NSTableCellView.init(frame: NSMakeRect(0, 0, (tableColumn?.width)!, 20))
            } else {
                for view in (cellView?.subviews)! {
                    view.removeFromSuperview()
                }
            }
            
            let textField = NSTextField.init(frame: NSMakeRect(0, 0, (tableColumn?.width)!, (cellView?.frame.size.height)!))
            
            textField.stringValue = Array(tokenArray[row].keys)[0]
            textField.isBordered = false
            textField.isEditable = false
            textField.alignment = .left
            textField.backgroundColor = NSColor.clear
            cellView?.addSubview(textField)
            
            return cellView
        } else {
            var cellView = tableView.makeView(withIdentifier: idString!, owner: self)
            if (cellView != nil) {
                cellView = NSTableCellView.init(frame: NSMakeRect(0, 0, (tableColumn?.width)!, 20))
            } else {
                for view in (cellView?.subviews)! {
                    view.removeFromSuperview()
                }
            }
            
            let textField = NSTextField.init(frame: NSMakeRect(0, 0, (tableColumn?.width)!, (cellView?.frame.size.height)!))
            textField.stringValue = Array(tokenArray[row].values)[0]
            textField.isBordered = false
            textField.isEditable = false
            textField.alignment = .left
            textField.backgroundColor = NSColor.clear
            cellView?.addSubview(textField)
            
            return cellView
        }
    }
    
}


//extension ViewController: NSTableViewDataSource, NSTableViewDelegate {
//    
//    
//    
//}


