//
//  SessionEditorResponder.swift
//  QuietWeb
//
//  Created by Kevin Galarza on 7/22/24.
//

import Foundation

protocol SessionEditorResponder: AnyObject {
    func didCreateSession(_ session: Session)
    func didModifySession(_ session: Session)
}
