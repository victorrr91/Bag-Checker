//
//  ChecklistHeaderViewCell.swift
//  Camming
//
//  Created by Victor Lee on 2022/08/22.
//

import UIKit
import SnapKit

protocol ChecklistHeaderViewCellDelegate: AnyObject {
    func didSelectCategory(_ sender: UIButton)
}

protocol CategoryButtonDelegate: AnyObject {
    func didtapCategory(_ sender: UIButton)
}

final class ChecklistHeaderViewCell: UICollectionViewCell {
    static let identifier = "ChecklistHeaderViewCell"

    private weak var delegate: ChecklistHeaderViewCellDelegate?
    private weak var categoryButtonDelegate: CategoryButtonDelegate?

    lazy var categoryButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .systemFont(ofSize: 15.0, weight: .semibold)
        button.setTitleColor(UIColor.white, for: .normal)

        button.setBackgroundColor(.darkGray, for: .normal)
        button.setBackgroundColor(.systemIndigo, for: .selected)
        button.clipsToBounds = true
        button.titleLabel?.adjustsFontForContentSizeCategory = true

        button.layer.cornerRadius = 6.0
        button.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner]

        button.addTarget(self, action: #selector(didTapCategory), for: .touchUpInside)

        return button
    }()

    func setup(
        category: Category,
        delegate: ChecklistHeaderViewCellDelegate?,
        categoryButtonDelegate: CategoryButtonDelegate?
    ) {
        categoryButton.setTitle(category.name, for: .normal)
        self.delegate = delegate
        self.categoryButtonDelegate = categoryButtonDelegate

        setupLayout()
    }
}

private extension ChecklistHeaderViewCell {
    func setupLayout() {
        addSubview(categoryButton)

        categoryButton.snp.makeConstraints {
            $0.leading.trailing.top.bottom.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }

    @objc func didTapCategory(_ sender: UIButton) {
        delegate?.didSelectCategory(categoryButton)
        categoryButtonDelegate?.didtapCategory(categoryButton)
    }
}
