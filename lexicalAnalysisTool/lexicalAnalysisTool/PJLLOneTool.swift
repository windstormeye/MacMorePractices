//
//  PJLLOneTool.swift
//  lexicalAnalysisTool
//
//  Created by pjpjpj on 2018/6/8.
//  Copyright © 2018年 #incloud. All rights reserved.
//

import Cocoa

class PJLLOneTool: NSObject {

    private static let sharedManager: PJLLOneTool = {
        let shared = PJLLOneTool()
        return shared
    }()
    
    var inputString: String? {
        didSet {
            formatString()
        }
    }
    
    private var noFinalityCharArray = Array<String>()
    private var finalityCharArray = Array<String>()
    private var currentNoFinalityString = ""
    
    private(set) var firstCollect = Dictionary<String, Array<String>>()

    class func shared() -> PJLLOneTool {
        return sharedManager
    }
    
    /*
     * 格式化 非终结符与终结符
     */
    private func formatString() {
        let inputStringArray = inputString?.components(separatedBy: "\n")
        for item in inputStringArray! {
            let lineStringArray = item.components(separatedBy: "->")
            noFinalityCharArray.append(lineStringArray[0])
            finalityCharArray.append(lineStringArray[1])
        }
        print(noFinalityCharArray)
        print(finalityCharArray)
        
        for item in noFinalityCharArray {
            currentNoFinalityString = item
            firstCollect(nofinalityString: item)
        }
        print(firstCollect)
    }
    
    private func firstCollect(nofinalityString: String) {
        var index = 0
        for item in noFinalityCharArray {
            if item == nofinalityString {
                let finalityString = finalityCharArray[index]
                let char = finalityString[finalityString.startIndex]
                if noFinalityCharArray.contains(char.description) {
                    firstCollect(nofinalityString: char.description)
                } else {
                    if firstCollect[currentNoFinalityString] != nil {
                        var colectArray = firstCollect[currentNoFinalityString]
                        if !(colectArray?.contains(char.description))! {
                            colectArray?.append(char.description)
                            firstCollect[currentNoFinalityString] = colectArray
                        }
                    } else {
                        var collectArray = Array<String>()
                        collectArray.append(char.description)
                        firstCollect[currentNoFinalityString] = collectArray
                    }
                }
            }
            
            index += 1
        }
    }
    
}
