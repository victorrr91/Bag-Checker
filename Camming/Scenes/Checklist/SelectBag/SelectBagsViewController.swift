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
    private var beforeSelect: SelectBagsViewCell?

    private var checklist: Checklist!
    private var bags: [String] = []

    private var isEditMode = false
    private var deleteSet: Set<String> = []

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
        checklist.state = .ready

        delegate?.selectBag(modifiedChecklist: checklist)
        navigationController?.popViewController(animated: true)
    }

    private lazy var deleteButton: UIButton = {
        let button = UIButton()

        button.setTitle("삭제", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18.0, weight: .bold)
        button.titleLabel?.textColor = .white
        button.setBackgroundColor(.red, for: .normal)
        button.setBackgroundColor(.secondarySystemBackground, for: .disabled)
        button.layer.cornerRadius = 8.0

        button.addTarget(self, action: #selector(didTapDeleteButton), for: .touchUpInside)

        return button
    }()

    @objc func didTapDeleteButton() {
        let alertController = UIAlertController(
            title: "진짜 삭제하시겠습니까?",
            message: "해당 가방은 영구 삭제됩니다.",
            preferredStyle: .alert
        )

        let confirm = UIAlertAction(title: "OK", style: .default) { [weak self] _ in

            self?.deleteSet.forEach { bag in
                let index = self?.bags.firstIndex(of: bag) ?? 0
                self?.bags.remove(at: index)
            }
            UserDefaults.standard.bags = self?.bags ?? []

            self?.setEditing(false, animated: true)
            self?.confirmButton.isHidden = false
            self?.deleteButton.isHidden = true

            self?.collectionView.reloadData()
        }

        let cancel = UIAlertAction(title: "Cancel", style: .cancel)

        alertController.addAction(confirm)
        alertController.addAction(cancel)

        present(alertController, animated: true)
    }

    private lazy var editButton: UIButton = {
        let button = UIButton()

        button.setImage(UIImage(systemName: "trash.fill"), for: .normal)
        button.addTarget(self, action: #selector(didTapEditButton), for: .touchUpInside)

        return button
    }()

    @objc func didTapEditButton() {
        isEditMode = !isEditMode
        setEditing(isEditMode, animated: true)
        confirmButton.isHidden = isEditMode
        deleteButton.isHidden = !isEditMode
        addButton.isHidden = isEditMode
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        collectionView.indexPathsForVisibleItems.forEach { indexPath in
            guard let cell = collectionView.cellForItem(at: indexPath) as? SelectBagsViewCell else { return }
            cell.isEditing = editing
        }
    }

    private lazy var addButton: UIButton = {
        let button = UIButton()

        button.setImage(UIImage(systemName: "plus"), for: .normal)

        button.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)

        return button
    }()

    @objc func didTapAddButton() {
        let alertController = UIAlertController(
            title: "가방 추가하기",
            message: "어떤 가방을 추가하시나요?",
            preferredStyle: .alert
        )
        alertController.addTextField()

        let confirm = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            guard let text = alertController.textFields?[0].text?
                .trimmingCharacters(in: .whitespaces)
            else { return }

            let bags = self?.bags ?? []
            if bags.contains(text) {
                let cautionAlert = UIAlertController(
                    title: "같은 이름의 가방이 있습니다. 다른 이름으로 다시 시도해주세요.",
                    message: "",
                    preferredStyle: .alert
                )
                cautionAlert.addAction(UIAlertAction(title: "OK", style: .cancel))
                self?.present(cautionAlert, animated: true)
                return
            }

            if text != "" {
                self?.bags.append(text)
                UserDefaults.standard.bags = self?.bags ?? []
                self?.collectionView
                    .insertItems(at: [IndexPath(row: (self?.bags.count ?? 0) - 1, section: 0)])
            }
        }

        let cancel = UIAlertAction(title: "Cancel", style: .cancel)

        alertController.addAction(confirm)
        alertController.addAction(cancel)

        present(alertController, animated: true)
    }

    init(delegate: SelectBagsViewControllerDelegate?, checklist: Checklist) {
        super.init(nibName: nil, bundle: nil)

        self.delegate = delegate
        self.checklist = checklist
        self.bags = UserDefaults.standard.bags

        view.backgroundColor = .systemBackground
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        confirmButton.isEnabled = false
        deleteButton.isEnabled = false
        deleteButton.isHidden = true

        setLayout()
    }
}

extension SelectBagsViewController: SelectBagsViewCellDelegate {
    func tappedCheckButton(cell: SelectBagsViewCell, index: Int) {
        cell.checkBox.isSelected.toggle()
        if cell.checkBox.isSelected == true {
            deleteSet.insert(bags[index])
        } else {
            deleteSet.remove(bags[index])
        }

        if deleteSet.isEmpty {
            deleteButton.isEnabled = false
        } else {
            deleteButton.isEnabled = true
        }
    }

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
        cell.checkBox.tag = indexPath.item

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
        [
            collectionView,
            confirmButton,
            editButton,
            addButton,
            deleteButton
        ]
            .forEach { view.addSubview($0) }

        collectionView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(24.0)
            $0.bottom.equalTo(addButton.snp.top).offset(-16.0)
        }

        confirmButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(24.0)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(24.0)
            $0.height.equalTo(50.0)
        }

        editButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(8.0)
            $0.trailing.equalToSuperview()
            $0.width.height.equalTo(80.0)
        }

        addButton.snp.makeConstraints {
            $0.bottom.equalTo(confirmButton.snp.top).offset(-16.0)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(80.0)
        }

        deleteButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(24.0)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(24.0)
            $0.height.equalTo(50.0)
        }
    }
}
