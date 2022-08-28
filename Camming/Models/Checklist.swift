//
//  Checklist.swift
//  Camming
//
//  Created by Victor Lee on 2022/08/22.
//

import Foundation
import UIKit

struct Checklist: Codable {
    var name: String
    var state: CheckState
    var bag: String?
}

enum CheckState: String, Codable {
    case toBuy
    case ready

    var color: UIColor {
        switch self {
        case .toBuy: return UIColor.red
        case .ready: return UIColor.init(red: 4/255, green: 163/255, blue: 103/255, alpha: 0.6)
        }
    }
}
