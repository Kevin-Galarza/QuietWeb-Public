//
//  UIButton.swift
//  QuietWeb
//
//  Created by Kevin Galarza on 7/25/24.
//

import UIKit

extension UIButton {
    func setEnabled(_ enabled: Bool, withAnimationDuration duration: TimeInterval = 0.3) {
        UIView.transition(with: self, duration: duration, options: .curveLinear, animations: {
            if enabled {
                self.backgroundColor = Color.primaryGreen
            } else {
                self.backgroundColor = Color.systemGray5
            }
            self.isEnabled = enabled
        }, completion: nil)
    }
}
