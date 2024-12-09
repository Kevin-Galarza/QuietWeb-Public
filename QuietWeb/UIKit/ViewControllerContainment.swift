//
//  ViewControllerContainment.swift
//  CirclePuzzle
//
//  Created by Kevin Galarza on 5/21/24.
//

import UIKit

extension UIViewController {

    // Present Modals
    func presentFullScreenModal(childViewController child: UIViewController, animated: Bool = true) {
        child.modalPresentationStyle = .fullScreen
        present(child, animated: animated)
    }

    func presentBottomSheetModal(childViewController child: UIViewController, animated: Bool = true) {
        child.modalPresentationStyle = .formSheet
        present(child, animated: animated)
    }

    // Add/Remove Child View Controllers
    func addFullScreen(childViewController child: UIViewController) {
        guard child.parent == nil else {
            return
        }

        addChild(child)
        view.addSubview(child.view)

        child.view.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            view.leadingAnchor.constraint(equalTo: child.view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: child.view.trailingAnchor),
            view.topAnchor.constraint(equalTo: child.view.topAnchor),
            view.bottomAnchor.constraint(equalTo: child.view.bottomAnchor)
        ]
        constraints.forEach { $0.isActive = true }
        view.addConstraints(constraints)

        child.didMove(toParent: self)
    }

    func remove(childViewController child: UIViewController?) {
        guard let child = child else {
            return
        }

        guard child.parent != nil else {
            return
        }

        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
    }
}
