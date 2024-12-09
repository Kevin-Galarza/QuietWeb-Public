//
//  SessionEditorPresentationMode.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 7/16/24.
//

import Foundation

enum SessionEditorPresentationMode: Equatable {
    case create
    case edit(session: Session)
    case view(session: Session)
}
