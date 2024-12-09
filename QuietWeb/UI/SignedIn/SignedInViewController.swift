//
//  SignedInViewController.swift
//  CirclePuzzle
//
//  Created by Kevin Galarza on 5/22/24.
//

import UIKit

class SignedInViewController: NiblessTabBarController {

    let sessionsViewController: UIViewController
    let blocklistsViewController: UIViewController
//    let webShieldViewController: UIViewController
    let settingsViewController: UIViewController
    
    // child view controller
    var contentBlockerStatusViewController: ContentBlockerStatusViewController?
    
    // factory
    let makeContentBlockerStatusViewController: () -> ContentBlockerStatusViewController
    
    init(sessionsViewController: UIViewController,
         blocklistsViewController: UIViewController,
         settingsViewController: UIViewController,
         contentBlockerStatusViewControllerFactory: @escaping () -> ContentBlockerStatusViewController) {
        self.sessionsViewController = sessionsViewController
        self.blocklistsViewController = blocklistsViewController
        self.settingsViewController = settingsViewController
        self.makeContentBlockerStatusViewController = contentBlockerStatusViewControllerFactory
        super.init()
        constructHierarchy()
        applyStyle()
        addObservers()
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(contentBlockerDisabled), name: .contentBlockerDidBecomeDisabled, object: nil)
    }
    
    @objc func contentBlockerDisabled() {
        DispatchQueue.main.async {
            self.presentContentBlockerStatusViewController()
        }
        print("present content blocker status vc")
    }
    
    private func constructHierarchy() {
        sessionsViewController.tabBarItem = UITabBarItem(title: "Sessions", image: UIImage(named: "sessions_tab_icon_normal"), tag: 0)
        blocklistsViewController.tabBarItem = UITabBarItem(title: "Blocklists", image: UIImage(named: "blocklists_tab_icon_normal"), tag: 1)
//        webShieldViewController.tabBarItem = UITabBarItem(title: "Web Shield", image: UIImage(named: "webshield_tab_icon_normal"), tag: 2)
        settingsViewController.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(named: "settings_tab_icon_normal"), tag: 3)

        self.viewControllers = [sessionsViewController, blocklistsViewController, settingsViewController]
    }

    private func applyStyle() {
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.tabBar.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.tabBar.insertSubview(blurEffectView, at: 0)
        self.tabBar.isTranslucent = true
        self.tabBar.tintColor = Color.primaryBlue

        let normalAttributes = [NSAttributedString.Key.foregroundColor: Color.systemBlackText]
        let selectedAttributes = [NSAttributedString.Key.foregroundColor: Color.primaryBlue]

        UITabBarItem.appearance().setTitleTextAttributes(normalAttributes, for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes(selectedAttributes, for: .selected)

        sessionsViewController.tabBarItem.selectedImage = UIImage(named: "sessions_tab_icon_selected")
        blocklistsViewController.tabBarItem.selectedImage = UIImage(named: "blocklists_tab_icon_selected")
//        webShieldViewController.tabBarItem.selectedImage = UIImage(named: "webshield_tab_icon_selected")
        settingsViewController.tabBarItem.selectedImage = UIImage(named: "settings_tab_icon_selected")
    }
    
    private func presentContentBlockerStatusViewController() {
        if let vc = contentBlockerStatusViewController {
            guard presentedViewController != vc else { return }
            contentBlockerStatusViewController = nil
        }
        let contentBlockerStatusViewControllerToPresent = makeContentBlockerStatusViewController()
        contentBlockerStatusViewControllerToPresent.modalPresentationStyle = .fullScreen
        contentBlockerStatusViewController = contentBlockerStatusViewControllerToPresent
        present(contentBlockerStatusViewControllerToPresent, animated: true)
    }
}
