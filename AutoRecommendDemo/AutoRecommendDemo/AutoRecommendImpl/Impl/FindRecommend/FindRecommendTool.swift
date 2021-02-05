//
//  FindRecommendTool.swift
//  AutoRecommendDemo
//
//  Created by 李勇 on 2021/2/5.
//

import Foundation

class FindRecommendNode {
    /// 是否是句子的最后节点，比如"您好"中"好".complete = true
    private(set) var complete: Bool = false
    /// 该节点对应的汉字
    let value: String
    /// 包含的所有子节点，key为汉字
    private(set) var subNodes: [String: FindRecommendNode] = [:]

    init(value: String) {
        self.value = value
    }

    func insert(sentence: String) {
        // 如果后续没有字符需要继续插入，说明当前节点是句子的最后节点
        guard !sentence.isEmpty, let firstWord = sentence.first else { self.complete = true; return }

        // 判断是否存在子节点，没有就创建
        self.subNodes[String(firstWord)] = self.subNodes[String(firstWord)] ?? FindRecommendNode(value: String(firstWord))

        // 继续对对应子节点进行插入
        self.subNodes[String(firstWord)]?.insert(sentence: String(sentence.suffix(sentence.count - 1)))
    }

    /// 找到这个语句最后一个汉字所在的子树
    func find(sentence: String) -> FindRecommendNode? {
        // 如果后续没有字符需要继续查找，说明当前节点是找到的结果
        guard !sentence.isEmpty, let firstWord = sentence.first else { return self }

        guard let node = self.subNodes[String(firstWord)] else { return nil }

        return node.find(sentence: String(sentence.suffix(sentence.count - 1)))
    }
}

/// 查找推荐结果工具
class FindRecommendTool {
    static let shared = FindRecommendTool()
    /// 默认构造一个根节点，值为空
    private let root = FindRecommendNode(value: "")

    init() {
        // 用文章中的词库来测试
        let sentences = ["重阳", "重力", "你好", "你好呀", "你真忙", "种地"]
        let begin = NSDate().timeIntervalSince1970
        print("构造查找推荐结果字典树 begin")
        sentences.forEach { (sentence) in
            self.root.insert(sentence: sentence)
        }
        print("构造查找推荐结果字典树 end 耗时：\(NSDate().timeIntervalSince1970 - begin)")
    }

    /// sentence是否是词库中某些语句的前缀
    func checkRecommend(sentence: String) -> Bool {
        return self.root.find(sentence: sentence) != nil
    }

    func findRecommend(sentence: String) -> [String] {
        guard let trieNode = self.root.find(sentence: sentence) else { return [] }

        // 遍历这颗字典树，得到推荐结果
        var results: [String] = []
        self.sunFindRecommend(trieNode: trieNode, prefixStr: sentence, results: &results)
        return results
    }

    private func sunFindRecommend(trieNode: FindRecommendNode, prefixStr: String, results: inout [String]) {
        if trieNode.complete { results.append(prefixStr) }
        trieNode.subNodes.values.forEach { (node) in
            self.sunFindRecommend(trieNode: node, prefixStr: prefixStr + node.value, results: &results)
        }
    }
}
