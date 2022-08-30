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
    func tappedCheckButton(cell: SelectBagsViewCell, index: Int)
}

final class SelectBagsViewCell: UICollectionViewCell {
    static let identifier = "SelectBagsViewCell"

    private weak var delegate: SelectBagsViewCellDelegate?
    private var checklist: Checklist!

    var isEditing: Bool = false {
        didSet {
            checkBox.isHidden = !isEditing
            bagButton.isEnabled = !isEditing
        }
    }

    lazy var bagButton: UIButton = {
        let button = UIButton()

        button.setImage(UIImage(systemName: "suitcase"), for: .normal)
        button.setImage(UIImage(systemName: "suitcase.fill"), for: .selected)

        button.addTarget(self, action: #selector(didTapBagButton), for: .touchUpInside)

        return button
    }()

    @objc func didTapBagButton() {
        delegate?.tappedBagButton(cell: self)
    }

    lazy var checkBox: UIButton = {
        let button = UIButton()

        button.setImage(UIImage(systemName: "circle"), for: .normal)
        button.setImage(UIImage(systemName: "checkmark.circle"), for: .selected)

        button.addTarget(self, action: #selector(didTapCheckbox), for: .touchUpInside)

        return button
    }()

    @objc func didTapCheckbox(_ sender: UIButton) {
        delegate?.tappedCheckButton(cell: self, index: sender.tag)
    }

    private lazy var bagName: UILabel = {
        let label = UILabel()

        label.font = .systemFont(ofSize: 16.0, weight: .semibold)
        label.textColor = .label

        return label
    }()

    func setup(
        bag: String,
        delegate: SelectBagsViewCellDelegate?,
        checklist: Checklist
    ) {
        self.delegate = delegate
        self.checklist = checklist

        checkBox.isHidden = true

        bagName.text = bag

        [
            bagButton,
            bagName,
            checkBox
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

        checkBox.snp.makeConstraints {
            $0.bottom.trailing.equalTo(bagButton)
            $0.width.height.equalTo(40.0)
        }
    }
}
