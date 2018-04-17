//
//  PJAnalysisTool.swift
//  lexicalAnalysisTool
//
//  Created by pjpjpj on 2018/4/14.
//  Copyright © 2018年 #incloud. All rights reserved.
//

import Cocoa

class PJAnalysisTool: NSObject {

    // 一行代码
    public var inputCodeString: String = ""
    // token表
    public var token = Array<[String : String]>()
    // 字符表
    public var workTable = Array<String>()
    // 词法分析无错
    public var isTrue: Bool = true
    // 代码出错行数
    public var wrongLine: Int = 0
    // 错误字符串
    public var wrongString: String = ""
    
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
    
    // MARK: init方法
    // designer
    public init(inputCodeString : String) {
        self.inputCodeString = inputCodeString
    }
    
    
    // MARK: 词法分析方法
    public func lexicalAnalysis() -> Array<[String : String]> {
        var tampString = ""
        // 注释检测符号
        var annotatedStatus = false
        var normalWordStatus = false
        var operatorStatus = false
        var tempLine = 1
        
        for singleChar in inputCodeString {
            if singleChar == "\n" {
                tempLine += 1
                annotatedStatus = false
                continue
            }

            // 检测界符
            if !marginalWords.contains(String(singleChar)) {
                tampString.append(singleChar)
            } else {
                // 检测注释
                if !annotatedStatus {
                    if annotatedWords.contains(tampString) {
                        annotatedStatus = true
                    }
                    
                    if tampString.contains(".h") {
                        token.append(["头文件": tampString])
                    }
                    
                    let tokenString = contanierType(keyString: tampString)
                    if !tokenString.isEmpty {
                        
                        // 插入字符表相关逻辑
                        if tokenString == "正常字符" {
                            // 检测变量是否错误
                            if numberOfHeaderString(tampString) {
                                isTrue = false
                                wrongLine = tempLine
                                wrongString = tampString
                                print(String(wrongLine) + tampString)
                            }
                            normalWordStatus = true
                        }
                        if normalWordStatus {
                            if tokenString == "操作符" {
                                if tampString == "=" {
                                    operatorStatus = true
                                    normalWordStatus = false
                                }
                            }
                        }
                        if operatorStatus {
                            if tokenString == "正常字符" {
                                workTable.append(tampString)
                                operatorStatus = false
                                normalWordStatus = false
                                token.append(["字符表": String(workTable.count - 1)])
                                if (token[token.count - 2]["操作符"] != nil) {
                                    token.remove(at: token.count - 2)
                                }
                                if (token[token.count - 2]["正常字符"] != nil) {
                                    token.remove(at: token.count - 2)
                                }
                                if (token[token.count - 2]["关键词"] != nil) {
                                    token.remove(at: token.count - 2)
                                }
                                // 填充到字符表中后需要把当前缓存字符串清空
                                tampString = ""
                                continue
                            }
                        }
                        
                        // 除了注释都可以被加入
                        if !annotatedStatus {
                            token.append([tokenString: tampString])
                        }
                    }
                    
                    if ![" ", "\n", ""].contains(String(singleChar)) {
                        token.append(["界符" : String(singleChar)])
                    }
                    
                    tampString = ""
                }
            }
        }
        
        return token
    }
    
    private func contanierType(keyString: String) -> String {
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
    
    private func inputNumberOrLetters(_ name: String) -> Bool {
        if name.isEmpty {
            return false
        }
        let regex = "[a-zA-Z0-9]*"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        let inputString = predicate.evaluate(with: name)
        return inputString
    }
    
    private func onlyInputTheNumber(_ string: String) -> Bool {
        let numString = "[0-9]*"
        let predicate = NSPredicate(format: "SELF MATCHES %@", numString)
        let number = predicate.evaluate(with: string)
        return number
    }
    
    func inputCapitalAndLowercaseLetter(_ string: String) -> Bool {
        let regex = "[a-zA-Z]*"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        let inputString = predicate.evaluate(with: string)
        return inputString
    }
    
    private func numberOfHeaderString(_ string: String) -> Bool {
        let headString = string.prefix(1)
        if onlyInputTheNumber(String(headString)) {
            for chaString in string {
                if inputCapitalAndLowercaseLetter(String(chaString)) {
                    return true
                }
            }
        }
        return false
    }
    
}
