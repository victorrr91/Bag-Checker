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

final class ChecklistViewController: UIViewController {
    private var currentCategory = ""

    private var categories: [String] = []
    private var checklists: [Checklist] = []

    private var selectIdx: Int?

    private var longPressGesture: UILongPressGestureRecognizer!

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16.0

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
        let floaty = Floaty(size: 50.0)
        floaty.addItem("What's in my bag", icon: UIImage(systemName: "suitcase.fill")!)

        floaty.buttonImage = UIImage(systemName: "questionmark.circle.fill")?
            .withTintColor(.white, renderingMode: .alwaysOriginal)

        return floaty
    }()

    private lazy var separator: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground

        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.currentCategory = UserDefaults.standard.categories.first ?? ""

        configure()
        setupLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.categories = UserDefaults.standard.categories
        self.checklists = UserDefaults.standard.getChecklists(currentCategory)
        collectionView.reloadSections(IndexSet(integer: 0))
    }

    override func viewWillDisappear(_ animated: Bool) {
        UserDefaults.standard.setChecklists(checklists, currentCategory)

        super.viewWillDisappear(animated)
    }

    @objc func didTapPackButton(_ sender: UIButton) {
        selectIdx = sender.tag
        let checklist = checklists[selectIdx!]
        let selectBagViewController = SelectBagsViewController(delegate: self, checklist: checklist)
        selectBagViewController.modalPresentationStyle = .popover

        present(selectBagViewController, animated: true)
    }
}

extension ChecklistViewController: SelectBagsViewControllerDelegate {
    func selectBag(modifiedChecklist: Checklist) {
        checklists[selectIdx!] = modifiedChecklist

        UserDefaults.standard.setChecklists(checklists, currentCategory)
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
        let checklist = checklists[indexPath.row]

        cell.stateButton.tag = indexPath.row
        cell.setup(checklist: checklist, delegate: self)

        cell.delegate = self

        cell.packButton.tag = indexPath.row
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

        header.setup(categories: categories, delegate: self)
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
            checklists.insert(insertValue, at: destinationIndexPath.item + 1)
            checklists.remove(at: sourceIndexPath.item)
        } else if sourceIndexPath.item > destinationIndexPath.item {
            let insertValue = checklists[sourceIndexPath.item]
            checklists.insert(insertValue, at: destinationIndexPath.item)
            checklists.remove(at: sourceIndexPath.item + 1)
        }
        UserDefaults.standard.setChecklists(checklists, currentCategory)
    }
}

extension ChecklistViewController: UICollectionViewDelegate {}

extension ChecklistViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = collectionView.frame.width
        let height = 36.0

        return CGSize(width: width, height: height)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        let width = collectionView.frame.width
        let height = 60.0

        return CGSize(width: width, height: height)
    }
}

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
    func checklistStateChanged(state: CheckState, index: Int) {
        checklists[index].state = state
    }
}

extension ChecklistViewController: ChecklistHeaderViewCellDelegate {
    func didSelectCategory(_ selectedCategory: String) {
        UserDefaults.standard.setChecklists(checklists, currentCategory)
        self.currentCategory = selectedCategory
        self.checklists = UserDefaults.standard.getChecklists(currentCategory)
        self.collectionView.reloadData()
    }
}

extension ChecklistViewController: CategorySettingViewControllerDelegate {
    func tappedConfirmButton(categories: [String]) {
        self.categories = categories
        self.currentCategory = categories.first ?? ""
        self.checklists = UserDefaults.standard.getChecklists(currentCategory)

        if let flowLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.invalidateLayout()
        }

        UserDefaults.standard.categories = categories
    }
}

private extension ChecklistViewController {
    func setupLayout() {
        [collectionView, addChecklistButton, floaty, separator]
            .forEach { self.view.addSubview($0) }

        collectionView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(addChecklistButton.snp.top).offset(16.0)
        }

        addChecklistButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-1.0)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(50.0)
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
        let viewController = CategorySettingViewController(categories: categories, delegate: self)
        navigationController?.pushViewController(viewController, animated: true)
    }

    @objc func didTapAddChecklistButton() {
        if checklists.last?.name != "" {
            let alertController = UIAlertController(
                title: "체크리스트 추가하기",
                message: "어떤 항목을 추가하시나요?",
                preferredStyle: .alert
            )
            alertController.addTextField()

            let confirm = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                guard let text = alertController.textFields?[0].text else { return }

                if text != "" {
                    let newChecklist = Checklist(name: text, state: .toBuy)
                    self?.checklists.append(newChecklist)
                    self?.collectionView.insertItems(at: [IndexPath(row: (self?.checklists.count ?? 0) - 1, section: 0)])

                    UserDefaults.standard.setChecklists(self?.checklists ?? [], self?.currentCategory ?? "")
                }
            }

            let cancel = UIAlertAction(title: "Cancel", style: .cancel)

            alertController.addAction(confirm)
            alertController.addAction(cancel)

            present(alertController, animated: true)
        }
    }
}
