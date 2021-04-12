//
//  FindRecommendByWordsController.swift
//  AutoRecommendDemo
//
//  Created by 李勇 on 2021/2/3.
//

import Foundation
import UIKit

class FindRecommendByWordsController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    private var dataSource: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "通过汉字得到推荐结果"
        self.view.backgroundColor = .white
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let textField = UITextField(frame: CGRect(origin: CGPoint(x: 0, y: self.view.safeAreaInsets.top), size: CGSize(width: self.view.bounds.size.width, height: 35)))
        textField.borderStyle = .roundedRect
        textField.attributedPlaceholder = NSAttributedString(string: "在这里输入内容...", attributes: [.font: UIFont.systemFont(ofSize: 17)])
        textField.font = .systemFont(ofSize: 17)
        textField.delegate = self
        self.view.addSubview(textField)

        let tableView = UITableView(frame: CGRect(origin: CGPoint(x: 0, y: self.view.safeAreaInsets.top + 35), size: CGSize(width: self.view.bounds.size.width, height: self.view.bounds.height - self.view.safeAreaInsets.top - 50)), style: .plain)
        tableView.tableHeaderView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 0, height: 1)))
        tableView.tableFooterView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 0, height: 1)))
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tag = 1001
        tableView.keyboardDismissMode = .onDrag
        self.view.addSubview(tableView)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.dataSource = FindRecommendTool.shared.findRecommend(sentence: textField.text ?? "")
        if self.dataSource.isEmpty { self.dataSource = ["未找到推荐结果"] }
        (self.view.viewWithTag(1001) as? UITableView)?.reloadData()
        self.view.endEditing(true)
        return true
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = self.dataSource[indexPath.row]
        return cell
    }
}
