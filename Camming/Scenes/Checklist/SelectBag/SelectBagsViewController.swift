//
//  SelectBagsViewController.swift
//  Camming
//
//  Created by Victor Lee on 2022/08/27.
//

import Foundation
import UIKit
import RealmSwift

protocol SelectBagsViewControllerDelegate: AnyObject {
    func selectBag(modifiedChecklist: Checklist)
}

final class SelectBagsViewController: UIViewController {
    var realm: Realm!

    private weak var delegate: SelectBagsViewControllerDelegate?
    private var beforeSelect: SelectBagsViewCell?

    private var checklist: Checklist!
    private var bags: Results<Bag>

    private var isEditMode = false
    private var deleteSet: Set<Bag> = []

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

        button.isEnabled = false

        button.addTarget(self, action: #selector(didTapConfirmButton), for: .touchUpInside)

        return button
    }()

    private lazy var editButton: UIButton = {
        let button = UIButton()

        button.setImage(UIImage(systemName: "gearshape.fill"), for: .normal)
        button.addTarget(self, action: #selector(didTapEditButton), for: .touchUpInside)

        return button
    }()

    private lazy var addButton: UIButton = {
        let button = UIButton()

        button.setImage(UIImage(systemName: "plus"), for: .normal)

        button.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)

        return button
    }()

    private lazy var separator: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground

        return view
    }()

    init(
        delegate: SelectBagsViewControllerDelegate?,
        checklist: Checklist,
        realm: Realm
    ) {
        self.delegate = delegate
        self.checklist = checklist
        self.realm = realm
        self.bags = realm.objects(Bag.self)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setLayout()

        view.backgroundColor = .systemBackground
    }
}

extension SelectBagsViewController: SelectBagsViewCellDelegate {
    func tappedDeleteButton(cell: SelectBagsViewCell, index: Int) {
        let alertController = UIAlertController(
            title: "진짜 삭제하시겠습니까?",
            message: "해당 가방은 영구 삭제됩니다.",
            preferredStyle: .alert
        )

        let confirm = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            let bag = self?.bags[index]
            try? self?.realm.write {
                self?.realm.delete(bag!)
            }
            self?.isEditMode = false
            self?.confirmButton.isHidden = false

            self?.collectionView.reloadData()
        }

        let cancel = UIAlertAction(title: "Cancel", style: .cancel)

        alertController.addAction(confirm)
        alertController.addAction(cancel)

        present(alertController, animated: true)
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

        cell.deleteButton.isHidden = !isEditMode
        cell.bagButton.isEnabled = !isEditMode

        if deleteSet.contains(bag) {
            cell.deleteButton.isSelected = true
        } else {
            cell.deleteButton.isSelected = false
        }

        cell.bagButton.tag = indexPath.item
        cell.deleteButton.tag = indexPath.item

        cell.setup(bag: bag, delegate: self)

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
            separator
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

        separator.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(1.0)
        }
    }

    @objc func didTapEditButton() {
        isEditMode = !isEditMode
        confirmButton.isHidden = isEditMode
        addButton.isHidden = isEditMode

        collectionView.reloadData()
    }

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

            if !(self?.bags.filter({ $0.name == text }).isEmpty ?? false) {
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
                let bag = Bag(value: ["name": text])
                try? self?.realm.write({
                    self?.realm.add(bag)
                })

                self?.collectionView
                    .insertItems(at: [IndexPath(row: (self?.bags.count ?? 0) - 1, section: 0)])
            }
        }

        let cancel = UIAlertAction(title: "Cancel", style: .cancel)

        alertController.addAction(confirm)
        alertController.addAction(cancel)

        present(alertController, animated: true)
    }

    @objc func didTapConfirmButton() {
        guard let selectIndex = beforeSelect?.bagButton.tag else { return }
        let bag = bags[selectIndex]

        try? realm.write {
            checklist.bag = bag
            checklist.state = .ready
        }

        delegate?.selectBag(modifiedChecklist: checklist)
        navigationController?.popViewController(animated: true)
    }
}
