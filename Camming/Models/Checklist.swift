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
}

enum CheckState: String, Codable {
    case toBuy
    case toPack
    case ready

    var color: UIColor {
        switch self {
        case .toBuy: return UIColor.red
        case .toPack: return UIColor.orange
        case .ready: return UIColor.green
        }
    }
}
