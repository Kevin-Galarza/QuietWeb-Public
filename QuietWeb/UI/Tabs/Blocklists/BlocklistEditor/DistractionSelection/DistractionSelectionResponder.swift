//
//  WebsiteSelectionResponder.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 7/12/24.
//

import Foundation

protocol DistractionSelectionResponder: AnyObject {
    func didSelectDistractions(selectedUserDistractions: Set<String>, selectedDistractionGroups: Set<DistractionGroup>, selectedDistractionSourceIds: Set<String>)
    func didUpdateUserDistraction(oldWebsite: String, newWebsite: String)
    func didDeleteUserDistraction(website: String)
}
