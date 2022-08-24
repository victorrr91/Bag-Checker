//
//  ChecklistTableViewCell.swift
//  Camming
//
//  Created by Victor Lee on 2022/08/21.
//

import SnapKit
import UIKit

class ChecklistTableViewCell: UITableViewCell {
    static let identifier = "ChecklistViewCell"

    private lazy var lightImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "star")

        return imageView
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15.0, weight: .medium)
        label.textColor = .label

        return label
    }()

    private lazy var stateButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12.0, weight: .medium)
        button.layer.cornerRadius = 6.0

        return button
    }()

    private lazy var packButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "suitcase.fill"), for: .normal)
//        button.isHidden = true

        return button
    }()

    func setup(_ checklist: Checklist) {
        setupLayout()
        selectionStyle = .none
        accessoryType = .none

        nameLabel.text = checklist.name
        stateButton.setTitle(checklist.state.rawValue, for: .normal)
        stateButton.backgroundColor = checklist.state.color
    }
}

private extension ChecklistTableViewCell {
    func setupLayout() {
        [lightImageView, nameLabel, stateButton, packButton]
            .forEach { addSubview($0) }

        lightImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20.0)
            $0.centerY.equalToSuperview()
            $0.height.width.equalTo(12.0)
        }

        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(lightImageView.snp.trailing).offset(16.0)
            $0.trailing.equalTo(stateButton.snp.leading).offset(-8.0)
            $0.centerY.equalToSuperview()
        }

        packButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20.0)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(20.0)
        }

        stateButton.snp.makeConstraints {
            $0.trailing.equalTo(packButton.snp.leading).offset(-16.0)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(60.0)
        }
    }
}
