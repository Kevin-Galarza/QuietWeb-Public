//
//  UIViewController+ErrorPresentation.swift
//  CirclePuzzle
//
//  Created by Kevin Galarza on 5/21/24.
//

import UIKit
import Combine

extension UIViewController {

    func present(errorMessage: ErrorMessage) {
        let errorAlertController = UIAlertController(title: errorMessage.title, message: errorMessage.message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        errorAlertController.addAction(okAction)
        present(errorAlertController, animated: true, completion: nil)
    }

    func present(errorMessage: ErrorMessage, withPresentationState errorPresentation: PassthroughSubject<ErrorPresentation?, Never>) {
        errorPresentation.send(.presenting)
        let errorAlertController = UIAlertController(title: errorMessage.title, message: errorMessage.message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            errorPresentation.send(.dismissed)
            errorPresentation.send(nil)
    }
        errorAlertController.addAction(okAction)
        present(errorAlertController, animated: true, completion: nil)
    }
}
