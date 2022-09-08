//
//  ChecklistHeaderView.swift
//  Camming
//
//  Created by Victor Lee on 2022/08/22.
//

import UIKit
import SnapKit
import RealmSwift

final class ChecklistHeaderView: UICollectionReusableView {
    static let identifier = "ChecklistHeaderView"

    private var categories = List<Category>()
    private weak var delegate: ChecklistHeaderViewCellDelegate?

    private var selectCategory: Category?

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 20.0
        layout.itemSize = CGSize(width: 72.0, height: 32.0)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        collectionView.register(
            ChecklistHeaderViewCell.self,
            forCellWithReuseIdentifier: ChecklistHeaderViewCell.identifier
        )

        collectionView.dataSource = self

        return collectionView
    }()

    lazy var settingButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "gearshape.fill"), for: .normal)

        return button
    }()

    func setup(
        categories: List<Category>,
        delegate: ChecklistHeaderViewCellDelegate?,
        currentCategory: Category
    ) {
        self.categories = categories
        self.delegate = delegate
        self.selectCategory = currentCategory

        setupLayout()
    }
}

extension ChecklistHeaderView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let selectedCategory = selectCategory,
              let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ChecklistHeaderViewCell.identifier,
            for: indexPath
        ) as? ChecklistHeaderViewCell
        else { return UICollectionViewCell() }

        cell.categoryButton.tag = indexPath.item
        let category = categories[indexPath.item]

        if selectedCategory.name == category.name {
            cell.categoryButton.isSelected = true
        } else {
            cell.categoryButton.isSelected = false
        }

        cell.setup(category: category, delegate: delegate, categoryButtonDelegate: self)

        return cell
    }
}

extension ChecklistHeaderView: CategoryButtonDelegate {
    func didtapCategory(_ sender: UIButton) {
        let category = categories[sender.tag]
        selectCategory = category

        self.collectionView.reloadData()
    }
}

private extension ChecklistHeaderView {
    func setupLayout() {
        [
            collectionView,
            settingButton
        ].forEach { addSubview($0) }

        collectionView.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().inset(40.0)
        }

        settingButton.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
        }

        collectionView.reloadData()
    }
}
