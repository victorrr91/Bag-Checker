//
//  Checklist.swift
//  Camming
//
//  Created by Victor Lee on 2022/08/22.
//

import Foundation
import UIKit
import RealmSwift

enum CheckState: String, PersistableEnum {
    case toBuy
    case toPack
    case ready

    var color: UIColor {
        switch self {
        case .toBuy: return .red
        case .toPack: return .orange
        case .ready: return .init(red: 4/255, green: 163/255, blue: 103/255, alpha: 0.6)
        }
    }
}

class Categories: Object {
    @Persisted var name = ""
    @Persisted var categories = List<Category>()

    convenience init(name: String) {
        self.init()
        self.name = name
    }
}

class Category: Object {
    @Persisted var name = ""
    @Persisted var checklists = List<Checklist>()

    convenience init(name: String) {
        self.init()
        self.name = name
    }
}

class Checklist: Object {
    @Persisted var product = ""
    @Persisted var state: CheckState = .toBuy
    @Persisted var bag: Bag? = nil

    convenience init(name: String) {
        self.init()
        self.product = product
    }
}

class Bag: Object {
    @Persisted var name = ""

    convenience init(name: String) {
        self.init()
        self.name = name
    }
}
