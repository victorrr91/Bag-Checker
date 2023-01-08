//
//  TabBarItem.swift
//  Camming
//
//  Created by Victor Lee on 2022/08/20.
//

import UIKit

enum TabBarItem: CaseIterable {
    case checklist

    var icon: (default: UIImage?, selected: UIImage?) {
        switch self {
        case .checklist: return (UIImage(systemName: "checklist"), UIImage(systemName: "checklist.fill"))
        }
    }

    var viewController: UIViewController {
        switch self {
        case .checklist: return UINavigationController(rootViewController: ChecklistViewController())
        }
    }
}
