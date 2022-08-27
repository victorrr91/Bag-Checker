//
//  SelectBagsViewController.swift
//  Camming
//
//  Created by Victor Lee on 2022/08/27.
//

import Foundation
import UIKit

protocol SelectBagsViewControllerDelegate: AnyObject {
    func selectBag()
}

final class SelectBagsViewController: UIViewController {
    private weak var delegate: SelectBagsViewControllerDelegate?

    private var bags: [String] = []

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 24.0, left: 24.0, bottom: 24.0, right: 24.0)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self

        collectionView.register(
            SelectBagsViewCell.self,
            forCellWithReuseIdentifier: SelectBagsViewCell.identifier
        )

        return collectionView
    }()

    init(delegate: SelectBagsViewControllerDelegate?) {
        super.init(nibName: nil, bundle: nil)

        bags = UserDefaults.standard.bags

        view.backgroundColor = .cyan
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SelectBagsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bags.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SelectBagsViewCell.identifier,
            for: indexPath
        ) as? SelectBagsViewCell
        else { return UICollectionViewCell() }


        return cell
    }
}
