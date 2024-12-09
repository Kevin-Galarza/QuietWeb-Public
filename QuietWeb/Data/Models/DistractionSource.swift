//
//  Source.swift
//  QuietWeb
//
//  Created by Kevin Galarza on 8/24/24.
//

import Foundation

struct DistractionSource: Codable {
    let id: String
    let group: DistractionGroup
    let name: String
    let hosts: [String]
}
