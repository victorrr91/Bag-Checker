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

final class ChecklistHeaderViewCell: UICollectionViewCell {
    static let identifier = "ChecklistHeaderViewCell"

    private weak var delegate: ChecklistHeaderViewCellDelegate?

    lazy var categoryButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .systemFont(ofSize: 14.0, weight: .semibold)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = .orange
        button.layer.cornerRadius = 6.0

        button.addTarget(self, action: #selector(didTapCategory), for: .touchUpInside)

        return button
    }()

    @objc func didTapCategory() {
        delegate?.didSelectCategory(categoryButton.titleLabel?.text ?? "")
    }

    func setup(_ category: String, delegate: ChecklistHeaderViewCellDelegate?) {
        categoryButton.setTitle(category, for: .normal)

        self.delegate = delegate

        setupLayout()
    }
}

private extension ChecklistHeaderViewCell {
    func setupLayout() {
        addSubview(categoryButton)

        categoryButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16.0)
            $0.height.equalTo(25.0)
            $0.width.equalTo(50.0)
            $0.centerY.equalToSuperview()
        }
    }
}
