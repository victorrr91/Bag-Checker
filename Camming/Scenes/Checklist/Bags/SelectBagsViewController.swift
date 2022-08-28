//
//  SelectBagsViewController.swift
//  Camming
//
//  Created by Victor Lee on 2022/08/27.
//

import Foundation
import UIKit
import XCTest

protocol SelectBagsViewControllerDelegate: AnyObject {
    func selectBag(modifiedChecklist: Checklist)
}

final class SelectBagsViewController: UIViewController {
    private weak var delegate: SelectBagsViewControllerDelegate?

    private var checklist: Checklist!

    private var beforeSelect: SelectBagsViewCell?

    private var bags: [String] = ["초록이", "코로나", "노르디스크", "아이스박스"]

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 24.0, left: 24.0, bottom: 24.0, right: 24.0)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.register(
            SelectBagsViewCell.self,
            forCellWithReuseIdentifier: SelectBagsViewCell.identifier
        )

        return collectionView
    }()

    private lazy var confirmButton: UIButton = {
        let button = UIButton()

        button.setTitle("담기", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18.0, weight: .bold)
        button.titleLabel?.textColor = .white
        button.setBackgroundColor(.systemIndigo, for: .normal)
        button.setBackgroundColor(.secondarySystemBackground, for: .disabled)
        button.layer.cornerRadius = 8.0

        button.addTarget(self, action: #selector(didTapConfirmButton), for: .touchUpInside)

        return button
    }()

    @objc func didTapConfirmButton() {
        guard let selectIndex = beforeSelect?.bagButton.tag else { return }
        let bag = bags[selectIndex]
        checklist.bag = bag

        delegate?.selectBag(modifiedChecklist: checklist)
        dismiss(animated: true)
    }

    init(delegate: SelectBagsViewControllerDelegate?, checklist: Checklist) {
        super.init(nibName: nil, bundle: nil)

        self.delegate = delegate
        self.checklist = checklist

//        bags = UserDefaults.standard.bags

        view.backgroundColor = .systemBackground
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        confirmButton.isEnabled = false

        setLayout()
    }
}

extension SelectBagsViewController: SelectBagsViewCellDelegate {
    func tappedBagButton(cell: SelectBagsViewCell) {
        confirmButton.isEnabled = true
        if beforeSelect != nil {
            beforeSelect?.bagButton.isSelected = false
        }
        cell.bagButton.isSelected = true
        beforeSelect = cell
    }
}

extension SelectBagsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bags.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SelectBagsViewCell.identifier,
            for: indexPath
        ) as? SelectBagsViewCell
        else { return UICollectionViewCell() }

        let bag = bags[indexPath.item]

        if checklist.bag == bag {
            beforeSelect = cell
            beforeSelect?.bagButton.isSelected = true
            confirmButton.isEnabled = true
        }

        cell.bagButton.tag = indexPath.item
        cell.setup(bag: bag, delegate: self, checklist: checklist)

        return cell
    }
}

extension SelectBagsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = 120.0
        let height = width

        return CGSize(width: width, height: height)
    }
}

private extension SelectBagsViewController {
    func setLayout() {
        [collectionView, confirmButton].forEach { view.addSubview($0) }

        collectionView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(24.0)
            $0.bottom.equalTo(confirmButton.snp.top).offset(-16.0)
        }

        confirmButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(24.0)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(24.0)
            $0.height.equalTo(50.0)
        }
    }
}
