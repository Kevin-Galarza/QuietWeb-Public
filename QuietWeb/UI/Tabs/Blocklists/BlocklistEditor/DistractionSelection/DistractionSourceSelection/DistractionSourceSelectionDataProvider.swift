//
//  DistractionSourceSelectionProvider.swift
//  QuietWeb
//
//  Created by Kevin Galarza on 8/27/24.
//

import Foundation

protocol DistractionSourceSelectionDataProvider: AnyObject {
    var selectedDistractionSourceIds: Set<String> { get set }
}
