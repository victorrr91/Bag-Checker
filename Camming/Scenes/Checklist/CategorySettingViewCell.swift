//
//  CategorySettingViewCell.swift
//  Camming
//
//  Created by Victor Lee on 2022/08/27.
//

import Foundation
import UIKit
import SnapKit

final class CategorySettingViewCell: UITableViewCell {
    static let identifier = "CategorySettingViewCell"

    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16.0, weight: .medium)
        label.textColor = .label

        return label
    }()

    func setup(category: String) {
        selectionStyle = .none
        label.text = category

        addSubview(label)
        label.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
}
