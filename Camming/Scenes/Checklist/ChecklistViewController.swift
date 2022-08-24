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

    private lazy var addChecklistButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus.circle"), for: .normal)

        button.addTarget(self, action: #selector(didTapAddChecklistButton), for: .touchUpInside)

        return button
    }()

    @objc func didTapAddChecklistButton() {
        if checklists.last?.name != "" {
            let alertController = UIAlertController(
                title: "체크리스트 추가하기",
                message: "어떤 항목을 추가하시나요?",
                preferredStyle: .alert
            )
            alertController.addTextField()

            let confirm = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                guard let text = alertController.textFields?[0].text else { return }

                if text != "" {
                    let newChecklist = Checklist(name: text, state: .toBuy)
                    self?.checklists.append(newChecklist)

                    UserDefaults.standard.setChecklists(self?.checklists ?? [], self?.currentCategory ?? "")

                    self?.tableView.reloadData()
                }
            }

            let cancel = UIAlertAction(title: "Cancel", style: .cancel)

            alertController.addAction(confirm)
            alertController.addAction(cancel)

            present(alertController, animated: true)
        }

    }

    private lazy var separator: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground

        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()

        categories = UserDefaults.standard.categories
        currentCategory = categories.first ?? ""

        checklists = UserDefaults.standard.getChecklists(currentCategory)
        print(checklists)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }

    @objc func didTapCategoryAddButton() {
        let alertController = UIAlertController(title: "카테고리 추가하기", message: nil, preferredStyle: .alert)
        alertController.addTextField()

        let confirm = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            guard let newCategory = alertController.textFields?[0].text else { return }

            if newCategory != "" {
                self?.categories.append(newCategory)
                UserDefaults.standard.categories = self?.categories ?? []
                UserDefaults.standard.addCategory(name: newCategory)

                self?.tableView.reloadSections(IndexSet(integer: 0), with: .none)

                // MARK: 이걸 안하면 왜인지 위로 튀었다가 내려옴
                self?.tableView.reloadData()
            }
        }

        let cancel = UIAlertAction(title: "Cancel", style: .cancel)

        alertController.addAction(confirm)
        alertController.addAction(cancel)

        present(alertController, animated: true)
    }
}

extension ChecklistViewController: UITableViewDelegate {
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
        checklists = UserDefaults.standard.getChecklists(currentCategory)
        tableView.reloadData()
    }
}

private extension ChecklistViewController {
    func setupLayout() {
        [tableView, addChecklistButton, separator]
            .forEach { self.view.addSubview($0) }

        tableView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(addChecklistButton.snp.top).offset(16.0)
        }

        addChecklistButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-1.0)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(60.0)
        }
        separator.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.top.equalTo(addChecklistButton.snp.bottom)
        }
    }
}
