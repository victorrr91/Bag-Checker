//
//  ChecklistHeaderView.swift
//  Camming
//
//  Created by Victor Lee on 2022/08/22.
//

import UIKit
import SnapKit

final class ChecklistHeaderView: UICollectionReusableView {
    static let identifier = "ChecklistHeaderView"

    private var categories: [String] = []

    private weak var delegate: ChecklistHeaderViewCellDelegate?

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        collectionView.register(
            ChecklistHeaderViewCell.self,
            forCellWithReuseIdentifier: ChecklistHeaderViewCell.identifier
        )

        collectionView.dataSource = self
        collectionView.delegate = self

        return collectionView
    }()

    lazy var settingButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "gearshape.fill"), for: .normal)

        return button
    }()

    func setup(categories: [String], delegate: ChecklistHeaderViewCellDelegate?) {
        self.categories = categories
        self.delegate = delegate

        addSubview(collectionView)
        addSubview(settingButton)

        collectionView.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.trailing.equalTo(settingButton.snp.leading).inset(8.0)
        }

        settingButton.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.width.height.equalTo(40.0)
            $0.centerY.equalToSuperview()
        }
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
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ChecklistHeaderViewCell.identifier,
            for: indexPath
        ) as? ChecklistHeaderViewCell
        else { return UICollectionViewCell() }

        let category = categories[indexPath.item]
        
        cell.setup(category, delegate: delegate)

        return cell
    }
}

extension ChecklistHeaderView: UICollectionViewDelegate {
}
