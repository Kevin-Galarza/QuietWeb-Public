//
//  BlocklistsPresentationMode.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 7/11/24.
//

import RealmSwift

enum BlocklistsPresentationMode: Equatable {
    case view
    case select(selectedBlocklists: [ObjectId]?)
}
