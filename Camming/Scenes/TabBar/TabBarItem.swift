//
//  TabBarItem.swift
//  Camming
//
//  Created by Victor Lee on 2022/08/20.
//

import UIKit

enum TabBarItem: CaseIterable {
    case checklist
    case calendar
    case search
    case etc

    var icon: (default: UIImage?, selected: UIImage?) {
        switch self {
        case .checklist: return (UIImage(systemName: "checklist"), UIImage(systemName: "checklist.fill"))
        case .calendar: return (UIImage(systemName: "calendar"), UIImage(systemName: "calendar.fill"))
        case .search: return (UIImage(systemName: "magnifyingglass"), UIImage(systemName: "magnifyingglass.fill"))
        case .etc: return (UIImage(systemName: "ellipsis"), UIImage(systemName: "ellipsis.fill"))
        }
    }

    var viewController: UIViewController {
        switch self {
        case .checklist: return UINavigationController(rootViewController: ChecklistViewController())
        case .calendar: return UIViewController()
        case .search: return UIViewController()
        case .etc: return UIViewController()
        }
    }
}
