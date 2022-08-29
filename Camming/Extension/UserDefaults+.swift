//
//  UserDefaults+.swift
//  Camming
//
//  Created by Victor Lee on 2022/08/22.
//

import Foundation

extension UserDefaults {
    enum Key: String {
        case categories
        case checklists
        case bags
    }

    var categories: [String] {
        get {
            guard let data = UserDefaults.standard.data(forKey: Key.categories.rawValue) else { return [] }

            return ( try? PropertyListDecoder().decode([String].self, from: data) ) ?? []
        }

        set {
            UserDefaults.standard.setValue(
                try? PropertyListEncoder().encode(newValue),
                forKey: Key.categories.rawValue
            )
        }
    }

    func deleteCategory(name: String) {
        UserDefaults.standard.removeObject(forKey: name)
    }

    func getChecklists(_ currentCategory: String) -> [Checklist] {
        guard let data = UserDefaults.standard.data(forKey: currentCategory) else { return [] }

        return (try? PropertyListDecoder().decode([Checklist].self, from: data)) ?? []
    }

    func setChecklists(_ newValue: [Checklist], _ currentCategory: String) {
        UserDefaults.standard.setValue(
            try? PropertyListEncoder().encode(newValue),
            forKey: currentCategory
        )
    }

    var bags: [String] {
        get {
            guard let data = UserDefaults.standard.data(forKey: Key.bags.rawValue) else { return [] }

            return ( try? PropertyListDecoder().decode([String].self, from: data) ) ?? []
        }

        set {
            UserDefaults.standard.setValue(
                try? PropertyListEncoder().encode(newValue),
                forKey: Key.bags.rawValue
            )
        }
    }
}
