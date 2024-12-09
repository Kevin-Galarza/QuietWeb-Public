//
//  ErrorMessagePresentation.swift
//  CirclePuzzle
//
//  Created by Kevin Galarza on 5/21/24.
//

import UIKit

extension UIViewController {

    func present(_ errorMessage: ErrorMessage) {
        let alert = UIAlertController(title: errorMessage.title, message: errorMessage.message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension ErrorMessage {

    static func makeUnknown() -> ErrorMessage {
        return ErrorMessage(title: "Unknown Issue", message: "Koober ran into an unexpected issue, please try again or contact us.")
    }
}
