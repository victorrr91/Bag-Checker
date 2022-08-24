//
//  ChecklistViewCell.swift
//  Camming
//
//  Created by Victor Lee on 2022/08/21.
//

import SnapKit
import UIKit

protocol ChecklistViewCellDelegate: AnyObject {
    func checklistStateChanged(state: CheckState, index: Int)
}

final class ChecklistViewCell: UICollectionViewCell {
    static let identifier = "ChecklistViewCell"

    private weak var delegate: ChecklistViewCellDelegate?

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

    lazy var stateButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12.0, weight: .medium)
        button.layer.cornerRadius = 6.0

        button.addTarget(self, action: #selector(didTapStateButton), for: .touchUpInside)

        return button
    }()

    private lazy var packButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "suitcase.fill"), for: .normal)

        return button
    }()

    private lazy var separator: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground

        return view
    }()

    @objc func didTapStateButton() {
        switch stateButton.titleLabel?.text {
        case CheckState.toBuy.rawValue:
            stateButton.setTitle(CheckState.toPack.rawValue, for: .normal)
            delegate?.checklistStateChanged(state: CheckState.toPack, index: stateButton.tag)
            stateButton.backgroundColor = CheckState.toPack.color
        case CheckState.toPack.rawValue:
            stateButton.setTitle(CheckState.ready.rawValue, for: .normal)
            delegate?.checklistStateChanged(state: CheckState.ready, index: stateButton.tag)
            stateButton.backgroundColor = CheckState.ready.color
            packButton.isHidden = false
        case CheckState.ready.rawValue:
            stateButton.setTitle(CheckState.toBuy.rawValue, for: .normal)
            delegate?.checklistStateChanged(state: CheckState.toBuy, index: stateButton.tag)
            stateButton.backgroundColor = CheckState.toBuy.color
            packButton.isHidden = true
        default:
            return
        }
    }

    func setup(checklist: Checklist, delegate: ChecklistViewCellDelegate?) {
        self.delegate = delegate

        setupLayout()

        nameLabel.text = checklist.name
        stateButton.setTitle(checklist.state.rawValue, for: .normal)
        stateButton.backgroundColor = checklist.state.color
        if stateButton.titleLabel?.text == CheckState.toBuy.rawValue || stateButton.titleLabel?.text == CheckState.toPack.rawValue {
            packButton.isHidden = true
        } else {
            packButton.isHidden = false
        }
    }
}

private extension ChecklistViewCell {
    func setupLayout() {
        [
            lightImageView,
            nameLabel,
            stateButton,
            packButton,
            separator
        ]
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

        separator.snp.makeConstraints {
            $0.top.equalTo(stateButton.snp.bottom).offset(12.0)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1.0)
        }
    }
}
