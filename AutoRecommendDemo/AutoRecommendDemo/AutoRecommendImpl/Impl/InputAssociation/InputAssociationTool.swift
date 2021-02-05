//
//  InputAssociationTool.swift
//  AutoRecommendDemo
//
//  Created by 李勇 on 2021/2/5.
//

import Foundation

class InputAssociationTool {
    static let shared = InputAssociationTool()

    /// 这里逻辑稍微麻烦一点，不过理清楚了还是很好理解
    func inputAssociation(str: String) -> [String] {
        // 1：str到底能转换为多少种汉字的组合？比如"li勇"可以转换为["利勇", "李勇"...]
        var sentences: [String] = []
        self.coverToSentence(prefixStr: "", suffixStr: str, sentences: &sentences)

        // 2：遍历汉字的组合，组装推荐结果
        var results: [String] = []
        sentences.forEach { (sentence) in
            results.append(contentsOf: FindRecommendTool.shared.findRecommend(sentence: sentence))
        }
        return results
    }

    /// prefixStr：前面已经转换好的汉字，suffixStr：需要转换的内容，sentences：存放所有结果
    private func coverToSentence(prefixStr: String, suffixStr: String, sentences: inout [String]){
        // 如果没有需要转换的内容了，说明都已经转换完了，prefixStr就是结果，添加即可
        if suffixStr.isEmpty { sentences.append(prefixStr); return }

        // 如果prefixStr本身就不是词库中任何语句的前缀，则不需要进行后续步骤，可以省一些时间
        if !prefixStr.isEmpty, !FindRecommendTool.shared.checkRecommend(sentence: prefixStr) { return }

        // 找到第一个不为汉字的下标，我们只需要对非汉字进行转换，举个例子prefixStr = "", suffixStr = "你lian好"
        if let firstIndex = suffixStr.firstIndex(where: { ($0 >= "A" && $0 <= "z") }) { // 这个算法实现有问题，但不重要
            var prefixStr = prefixStr
            // 前面的都是汉字，直接填充到prefixStr中，prefixStr = "你"
            prefixStr += suffixStr.prefix(suffixStr.distance(from: suffixStr.startIndex, to: firstIndex))
            // suffixStr = "lian好"
            var suffixStr = suffixStr
            suffixStr.removeFirst(suffixStr.distance(from: suffixStr.startIndex, to: firstIndex))
            // 找到前面全是字母的字符串，pinYin = "lian"，suffixStr = "好"
            let pinYin: String
            if let nextIndex = suffixStr.firstIndex(where: { $0 > "z" || $0 < "A"}) { // 这个算法实现有问题，但不重要
                // 取出[firstIndex, nextIndex]的内容，这一截全是字母
                pinYin = String(suffixStr.prefix(suffixStr.distance(from: firstIndex, to: nextIndex)))
                suffixStr = String(suffixStr.suffix(suffixStr.count - suffixStr.distance(from: firstIndex, to: nextIndex)))
            } else {
                // 全是字母，后面无汉字
                pinYin = suffixStr
                suffixStr = ""
            }
            // pinYins = [["lian"], ["li", "an"]]
            let pinYins = SeparationTool.shared.separation(str: pinYin)
            // 遍历pinYins，找到能构成哪些汉字的组合["连", "李安", "李按", "利安"...]
            var words: [String] = []
            pinYins.forEach { self.findWords(pinYin: $0, word: "", words: &words) }
            // 把这些都加到prefixStr上，继续递归，prefixStr = "你连"、"你李安"、"你利安"...，suffixStr = "好"
            words.forEach { self.coverToSentence(prefixStr: prefixStr + $0, suffixStr: suffixStr, sentences: &sentences) }
            return
        }
        // 如果全是汉字，则直接拼接返回，比如prefixStr = "你"，suffixStr = "好"，那么结果只可能是"你好"
        sentences.append(prefixStr + suffixStr)
    }

    private func findWords(pinYin: [String], word: String, words: inout [String]) {
        // 如果后续没有拼音了，直接添加结果即可
        guard let first = pinYin.first else { words.append(word); return }

        // 找到第一个拼音的汉字，比如pinYin = ["li", "an"]，word = "我"，那么先找到"li"对应的汉字，然后拼接到word后继续递归
        // 比如下次递归：pinYin = ["an"]，"word" = "我李"、pinYin = ["an"]，"word" = "我利"...
        let results = FindWordsTool.shared.findWords(pinYin: first)
        results.forEach { self.findWords(pinYin: pinYin.suffix(pinYin.count - 1), word: word + $0, words: &words) }
    }
}
