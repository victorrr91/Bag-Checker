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

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16.0

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.register(ChecklistViewCell.self, forCellWithReuseIdentifier: ChecklistViewCell.identifier)

        collectionView.register(
            ChecklistHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: ChecklistHeaderView.identifier
        )

        return collectionView
    }()

    private lazy var addChecklistButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus.circle"), for: .normal)

        button.addTarget(self, action: #selector(didTapAddChecklistButton), for: .touchUpInside)

        return button
    }()

    private lazy var separator: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground

        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()

        currentCategory = UserDefaults.standard.categories.first ?? ""
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        categories = UserDefaults.standard.categories
        checklists = UserDefaults.standard.getChecklists(currentCategory)
    }

    override func viewWillDisappear(_ animated: Bool) {
        UserDefaults.standard.setChecklists(checklists, currentCategory)

        super.viewWillDisappear(animated)
    }
}

extension ChecklistViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ChecklistViewCell.identifier,
            for: indexPath
        ) as? ChecklistViewCell
        else { return UICollectionViewCell() }
        let checklist = checklists[indexPath.row]

        cell.stateButton.tag = indexPath.row
        cell.setup(checklist: checklist, delegate: self)

        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: ChecklistHeaderView.identifier,
            for: indexPath
        ) as? ChecklistHeaderView
        else { return UICollectionReusableView() }

        header.setup(categories: categories, delegate: self)
        header.addButton.addTarget(self, action: #selector(didTapCategoryAddButton), for: .touchUpInside)

        return header
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return checklists.count
    }
}

extension ChecklistViewController: UICollectionViewDelegate {}

extension ChecklistViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = collectionView.frame.width
        let height = 36.0

        return CGSize(width: width, height: height)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        let width = collectionView.frame.width
        let height = 60.0

        return CGSize(width: width, height: height)
    }
}

extension ChecklistViewController: ChecklistViewCellDelegate {
    func checklistStateChanged(state: CheckState, index: Int) {
        checklists[index].state = state
    }
}

extension ChecklistViewController: ChecklistHeaderViewCellDelegate {
    func didSelectCategory(_ selectedCategory: String) {
        UserDefaults.standard.setChecklists(checklists, currentCategory)
        self.currentCategory = selectedCategory
        self.checklists = UserDefaults.standard.getChecklists(currentCategory)
        self.collectionView.reloadData()
    }
}

private extension ChecklistViewController {
    func setupLayout() {
        [collectionView, addChecklistButton, separator]
            .forEach { self.view.addSubview($0) }

        collectionView.snp.makeConstraints {
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

    @objc func didTapCategoryAddButton() {
        let alertController = UIAlertController(title: "카테고리 추가하기", message: nil, preferredStyle: .alert)
        alertController.addTextField()

        let confirm = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            guard let newCategory = alertController.textFields?[0].text else { return }

            if newCategory != "" {
                self?.categories.append(newCategory)
                UserDefaults.standard.categories = self?.categories ?? []
                UserDefaults.standard.addCategory(name: newCategory)

                self?.collectionView.reloadSections(IndexSet(integer: 0))

                // MARK: 이걸 안하면 왜인지 위로 튀었다가 내려옴
                self?.collectionView.reloadData()
            }
        }

        let cancel = UIAlertAction(title: "Cancel", style: .cancel)

        alertController.addAction(confirm)
        alertController.addAction(cancel)

        present(alertController, animated: true)
    }

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

                    self?.collectionView.reloadItems(at: [IndexPath(row: self?.checklists.count ?? 0, section: 0)])
                }
            }

            let cancel = UIAlertAction(title: "Cancel", style: .cancel)

            alertController.addAction(confirm)
            alertController.addAction(cancel)

            present(alertController, animated: true)
        }
    }
}
