//
//  BagViewController.swift
//  Camming
//
//  Created by Victor Lee on 2022/08/29.
//

import Foundation
import UIKit

final class BagViewController: UIViewController {
    private var allChecklists: [Checklist] = []
    private var bags: [String] = []

    init(categories: [String]) {
        super.init(nibName: nil, bundle: nil)

        categories.forEach { category in
            let checklists = UserDefaults.standard.getChecklists(category)
            self.allChecklists.append(contentsOf: checklists)
        }

        bags = UserDefaults.standard.bags

        print(self.allChecklists)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .orange
    }
}
