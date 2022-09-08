//
//  ChecklistsInBagViewCell.swift
//  Camming
//
//  Created by Victor Lee on 2022/08/30.
//

import Foundation
import UIKit

final class ChecklistsInBagViewCell: UITableViewCell {
    static let identifier = "ChecklistsInBagViewCell"

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16.0, weight: .medium)
        label.textColor = .label

        return label
    }()

    func setup(checklist: Checklist) {
        nameLabel.text = checklist.product

        addSubview(nameLabel)

        nameLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(40.0)
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
}
