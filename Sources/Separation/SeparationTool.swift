//
//  SeparationTool.swift
//  AutoRecommendDemo
//
//  Created by 李勇 on 2021/2/5.
//

import Foundation

class SeparationNode {
    /// 该节点是否是某个拼音的最后一个字母，比如"abc"中"c".complete=true
    private var complete: Bool = false
    /// 该节点对应的字母，小写存放
    private let value: String
    /// 包含的所有子节点，key为字母，value为该字母对应的子节点
    private var subNodes: [String: SeparationNode] = [:]

    init(value: String) {
        self.value = value
    }

    /// 插入拼音
    func insert(pinYin: String) {
        // 如果后续没有字符需要继续插入，说明当前节点是一个完整节点，插入结束
        guard !pinYin.isEmpty, let firstChar = pinYin.first else { self.complete = true; return }

        // 判断是否存在子节点，没有就创建
        self.subNodes[String(firstChar)] = self.subNodes[String(firstChar)] ?? SeparationNode(value: String(firstChar))

        // 继续对该子节点插入拼音
        self.subNodes[String(firstChar)]?.insert(pinYin: String(pinYin.suffix(pinYin.count - 1)))
    }

    /// 某个拼音是否存在
    func find(pinYin: String) -> Bool {
        // 如果后续没有字符需要继续查找，说明当前节点是找到的结果
        guard !pinYin.isEmpty, let firstChar = pinYin.first?.lowercased() else { return self.complete }

        guard let node = self.subNodes[String(firstChar)] else { return false }

        return node.find(pinYin: String(pinYin.suffix(pinYin.count - 1)))
    }
}

/// 分割字符串工具
class SeparationTool {
    static let shared = SeparationTool()
    /// 默认构造一个根节点，值为空
    private let root = SeparationNode(value: "")

    init() {
        // 根据拼音表场景字典树
        let begin = NSDate().timeIntervalSince1970
        print("构造拼音字典树 begin")
        /// http://m.wdfxw.net/doc13608223.htm，这份拼音表可能有遗漏，如果你要应用到项目中，建议找一份更全的
        let allPinYins = "a o e en an ang eng ong ba bo bi bu bai bei bao biao bie ban bian ben bin bang beng bing pa po pi pu pai pei pao piao pou pie pan pian pen pin pang peng ping ma mo me mi mu mai mei mao miao mou miu mie man mian men min mang meng ming fa fo fu fei fou fan fen fang feng da de di du dai dei dui dao diao dou diu die dan dian duan duo dang deng ding dong ta te ti tu tai tao tiao tou tie tan tian tuan tun tuo tang teng ting tong na ne ni nu nü nai nei nao niao niu nie nüe nan nian nuan nen nin nuo nang niang neng ning nong la lia le li lu lü lai lei lao liao lou liu lie lüe lan lian luan lin lun luo lang liang leng ling long ga gua ge gu gai gei gui gao gou gan gen gun guan guo gang guang geng gong ka kua ke ku kai kuai kui kou kan kuan ken kun kuo kang kuang keng kong ha hua he hu hai hei hui hao hou han huan hen hun huo hang heng hong ji jia ju jiao jiu jie jüe jian jin jun jian juan jiang jing jiong qi qia qu qie qou qiu qüe qin qiao qian qiang qing qiong xi xu xia xiu xie xue xin xun xiao xian xuan xiang xing xiong zha zhua zhuo zhe zhi zhu zhai zhuai zhui zhao zhou zhan zhuan zhuo zhen zhun zhang zheng zhong cha che chi chu chuo chai chuai chui chou chan chuan chen chang chuang cheng chong sha shua she shi shu shuo shai shuai shui shao shou shan shuan shen shang shuang sheng re ri ru rui rao rou ran ruan ren run ruo rang reng rong za ze zi zu zai zei zui zao zou zan zuan zen zun zuo zang zeng zong ca ce ci cu cai cui cao cou can cuan cen cun cuo cang ceng cong sa se si su sai sui sao sou san suan sen sun suo sang seng song ya ye yi yu yao you yue yan yuan yin yun yang ying yong wa wo wu wai wei wan wen wang weng"
        allPinYins.split(separator: " ").forEach({ self.root.insert(pinYin: String($0)) })
        print("构造拼音字典树 end 耗时：\(NSDate().timeIntervalSince1970 - begin)")
    }

    /// 分割字符串，得到分割结果，例如："lian" -> [["li", "an"], ["lian"]]
    func separation(str: String) -> [[String]] {
        if str.isEmpty { return [] }

        var allResults: [[String]] = []
        self.subSeparation(suffixStr: str, results: [], allResults: &allResults)
        return allResults
    }

    /// suffixStr：还需要分割的字符串，results：已经分割的字符串所得到的拼音，allResults：全局结果
    private func subSeparation(suffixStr: String, results: [String], allResults: inout [[String]]) {
        // 如果suffixStr为空，说明不需要继续分割了，当前分割已是一组有效分割
        if suffixStr.isEmpty { allResults.append(results); return }

        // 对suffixStr进行分割处理，挨着取前count个字符判断是否是拼音即可
        for count in 1...suffixStr.count {
            let prefixStr = String(suffixStr.prefix(count))
            guard self.root.find(pinYin: prefixStr) else { continue }

            // 存放这次分割，继续后续分割
            var results = results
            results.append(prefixStr)
            self.subSeparation(suffixStr: String(suffixStr.suffix(suffixStr.count - count)), results: results, allResults: &allResults)
        }
    }
}
