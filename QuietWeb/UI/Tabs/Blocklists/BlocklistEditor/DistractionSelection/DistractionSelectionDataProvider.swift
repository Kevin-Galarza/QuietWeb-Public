//
//  WebsiteSelectionDataProvider.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 7/14/24.
//

import Foundation

protocol DistractionSelectionDataProvider: AnyObject {
    var selectedUserDistractions: Set<String> { get set }
    var selectedDistractionGroups: Set<DistractionGroup> { get set }
    var selectedDistractionSourceIds: Set<String> { get set }
}
