//
//  BlocklistEditorPresentationMode.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 7/12/24.
//

import Foundation

enum BlocklistEditorPresentationMode: Equatable {
    case create
    case edit(blocklist: Blocklist)
}
