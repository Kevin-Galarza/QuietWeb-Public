//
//  WebsiteGroupDataStore.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 7/5/24.
//

import Foundation

protocol DistractionGroupDataStore {
    func read(group: DistractionGroup) throws -> [DistractionSource]
}
