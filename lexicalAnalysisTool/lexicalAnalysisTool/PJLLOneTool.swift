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
            leftRelationRightOfLast = Dictionary<String, String>()
            leftRelationRightOfNull = Dictionary<String, String>()
            currentNoFinalityString = ""
            firstCollect = Dictionary<String, Array<String>>()
            followCollect = Dictionary<String, Array<String>>()
            
            formatString()
        }
    }
    
    // 为什么不用hash表，因为不支持 | 符号识别
    // 产生式 左部（名字是历史原因）
    private var noFinalityCharArray = Array<String>()
    // 产生式 右部（名字是历史原因）
    private var rightCharArray = Array<String>()
    // 所有的非终结符
    private var AllfinalityCharArray = Array<String>()
    // 左部和右部的关系字典 —— 存储为最后一个字符和左部的关系
    private var leftRelationRightOfLast = Dictionary<String, String>()
    // 左部和右部的关系字典 —— 存储为最后一个字符为空和左部的关系
    private var leftRelationRightOfNull = Dictionary<String, String>()
    private var currentNoFinalityString = ""
    
    private(set) var firstCollect = Dictionary<String, Array<String>>()
    private(set) var followCollect = Dictionary<String, Array<String>>()

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
        
        // 筛选出所有的终结符
        for item in rightCharArray {
            for c in item {
                if !noFinalityCharArray.contains(c.description) {
                    AllfinalityCharArray.append(c.description)
                }
            }
        }
        
        // 求first集
        for item in noFinalityCharArray {
            currentNoFinalityString = item
            firstCollect(nofinalityString: item)
        }
        
        // 求follow集
        getFollowCollect()
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
                print(nextChar)
                
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
    
}
