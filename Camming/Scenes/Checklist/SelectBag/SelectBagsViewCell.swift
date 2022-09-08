//
//  SelectBagsViewCell.swift
//  Camming
//
//  Created by Victor Lee on 2022/08/27.
//

import Foundation
import UIKit

protocol SelectBagsViewCellDelegate: AnyObject {
    func tappedBagButton(cell: SelectBagsViewCell)
    func tappedDeleteButton(cell: SelectBagsViewCell, index: Int)
}

final class SelectBagsViewCell: UICollectionViewCell {
    static let identifier = "SelectBagsViewCell"

    private weak var delegate: SelectBagsViewCellDelegate?

    lazy var bagButton: UIButton = {
        let button = UIButton()

        button.setImage(UIImage(systemName: "suitcase"), for: .normal)
        button.setImage(UIImage(systemName: "suitcase.fill"), for: .selected)

        button.addTarget(self, action: #selector(didTapBagButton), for: .touchUpInside)

        return button
    }()

    lazy var deleteButton: UIButton = {
        let button = UIButton()

        button.setImage(UIImage(systemName: "trash.fill"), for: .normal)

        button.addTarget(self, action: #selector(didTapDeleteButton), for: .touchUpInside)

        return button
    }()

    private lazy var bagName: UILabel = {
        let label = UILabel()

        label.font = .systemFont(ofSize: 16.0, weight: .semibold)
        label.textColor = .label

        return label
    }()

    func setup(bag: Bag, delegate: SelectBagsViewCellDelegate?) {
        self.delegate = delegate
        bagName.text = bag.name

        setupLayout()
    }
}

private extension SelectBagsViewCell {
    func setupLayout() {
        [
            bagButton,
            bagName,
            deleteButton
        ]
            .forEach { addSubview($0) }

        bagButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.width.equalTo(120.0)
        }

        bagName.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(bagButton.snp.bottom).offset(-8.0)
        }

        deleteButton.snp.makeConstraints {
            $0.bottom.trailing.equalTo(bagButton)
            $0.width.height.equalTo(40.0)
        }
    }

    @objc func didTapBagButton() {
        delegate?.tappedBagButton(cell: self)
    }

    @objc func didTapDeleteButton(_ sender: UIButton) {
        delegate?.tappedDeleteButton(cell: self, index: sender.tag)
    }
}
