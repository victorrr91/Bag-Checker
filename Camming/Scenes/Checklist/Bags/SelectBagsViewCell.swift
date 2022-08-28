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
}

final class SelectBagsViewCell: UICollectionViewCell {
    static let identifier = "SelectBagsViewCell"

    private weak var delegate: SelectBagsViewCellDelegate?

    private var checklist: Checklist!

    lazy var bagButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "suitcase"), for: .normal)
        button.setImage(UIImage(systemName: "suitcase.fill"), for: .selected)

        button.addTarget(self, action: #selector(didTapBagButton), for: .touchUpInside)

        return button
    }()

    @objc func didTapBagButton(_ sender: UIButton) {
        delegate?.tappedBagButton(cell: self)
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

        bagName.text = bag

        [bagButton, bagName].forEach { addSubview($0) }

        bagButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.width.equalTo(120.0)
        }

        bagName.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(bagButton.snp.bottom).offset(-8.0)
        }
    }
}
