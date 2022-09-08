//
//  BagsViewCell.swift
//  Camming
//
//  Created by Victor Lee on 2022/08/30.
//

import Foundation
import UIKit

protocol BagsViewCellDelegate: AnyObject {
    func selectBag(cell: BagsViewCell)
}

final class BagsViewCell: UICollectionViewCell {
    static let identifier = "BagsViewCell"

    private weak var delegate: BagsViewCellDelegate?

    var nameLabel: UILabel = {
        let label = UILabel()

        label.font = .systemFont(ofSize: 16.0, weight: .semibold)
        label.textColor = .label

        return label
    }()

    lazy var bagButton: UIButton = {
        let button = UIButton()

        button.setImage(UIImage(systemName: "suitcase"), for: .normal)
        button.setImage(UIImage(systemName: "suitcase.fill"), for: .selected)

        button.addTarget(self, action: #selector(didTapBagButton), for: .touchUpInside)

        return button
    }()

    @objc func didTapBagButton() {
        delegate?.selectBag(cell: self)
    }

    func setup(bag: Bag, delegate: BagsViewCellDelegate?) {
        self.delegate = delegate

        nameLabel.text = bag.name

        [bagButton, nameLabel].forEach { addSubview($0) }

        bagButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        nameLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(bagButton.snp.bottom).offset(-20.0)
        }
    }
}
