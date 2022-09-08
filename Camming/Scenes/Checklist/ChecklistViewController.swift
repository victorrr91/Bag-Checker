//
//  ChecklistViewController.swift
//  Camming
//
//  Created by Victor Lee on 2022/08/20.
//

import Floaty
import UIKit
import SnapKit
import SwipeCellKit
import RealmSwift

final class ChecklistViewController: UIViewController {
    var realm: Realm!

    private var categories = List<Category>()
    private var currentCategory: Category?
    private var checklists = List<Checklist>()

    private var selectIdx: Int?

    private var longPressGesture: UILongPressGestureRecognizer!

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.register(ChecklistViewCell.self, forCellWithReuseIdentifier: ChecklistViewCell.identifier)

        collectionView.register(
            ChecklistHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: ChecklistHeaderView.identifier
        )

        return collectionView
    }()

    private lazy var addChecklistButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus.circle"), for: .normal)

        button.addTarget(self, action: #selector(didTapAddChecklistButton), for: .touchUpInside)

        return button
    }()

    private lazy var floaty: Floaty = {
        let float = Floaty(size: 50.0)
        float.addItem("What's in my Bag?", icon: UIImage(systemName: "suitcase.fill")) { [weak self] _ in
            guard let self = self else { return }
            self.navigationController?.pushViewController(BagViewController(realm: self.realm), animated: true)
        }

        float.buttonImage = UIImage(systemName: "questionmark.circle.fill")?
            .withTintColor(.white, renderingMode: .alwaysOriginal)

        return float
    }()

    private lazy var separator: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground

        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        realm = try? Realm()

        if UserDefaults.standard.isFirstRun(of: self.description) {
            try? realm.write {
                realm.add(Categories(value: ["name": "start"]))
            }
        }

        categories = realm.objects(Categories.self).first!.categories
        currentCategory = categories.first
        checklists = currentCategory?.checklists ?? List<Checklist>()

        configure()
        setupLayout()

        view.backgroundColor = .systemBackground
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        collectionView.reloadData()
    }
}

extension ChecklistViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ChecklistViewCell.identifier,
            for: indexPath
        ) as? ChecklistViewCell
        else { return UICollectionViewCell() }

        let checklist = checklists[indexPath.item]

        if checklist.state == .ready, checklist.bag == nil {
            try? realm.write {
                checklist.state = .toBuy
            }
        }
        cell.stateButton.tag = indexPath.item
        cell.setup(checklist: checklist, delegate: self)

        cell.packButton.tag = indexPath.item
        cell.packButton.addTarget(self, action: #selector(didTapPackButton), for: .touchUpInside)

        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: ChecklistHeaderView.identifier,
            for: indexPath
        ) as? ChecklistHeaderView
        else { return UICollectionReusableView() }

        header.setup(
            categories: categories,
            delegate: self,
            currentCategory: currentCategory ?? Category(value: ["name": ""])
        )
        header.settingButton.addTarget(self, action: #selector(didTapCategorySettingButton), for: .touchUpInside)

        return header
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return checklists.count
    }

    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    func collectionView(
        _ collectionView: UICollectionView,
        moveItemAt sourceIndexPath: IndexPath,
        to destinationIndexPath: IndexPath
    ) {
        if sourceIndexPath.item < destinationIndexPath.item {
            let insertValue = checklists[sourceIndexPath.item]
            try? realm.write({
                checklists.insert(insertValue, at: destinationIndexPath.item + 1)
                checklists.remove(at: sourceIndexPath.item)
            })
        } else if sourceIndexPath.item > destinationIndexPath.item {
            let insertValue = checklists[sourceIndexPath.item]
            try? realm.write({
                checklists.insert(insertValue, at: destinationIndexPath.item)
                checklists.remove(at: sourceIndexPath.item + 1)
            })
        }
        try? realm.write({
            currentCategory?.setValue(checklists, forKey: "checklists")
        })
    }
}

extension ChecklistViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = collectionView.frame.width
        let height = 50.0

        return CGSize(width: width, height: height)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        let width = collectionView.frame.width
        let height = 70.0

        return CGSize(width: width, height: height)
    }
}

// Swipe를 이용한 삭제
extension ChecklistViewController: SwipeCollectionViewCellDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        editActionsForItemAt indexPath: IndexPath,
        for orientation: SwipeActionsOrientation
    ) -> [SwipeAction]? {
        switch orientation {
        case .right:
            let deleteAction = SwipeAction(style: .default, title: nil) { [weak self] _, indexPath in

                self?.checklists.remove(at: indexPath.row)
                collectionView.deleteItems(at: [indexPath])
            }
            deleteAction.image = UIImage(systemName: "trash")
            deleteAction.backgroundColor = .red
            return [deleteAction]
        default:
            return []
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        editActionsOptionsForItemAt indexPath: IndexPath,
        for orientation: SwipeActionsOrientation
    ) -> SwipeOptions {
        var options = SwipeOptions()

        options.expansionStyle = .destructive(automaticallyDelete: false)
        options.transitionStyle = .drag
        options.maximumButtonWidth = 40.0

        return options
    }
}

