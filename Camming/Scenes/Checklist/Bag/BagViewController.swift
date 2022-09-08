//
//  BagViewController.swift
//  Camming
//
//  Created by Victor Lee on 2022/08/29.
//

import Foundation
import UIKit
import RealmSwift

final class BagViewController: UIViewController {
    var realm: Realm!

    private var bags: Results<Bag>
    private var checklists: [Checklist] = []
    private var currentBag: Bag?

    private var beforeSelect: BagsViewCell?

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 24.0
        layout.itemSize = CGSize(width: 120, height: 80)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self

        collectionView.register(BagsViewCell.self, forCellWithReuseIdentifier: BagsViewCell.identifier)

        return collectionView
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()

        tableView.register(ChecklistsInBagViewCell.self, forCellReuseIdentifier: ChecklistsInBagViewCell.identifier)

        tableView.dataSource = self
        tableView.delegate = self

        return tableView
    }()

    private lazy var separator: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground

        return view
    }()

    init(realm: Realm) {
        self.bags = realm.objects(Bag.self)
        self.realm = realm

        super.init(nibName: nil, bundle: nil)

        self.currentBag = bags.first
        fetchChecklists(currentBag: currentBag ?? Bag(value: ["name": ""]))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        realm = try? Realm()

        setupLayout()

        view.backgroundColor = .systemBackground
    }

    func fetchChecklists(currentBag: Bag) {
        checklists = realm.objects(Checklist.self).filter { $0.bag?.name == currentBag.name }
    }
}

extension BagViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: BagsViewCell.identifier,
            for: indexPath
        ) as? BagsViewCell else { return UICollectionViewCell() }

        let bag = bags[indexPath.item]
        if bag.name == currentBag?.name {
            beforeSelect = cell
            beforeSelect?.bagButton.isSelected = true
        }

        cell.bagButton.tag = indexPath.item

        cell.setup(bag: bag, delegate: self)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bags.count
    }
}

extension BagViewController: BagsViewCellDelegate {
    func selectBag(cell: BagsViewCell) {
        if beforeSelect != nil {
            beforeSelect?.bagButton.isSelected = false
        }
        cell.bagButton.isSelected = true
        beforeSelect = cell
        currentBag = bags[cell.bagButton.tag]

        fetchChecklists(currentBag: currentBag ?? Bag(value: ["name": ""]))
        tableView.reloadData()
    }
}

extension BagViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ChecklistsInBagViewCell.identifier,
            for: indexPath
        ) as? ChecklistsInBagViewCell else { return UITableViewCell() }

        let checklist = checklists[indexPath.item]
        cell.setup(checklist: checklist)

        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return checklists.count
    }
}

extension BagViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
}

private extension BagViewController {
    func setupLayout() {
        [collectionView, tableView, separator]
            .forEach { view.addSubview($0) }

        collectionView.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(8.0)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.width.equalTo(view.bounds.width/4)
        }

        tableView.snp.makeConstraints {
            $0.leading.equalTo(collectionView.snp.trailing)
            $0.bottom.equalTo(collectionView)
            $0.top.trailing.equalToSuperview()
        }

        separator.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(1.0)
        }
    }
}
