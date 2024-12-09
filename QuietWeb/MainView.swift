//
//  MainView.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 7/4/24.
//

import Foundation

enum MainView {

    case launching
    case onboarding
    case signedIn
}

extension MainView: Equatable {
  
    public static func ==(lhs: MainView, rhs: MainView) -> Bool {
        switch (lhs, rhs) {
        case (.launching, .launching):
            return true
        case (.onboarding, .onboarding):
            return true
        case (.signedIn, .signedIn):
            return true
        case (.launching, _),
         (.onboarding, _),
         (.signedIn, _):
            return false
        }
    }
}

