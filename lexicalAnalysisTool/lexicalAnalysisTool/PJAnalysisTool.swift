//
//  PJAnalysisTool.swift
//  lexicalAnalysisTool
//
//  Created by pjpjpj on 2018/4/14.
//  Copyright © 2018年 #incloud. All rights reserved.
//

import Cocoa

class PJAnalysisTool: NSObject {

    var inputCodeString  = String()
    var outputAnalysisString = String()
    var token = Array<[String : String]>()
    
    // 操作符 OPT
    private let operatorWords = ["+", "-", "*", "/", "%", "<", ">", "=", ">=", "<=", "==", "!="]
    // 界符 MAR
    private let marginalWords = [";", "{", "}", "(", ")", " ", "\r", "\t", "\""]
    // 注释 ANT
    private let annotatedWords = ["//", "/*", "*/"]
    // 非法字符 ILG
    private let illegalWords = [".", "?", "!", "@", "#", "$", "^", "~", ":"]
    // 正常字符 NOR
    // 关键字 KEY
    private let keyWords = ["break", "case", "char", "const", "printf",
                            "continue", "default", "double", "else",
                            "enum", "extern", "float", "for", "goto",
                            "if", "int", "long", "redister", "return",
                            "sizeof", "static", "struct", "while",
                            "switch", "typedef", "unsigned", "void",]
    
    // designer
    init(inputCodeString : String) {
        self.inputCodeString = inputCodeString
    }
    
    func longestWords() {
        var tampString = ""
        for singleChar in inputCodeString {
            if singleChar == "\n" {
                continue
            }
            print(singleChar)
            
            if !marginalWords.contains(String(singleChar)) {
                tampString.append(singleChar)
            } else {
                let tokenString = contanierType(keyString: tampString)
                if !tokenString.isEmpty {
                    token.append([tokenString: tampString])
                }
                
                if ![" ", "\n", ""].contains(String(singleChar)) {
                    token.append(["MAR" : String(singleChar)])
                }
                
                print(token)
                
                tampString = ""
            }
        }
    }
    
    func contanierType(keyString: String) -> String {
        if operatorWords.contains(keyString) {
            return "OPT"
        } else if marginalWords.contains(keyString) {
            return "MAR"
        } else if annotatedWords.contains(keyString) {
            return "ANT"
        } else if keyWords.contains(keyString) {
            return "KEY"
        } else if illegalWords.contains(keyString) {
            return "ILG"
        } else if inputNumberOrLetters(String(keyString)) {
            return "NOR"
        } else {
            return ""
        }
    }
    
    func inputNumberOrLetters(_ name: String) -> Bool {
        if name.isEmpty {
            return false
        }
        let regex = "[a-zA-Z0-9]*"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        let inputString = predicate.evaluate(with: name)
        return inputString
    }
    
}
