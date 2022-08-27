//
//  CategorySettingViewController.swift
//  Camming
//
//  Created by Victor Lee on 2022/08/27.
//

import Foundation
import UIKit
import SnapKit

protocol CategorySettingViewControllerDelegate: AnyObject {
    func tappedConfirmButton()
}

final class CategorySettingViewController: UIViewController {
    private var categories: [String]

    private weak var delegate: CategorySettingViewControllerDelegate?

    private lazy var tabelView: UITableView = {
        let tableView = UITableView()

        tableView.layer.borderWidth = 1.0
        tableView.layer.cornerRadius = 8.0
        tableView.layer.borderColor = UIColor.systemIndigo.cgColor

        tableView.isEditing = true

        tableView.register(
            CategorySettingViewCell.self,
            forCellReuseIdentifier: CategorySettingViewCell.identifier
        )

        tableView.dataSource = self
        tableView.delegate = self

        return tableView
    }()

    private lazy var addButton: UIButton = {
        let button = UIButton()

        button.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        button.tintColor = .systemIndigo

        button.addTarget(self, action: #selector(didTapAddCatogoryButton), for: .touchUpInside)

        return button
    }()

    @objc func didTapAddCatogoryButton() {
        let alertController = UIAlertController(title: "카테고리 추가하기", message: nil, preferredStyle: .alert)
        alertController.addTextField()

        let confirm = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            guard let newCategory = alertController.textFields?[0].text else { return }

            if newCategory != "" {
                self?.categories.append(newCategory)
                self?.tabelView.reloadData()
                self?.scrollToBottom()
            }
        }

        let cancel = UIAlertAction(title: "Cancel", style: .cancel)

        alertController.addAction(confirm)
        alertController.addAction(cancel)

        present(alertController, animated: true)
    }

    private lazy var confirmButton: UIButton = {
        let button = UIButton()

        button.setTitle("확인", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18.0, weight: .bold)
        button.titleLabel?.textColor = .white
        button.backgroundColor = .systemIndigo
        button.layer.cornerRadius = 8.0

        button.addTarget(self, action: #selector(didTapConfirmButton), for: .touchUpInside)

        return button
    }()

    @objc func didTapConfirmButton() {
        UserDefaults.standard.categories = categories
        delegate?.tappedConfirmButton()
        navigationController?.popViewController(animated: true)
    }

    init(categories: [String], delegate: CategorySettingViewControllerDelegate?) {
        self.categories = categories
        self.delegate = delegate

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        [tabelView, addButton, confirmButton]
            .forEach { view.addSubview($0) }

        tabelView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(80.0)
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(60.0)
            $0.height.equalTo(440.0)
        }

        addButton.snp.makeConstraints {
            $0.leading.trailing.equalTo(tabelView)
            $0.top.equalTo(tabelView.snp.bottom)
            $0.height.equalTo(50.0)
        }

        confirmButton.snp.makeConstraints {
            $0.leading.trailing.equalTo(addButton)
            $0.top.equalTo(addButton.snp.bottom).offset(8.0)
            $0.height.equalTo(50.0)
        }

        view.backgroundColor = .tertiarySystemBackground
    }

    func scrollToBottom(){
        let lastRowOfIndexPath = self.tabelView.numberOfRows(inSection: 0) - 1
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: lastRowOfIndexPath, section: 0)
            self.tabelView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
}

extension CategorySettingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CategorySettingViewCell.identifier,
            for: indexPath
        ) as? CategorySettingViewCell
        else { return UITableViewCell() }

        let category = categories[indexPath.row]
        cell.setup(category: category)

        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
}

extension CategorySettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let category: String = self.categories[sourceIndexPath.row]
        self.categories.remove(at: sourceIndexPath.row)
        self.categories.insert(category, at: destinationIndexPath.row)
    }


    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        self.categories.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}
