//
//  BlocklistSelectionResponder.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 7/16/24.
//

import Foundation
import RealmSwift

protocol BlocklistSelectionResponder: AnyObject {
    func didSelectBlocklists(selectedBlocklists: [ObjectId])
}
