//
//  AutoRecommendController.swift
//  AutoRecommendDemo
//
//  Created by 李勇 on 2021/2/3.
//

import Foundation
import UIKit

/// 实现的算法列表，要体验啥就点啥
class AutoRecommendController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "实现的算法，体验啥就点啥"
        let tableView = UITableView(frame: self.view.bounds, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        self.view.addSubview(tableView)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        switch indexPath.row {
        case 0: cell.textLabel?.text = "分割字符串为拼音"
        case 1: cell.textLabel?.text = "通过拼音找到同音汉字"
        case 2: cell.textLabel?.text = "通过汉字得到推荐结果"
        case 3: cell.textLabel?.text = "集成实现输入联想功能"
        default: break
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0: self.navigationController?.pushViewController(SeparationController(), animated: true)
        case 1: self.navigationController?.pushViewController(FindWordsByPinYinController(), animated: true)
        case 2: self.navigationController?.pushViewController(FindRecommendByWordsController(), animated: true)
        case 3: self.navigationController?.pushViewController(InputAssociationController(), animated: true)
        default: break
        }
    }
}
