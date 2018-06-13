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
            noFinalityCharArray = Array<String>()
            rightCharArray = Array<String>()
            AllfinalityCharArray = Array<String>()
            AllNoFinalityCharArray = Array<String>()
            leftRelationRightOfLast = Dictionary<String, String>()
            leftRelationRightOfNull = Dictionary<String, String>()
            
            currentNoFinalityString = ""
            
            firstCollect = Dictionary<String, Array<String>>()
            followCollect = Dictionary<String, Array<String>>()
            selelctCollect = Dictionary<Int, Array<String>>()
            forecastCollect = Dictionary<String, Array<String>>()
            codeProcessCollect = Array<String>()
            
            formatString()
        }
    }
    
    // 为什么不用hash表，因为不支持 | 符号识别
    // 产生式 左部（名字是历史原因）
    private var noFinalityCharArray = Array<String>()
    // 产生式 右部（名字是历史原因）
    private var rightCharArray = Array<String>()
    // 所有的终结符
    private(set) var AllfinalityCharArray = Array<String>()
    // 所有的非终结符
    private var AllNoFinalityCharArray = Array<String>()
    // 左部和右部的关系字典 —— 存储为最后一个字符和左部的关系
    private var leftRelationRightOfLast = Dictionary<String, String>()
    // 左部和右部的关系字典 —— 存储为最后一个字符为空和左部的关系
    private var leftRelationRightOfNull = Dictionary<String, String>()
    private var currentNoFinalityString = ""
    
    private(set) var firstCollect = Dictionary<String, Array<String>>()
    private(set) var followCollect = Dictionary<String, Array<String>>()
    private(set) var selelctCollect = Dictionary<Int, Array<String>>()
    private(set) var forecastCollect = Dictionary<String, Array<String>>()
    private(set) var codeProcessCollect = Array<String>()

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
            rightCharArray.append(lineStringArray[1])
        }
        
        // 筛选出所有的非终结符
        for item in noFinalityCharArray {
            for c in item {
                if !AllNoFinalityCharArray.contains(c.description) {
                    AllNoFinalityCharArray.append(c.description)
                }
            }
        }
        
        // 筛选出所有的终结符
        for item in rightCharArray {
            for c in item {
                if !noFinalityCharArray.contains(c.description) &&
                    !AllfinalityCharArray.contains(c.description) &&
                    c.description != " " {
                    AllfinalityCharArray.append(c.description)
                }
            }
        }
        AllfinalityCharArray.append("#")
        
        // 求first集
        for item in noFinalityCharArray {
            currentNoFinalityString = item
            firstCollect(nofinalityString: item)
        }
        
        // 求follow集
        getFollowCollect()
        
        // 求select集
        getSelectCollect()
        
        // 求预测分析表
        getForecasrCollect()
    }
    
    private func firstCollect(nofinalityString: String) {
        var index = 0
        for item in noFinalityCharArray {
            if item == nofinalityString {
                let finalityString = rightCharArray[index]
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
    
    public func getFollowCollect() {
        var index = 0
        for item in noFinalityCharArray {
            if index == 0 {
                followCollect[item] = ["#"]
            }
            
            let rightString = rightCharArray[index]
            var charIndex = 0
            var firstNoFinalityChar = ""
            for char in rightString {
                // 找到产生式中的第一个非终结符
                if noFinalityCharArray.contains(char.description) {
                    if firstNoFinalityChar == "" {
                        firstNoFinalityChar = char.description
                        break
                    }
                }
                charIndex += 1
            }
            // 如果只有终结符，则直接下一个产生式
            if charIndex == rightString.count {
                index += 1
                continue
            }
            
            if charIndex < rightString.count {
                charIndex += 1
                if charIndex == rightString.count {
                    if leftRelationRightOfLast[firstNoFinalityChar] == nil {
                        leftRelationRightOfLast[firstNoFinalityChar] = item
                    }
                    index += 1
                    continue
                }
                let nextChar = rightString[rightString.index(rightString.startIndex, offsetBy: charIndex)]
                
                // 若下一个字符为终结符，则把该终结符加入
                if AllfinalityCharArray.contains(nextChar.description) {
                    if followCollect[firstNoFinalityChar] != nil {
                        var array = followCollect[firstNoFinalityChar]
                        if !(array?.contains(String(nextChar)))! {
                            array?.append(String(nextChar))
                            followCollect[firstNoFinalityChar] = array
                        }
                    } else {
                        followCollect[firstNoFinalityChar] = [String(nextChar)]
                    }
                } else {
                    if noFinalityCharArray.contains(nextChar.description) {
                        // 若下一个字符为非终结符，则把该终结符的first集加入
                        var finalityCharArray = firstCollect[nextChar.description]
                        // 遍历出 𝞮 ，并删除
                        var cIndex = 0
                        for c in finalityCharArray! {
                            if c == "𝞮" {
                                finalityCharArray?.remove(at: cIndex)
                                if leftRelationRightOfNull[firstNoFinalityChar] == nil {
                                    leftRelationRightOfNull[firstNoFinalityChar] = item
                                }
                            }
                            cIndex += 1
                        }
                        // 判空，添加follow集元素
                        if followCollect[firstNoFinalityChar] != nil {
                            var array = followCollect[firstNoFinalityChar]
                            for c in finalityCharArray! {
                                if !(array?.contains(c))! {
                                    array?.append(c)
                                }
                            }
                            followCollect[firstNoFinalityChar] = array
                        } else {
                            followCollect[firstNoFinalityChar] = finalityCharArray
                        }
                        
                        // 判断该非终结符的first集中是否含 𝞮 ，若有，则把follow(左部)直接加入
                        if (firstCollect[nextChar.description]?.contains("𝞮"))! {
                            if followCollect[item] != nil {
                                var array = followCollect[firstNoFinalityChar]
                                for c in followCollect[item]! {
                                    if !(array?.contains(c))! {
                                        array?.append(c)
                                    }
                                }
                                followCollect[firstNoFinalityChar] = array
                                if leftRelationRightOfLast[nextChar.description] == nil {
                                    leftRelationRightOfLast[nextChar.description] = item
                                }
                            }
                        }
                        
                        // 下一个字符为该产生式的最后一个字符
                        if charIndex + 1 == rightString.count {
                            if followCollect[nextChar.description] != nil {
                                // 处理如果左部并没有follow集时，当前字符为最后一个字符，要取左部的follow集时出错
                                // 解决办法：当遇到左部的follow集为nil时，给左部一个空数组就好啦~啊哈哈哈哈
                                if followCollect[item] == nil {
                                    followCollect[item] = []
                                    continue
                                }
                                var array = followCollect[nextChar.description]
                                for c in followCollect[item]! {
                                    if !(array?.contains(c))! {
                                        array?.append(c)
                                    }
                                }
                                followCollect[nextChar.description] = array
                            } else {
                                followCollect[nextChar.description] = followCollect[item]
                            }
                        }
                        
                    }
                }
            }
            
            index += 1
        }
        
        // 统一左部和右部follow
        for key in leftRelationRightOfNull.keys {
            var array = followCollect[key]
            for c in followCollect[leftRelationRightOfNull[key]!]! {
                if !(array?.contains(c))! {
                    array?.append(c)
                }
                followCollect[key] = array
            }
        }
        
        for key in leftRelationRightOfLast.keys {
            if followCollect[key] != nil {
                var array = followCollect[key]
                for c in followCollect[leftRelationRightOfLast[key]!]! {
                    if !(array?.contains(c))! {
                        array?.append(c)
                    }
                    followCollect[key] = array
                }
            } else {
                followCollect[key] = followCollect[leftRelationRightOfLast[key]!]!
            }
        }
    }
    
    private func getSelectCollect() {
        var itemIndex = 0
        for item in rightCharArray {
            // 取第一个字符
            let firstChar = item[item.startIndex]
            if noFinalityCharArray.contains(firstChar.description) {
                let firstCharFirstCollect = firstCollect[firstChar.description]
                if firstCharFirstCollect != nil {
                    if selelctCollect[itemIndex] != nil {
                        var array = selelctCollect[itemIndex]
                        for c in firstCharFirstCollect! {
                            if !(array?.contains(c))! {
                                array?.append(c)
                            }
                        }
                        selelctCollect[itemIndex] = array
                    } else {
                        selelctCollect[itemIndex] = firstCharFirstCollect
                    }
                }
            } else if firstChar != "𝞮" && AllfinalityCharArray.contains(firstChar.description) {
                if selelctCollect[itemIndex] != nil {
                    var array = selelctCollect[itemIndex]
                    if !(array?.contains(firstChar.description))! {
                        array?.append(firstChar.description)
                        selelctCollect[itemIndex] = array
                    }
                } else {
                    selelctCollect[itemIndex] = [firstChar.description]
                }
            } else if firstChar == "𝞮" {
                let itemFollowCollect = followCollect[noFinalityCharArray[itemIndex]]
                if itemFollowCollect != nil {
                    if selelctCollect[itemIndex] != nil {
                        var array = selelctCollect[itemIndex]
                        for c in itemFollowCollect! {
                            if !(array?.contains(c))! {
                                array?.append(firstChar.description)
                            }
                        }
                        selelctCollect[itemIndex] = array
                    } else {
                        selelctCollect[itemIndex] = itemFollowCollect
                    }
                }
            }
            
            itemIndex += 1
        }
    }
    
    private func getForecasrCollect() {
        var finalityArray = AllfinalityCharArray
        
        // 消 𝞮
        var itemIndex = 0
        for item in AllfinalityCharArray {
            if item == "𝞮" {
                finalityArray.remove(at: itemIndex)
            }
            itemIndex += 1
        }
        
        var keyIndex = 0
        let keys = selelctCollect.keys.sorted(by: <)
        for key in keys {
            let values = selelctCollect[key]
            
            let selectKey = noFinalityCharArray[keyIndex]
            for v in values! {
                var sIndex = 0
                for s in AllfinalityCharArray {
                    // 遍历拿到s所处在所有非终结符的位置
                    if s == v {
                        var forecaseArray = forecastCollect[selectKey]
                        if forecaseArray == nil {
                            forecaseArray = Array.init(repeating: " ", count: AllfinalityCharArray.count)
                        }
                        forecaseArray![sIndex] = rightCharArray[keyIndex]
                        forecastCollect[selectKey] = forecaseArray
                    }
                    sIndex += 1
                }
            }
            keyIndex += 1
        }
    }
    
    
    public func getComeoutProcess(codeString: String) -> Bool{
        codeProcessCollect = Array<String>()
        var code = codeString + "#"
        var stack = ["#", noFinalityCharArray[0]]
        
        var whileIndex = 0
        while true {
            var firstCodeChar = code[code.startIndex]
            if firstCodeChar.description == stack.last {
                if firstCodeChar.description == "#" && stack.last == "#" {
                    let string = "[\(stack.last!)]" + "     " + firstCodeChar.description + "     " + "#匹配"
                    codeProcessCollect.append(string)
                    break
                }
                
                let string = "[\(stack)]" + "     " + code + "     " + "\"\(firstCodeChar.description)匹配\""
                codeProcessCollect.append(string)
                
                stack.removeLast()
                code.remove(at: code.startIndex)
                firstCodeChar = code[code.startIndex]
                
                // 防止删除后，直接匹配结束，再判断一次
                if firstCodeChar.description == "#" && stack.last == "#" {
                    let string = "[\(stack.last!)]" + "     " + firstCodeChar.description + "     " + "#匹配"
                    codeProcessCollect.append(string)
                    break
                }
                continue
            }
            
            // 产生式
            var production = ""
            if stack.last != " " {
                // 如果未在预测分析表中找到对应的产生式
                if forecastCollect[stack.last!] == nil {
                    return false
                }
                let forecastStringArray = forecastCollect[stack.last!]
                var itemIndex = 0
                for item in AllfinalityCharArray {
                    if item == firstCodeChar.description {
                        production = forecastStringArray![itemIndex]
                        // 如果在预测分析表中找到的产生式为 “ ”
                        if production == " " {
                            return false
                        }
                        let string = "[\(stack)]" + "     " + code + "     " + stack.last! + "->" + production
                        codeProcessCollect.append(string)
                        // 如果在分析表中找到了匹配的产生式，则把stack中对应的左部删除并替换
                        stack.removeLast()
                        if production == "𝞮" {
                            break
                        }
                        // 翻转产生式，入栈
                        var convertProduction = ""
                        for s in production {
                            convertProduction = s.description + convertProduction
                        }
                        for c in convertProduction {
                            stack.append(c.description)
                        }
                        break
                    }
                    itemIndex += 1
                }
                // 如果找了一遍对应非终结符预测分析表，还是没能找到对应产生式
                if itemIndex == AllfinalityCharArray.count {
                    return false
                }
            }
            whileIndex += 1
        }
        // 如果一切顺利，则大吉大利，今晚吃鸡
        return true
    }
    
}
