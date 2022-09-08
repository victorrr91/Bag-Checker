//
//  UserDefaults+.swift
//  Camming
//
//  Created by Victor Lee on 2022/08/22.
//

import Foundation

extension UserDefaults {
    enum Key: String {
        case isFirstRun
    }

    func isFirstRun(of viewController: String) -> Bool {
        if UserDefaults.standard.object(forKey: viewController) == nil {
            UserDefaults.standard.set("N", forKey: viewController)
            return true
        }
        return false
    }
}
