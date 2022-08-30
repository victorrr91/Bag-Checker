//
//  ChecklistHeaderViewCell.swift
//  Camming
//
//  Created by Victor Lee on 2022/08/22.
//

import UIKit
import SnapKit

protocol ChecklistHeaderViewCellDelegate: AnyObject {
    func didSelectCategory(_ selectedCategory: String)
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

//        button.backgroundColor = .darkGray

        button.setBackgroundColor(.darkGray, for: .normal)
        button.setBackgroundColor(.systemIndigo, for: .selected)
        button.clipsToBounds = true
        button.titleLabel?.adjustsFontForContentSizeCategory = true

//        button.contentEdgeInsets = UIEdgeInsets(top: 8.0, left: 20.0, bottom: 8.0, right: 20.0)
        button.layer.cornerRadius = 6.0
        button.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner]

        button.addTarget(self, action: #selector(didTapCategory), for: .touchUpInside)

        return button
    }()

    @objc func didTapCategory() {
        delegate?.didSelectCategory(categoryButton.titleLabel?.text ?? "")
        categoryButtonDelegate?.didtapCategory(categoryButton)
    }

    func setup(
        _ category: String,
        delegate: ChecklistHeaderViewCellDelegate?,
        categoryButtonDelegate: CategoryButtonDelegate?
    ) {
        categoryButton.setTitle(category, for: .normal)
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
}
