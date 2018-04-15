//
//  PJAnalysisTool.swift
//  lexicalAnalysisTool
//
//  Created by pjpjpj on 2018/4/14.
//  Copyright © 2018年 #incloud. All rights reserved.
//

import Cocoa

class PJAnalysisTool: NSObject {

    var inputCodeString: String = ""
    var outputAnalysisString: String = ""
    var token = Array<[String : String]>()
    
    // 操作符 OPT
    private let operatorWords = ["+", "-", "*", "/", "%", "<", ">", "=", ">=", "<=", "==", "!="]
    // 界符 MAR
    private let marginalWords = [";", "{", "}", "(", ")", " ", "\r", "\t", "\"", ",", "&"]
    // 注释 ANT
    private let annotatedWords = ["//", "/*", "*/"]
    // 非法字符 ILG
    private let illegalWords = [".", "?", "!", "@", "#", "$", "^", "~", ":"]
    // 输入输出 INO
    private let intoutWords = ["%d", "%c", "%f", "%lf"]
    // 关键字 KEY
    private let keyWords = ["break", "case", "char", "const", "printf",
                            "continue", "default", "double", "else",
                            "enum", "extern", "float", "for", "goto",
                            "if", "int", "long", "redister", "return",
                            "sizeof", "static", "struct", "while",
                            "switch", "typedef", "unsigned", "void", "#include"]
    // 正常字符 NOR
    // 头文件 HED
    
    // designer
    init(inputCodeString : String) {
        self.inputCodeString = inputCodeString
    }
    
    func longestWords() -> Array<[String : String]> {
        var tampString = ""
        // 注释检测符号
        var annotatedStatus = false
        for singleChar in inputCodeString {
            if singleChar == "\n" {
                annotatedStatus = false
                continue
            }
            print(singleChar)
            
            if !marginalWords.contains(String(singleChar)) {
                tampString.append(singleChar)
            } else {
                if !annotatedStatus {
                    if annotatedWords.contains(tampString) {
                        annotatedStatus = true
                    }
                    
                    if tampString.contains(".h") {
                        token.append(["头文件": tampString])
                    }
                    
                    let tokenString = contanierType(keyString: tampString)
                    if !tokenString.isEmpty {
                        token.append([tokenString: tampString])
                    }
                    
                    if ![" ", "\n", ""].contains(String(singleChar)) {
                        token.append(["界符" : String(singleChar)])
                    }
                    
                    print(token)
                    
                    tampString = ""
                }
            }
        }
        
        return token
    }
    
    func contanierType(keyString: String) -> String {
        if operatorWords.contains(keyString) {
            return "操作符"
        } else if marginalWords.contains(keyString) {
            return "界符"
        } else if annotatedWords.contains(keyString) {
            return "注释"
        } else if keyWords.contains(keyString) {
            return "关键词"
        } else if illegalWords.contains(keyString) {
            return "非法字符"
        } else if inputNumberOrLetters(keyString) {
            return "正常字符"
        } else if intoutWords.contains(keyString) {
            return "输入输出"
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