extension ChecklistViewController: ChecklistViewCellDelegate {
    func checklistStateChanged(
        state: CheckState,
        stateButton: UIButton,
        packButton: UIButton
    ) {
        if state == .ready {
            let alertController = UIAlertController(
                title: "경고",
                message: "정말 가방에서 꺼내시나요?",
                preferredStyle: .alert
            )

            let confirm = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                guard let self = self else { return }

                try? self.realm.write {
                    self.checklists[stateButton.tag].bag = nil
                    self.checklists[stateButton.tag].state = .toBuy
                }

                stateButton.setTitle(CheckState.toBuy.rawValue, for: .normal)
                stateButton.backgroundColor = CheckState.toBuy.color
                packButton.isHidden = true
                }

            let cancel = UIAlertAction(title: "Cancel", style: .cancel)

            alertController.addAction(confirm)
            alertController.addAction(cancel)

            present(alertController, animated: true)
        } else {
            try? realm.write({
                checklists[stateButton.tag].state = state
            })
        }
    }
}

extension ChecklistViewController: ChecklistHeaderViewCellDelegate {
    func didSelectCategory(_ sender: UIButton) {
        currentCategory = categories[sender.tag]
        checklists = currentCategory?.checklists ?? List<Checklist>()
        self.collectionView.reloadData()
    }
}

extension ChecklistViewController: CategorySettingViewControllerDelegate {
    func tappedConfirmButton() {
        categories = realm.objects(Categories.self).first!.categories
        currentCategory = categories.first
        checklists = currentCategory?.checklists ?? List<Checklist>()

        self.collectionView.reloadData()
    }
}

extension ChecklistViewController: SelectBagsViewControllerDelegate {
    func selectBag(modifiedChecklist: Checklist) {
        try? realm.write({
            checklists[selectIdx!] = modifiedChecklist
        })

        collectionView.reloadData()
    }
}

private extension ChecklistViewController {
    func setupLayout() {
        [collectionView, addChecklistButton, floaty, separator]
            .forEach { self.view.addSubview($0) }

        collectionView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16.0)
            $0.leading.trailing.equalToSuperview().inset(16.0)
            $0.bottom.equalTo(addChecklistButton.snp.top).offset(16.0)
        }

        addChecklistButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-1.0)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(100.0)
        }

        floaty.paddingY = 100.0

        separator.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.top.equalTo(addChecklistButton.snp.bottom)
        }
    }

    func configure() {
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongGesture))
        collectionView.addGestureRecognizer(longPressGesture)
    }

    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            guard let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView))
            else { break }
            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case .ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }

    @objc func didTapCategorySettingButton() {
        let viewController = CategorySettingViewController(delegate: self, realm: realm)
        navigationController?.pushViewController(viewController, animated: true)
    }

    @objc func didTapPackButton(_ sender: UIButton) {
        selectIdx = sender.tag
        let checklist = checklists[selectIdx!]
        let selectBagViewController = SelectBagsViewController(delegate: self, checklist: checklist, realm: realm)
        selectBagViewController.modalPresentationStyle = .popover
        navigationController?.pushViewController(selectBagViewController, animated: true)
    }

    @objc func didTapAddChecklistButton() {
        let alertController = UIAlertController(
            title: "체크리스트 추가하기",
            message: "어떤 항목을 추가하시나요?",
            preferredStyle: .alert
        )
        alertController.addTextField()

        print(self.currentCategory?.name)

        if self.currentCategory?.name == nil {
            let cautionAlert = UIAlertController(
                title: "카테고리를 먼저 생성해주세요!",
                message: "",
                preferredStyle: .alert
            )
            cautionAlert.addAction(UIAlertAction(title: "OK", style: .cancel))
            self.present(cautionAlert, animated: true)
            return
        }

        let confirm = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            guard let text = alertController.textFields?[0].text?
                .trimmingCharacters(in: .whitespaces)
            else { return }

            if text != "" {
                try? self?.realm.write {
                    let newChecklist = Checklist(value: ["product": text])
                    self?.currentCategory?.checklists.append(newChecklist)
                }
                self?.collectionView
                    .insertItems(at: [IndexPath(row: (self?.checklists.count ?? 0) - 1, section: 0)])
            }
        }

        let cancel = UIAlertAction(title: "Cancel", style: .cancel)

        alertController.addAction(confirm)
        alertController.addAction(cancel)

        present(alertController, animated: true)
    }
}
