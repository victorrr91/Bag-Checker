//
//  TabBarController.swift
//  Camming
//
//  Created by Victor Lee on 2022/08/20.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let tabBarViewController: [UIViewController] = TabBarItem.allCases
            .map { tabBar in
                let viewController = tabBar.viewController
                viewController.tabBarItem = UITabBarItem(
                    title: "",
                    image: tabBar.icon.default,
                    selectedImage: tabBar.icon.selected
                )

                return viewController
            }

        viewControllers = tabBarViewController
    }
}
