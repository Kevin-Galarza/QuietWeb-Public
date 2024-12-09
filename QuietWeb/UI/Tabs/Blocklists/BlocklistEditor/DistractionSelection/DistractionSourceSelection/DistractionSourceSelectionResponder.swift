//
//  DistractionSourceSelectionResponder.swift
//  QuietWeb
//
//  Created by Kevin Galarza on 8/27/24.
//

import Foundation

protocol DistractionSourceSelectionResponder: AnyObject {
    func didSelectDistractionSources(group: DistractionGroup, selectedDistractionSourceIds: Set<String>, unselectedDistractionSourceIds: Set<String>)
}
