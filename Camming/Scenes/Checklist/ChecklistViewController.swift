//
//  ChecklistViewController.swift
//  Camming
//
//  Created by Victor Lee on 2022/08/20.
//

import Foundation
import UIKit
import SnapKit

final class ChecklistViewController: UIViewController {
    private var currentCategory = ""
    // 임시 category
    private var categories: [String] = []
    private var checklists: [Checklist] = []

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self

        tableView.register(
            ChecklistTableViewCell.self,
            forCellReuseIdentifier: ChecklistTableViewCell.identifier
        )
        tableView.register(
            ChecklistTableHeaderView.self,
            forHeaderFooterViewReuseIdentifier: ChecklistTableHeaderView.identifier
        )

        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()

        categories = UserDefaults.standard.categories
        currentCategory = categories.first ?? ""

//        UserDefaults.standard.setChecklists(Checklist(name: "젓가락", state: .toBuy), currentCategory)
//        UserDefaults.standard.setChecklists(Checklist(name: "숟가락", state: .toPack), currentCategory)

        checklists = UserDefaults.standard.getChecklists(currentCategory)
        print(checklists)
        print("aa")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
}

extension ChecklistViewController: UITableViewDelegate {
    // 클릭은 개별로 이루어져야하니까 row를 통째로 잡을 이벤트가 있을까
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        checklists = data["용품"] ?? []
//        print(checklists[indexPath.row])
//    }
}

extension ChecklistViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return checklists.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ChecklistTableViewCell.identifier,
            for: indexPath
        ) as? ChecklistTableViewCell
        else { return UITableViewCell() }

        let checklist = checklists[indexPath.row]

        cell.setup(checklist)

        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: ChecklistTableHeaderView.identifier
        ) as? ChecklistTableHeaderView
        else { return UIView() }

        header.setup(categories: categories, delegate: self)
        header.addButton.addTarget(self, action: #selector(didTapCategoryAddButton), for: .touchUpInside)

        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
}

extension ChecklistViewController: ChecklistTableHeaderViewDelegate {
    func didSelectCategory(_ selectedCategory: String) {
        currentCategory = selectedCategory
        print("지금이야", currentCategory)
        checklists = UserDefaults.standard.getChecklists(currentCategory)
        tableView.reloadData()
    }
}

private extension ChecklistViewController {
    func setupLayout() {
        view.addSubview(tableView)

        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    @objc func didTapCategoryAddButton() {
        let alertController = UIAlertController(title: "카테고리 추가하기", message: nil, preferredStyle: .alert)
        alertController.addTextField()

        let confirm = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            guard let newCategory = alertController.textFields?[0].text else { return }

            self?.categories.append(newCategory)
            UserDefaults.standard.categories = self?.categories ?? []
            UserDefaults.standard.addCategory(name: newCategory)

            self?.tableView.reloadSections(IndexSet(integer: 0), with: .none)

            // MARK: 이걸 안하면 왜인지 위로 튀었다가 내려옴
            self?.tableView.reloadData()
        }

        let cancel = UIAlertAction(title: "Cancel", style: .cancel)

        alertController.addAction(confirm)
        alertController.addAction(cancel)

        present(alertController, animated: true)
    }
}
