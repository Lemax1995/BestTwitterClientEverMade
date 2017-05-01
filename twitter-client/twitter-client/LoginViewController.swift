//
//  LoginViewController.swift
//  Twitter
//
//  Created by Alexander Svetlichny & Grigory Setezhev in 2017
//  Copyright © 2017 CS333. All rights reserved.
//


import UIKit
import BDBOAuth1Manager

final class LoginViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet var logoVerticalConstraint: NSLayoutConstraint!
    @IBOutlet var logoMovedToTopConstraint: NSLayoutConstraint!

    @IBOutlet var logoHeightOriginalConstraint: NSLayoutConstraint!
    @IBOutlet var logoHeightSmallerConstraint: NSLayoutConstraint!

    @IBOutlet var WelcomeLabel: UILabel!
    @IBOutlet var SubtitleLabel: UILabel!
    @IBOutlet var ButtonContainerView: UIView!

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        ButtonContainerView.layer.cornerRadius = 5

        [ButtonContainerView, WelcomeLabel, SubtitleLabel].forEach { $0.alpha = 0 }

        UIApplication.shared.statusBarStyle = .lightContent

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: AppInfo.notifications.ReturnToSplash), object: nil, queue: OperationQueue.main) { _ in
            self.dismiss(animated: true, completion: nil)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        logoVerticalConstraint.isActive = false
        logoMovedToTopConstraint.isActive = true

        logoHeightOriginalConstraint.isActive = false
        logoHeightSmallerConstraint.isActive = true

        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()

            [self.ButtonContainerView, self.WelcomeLabel, self.SubtitleLabel].forEach {
                $0?.alpha = 1
                $0?.frame = ($0?.frame.offsetBy(dx: 0, dy: -20))!
            }
        }) 
    }

    // MARK: - IBActions
    @IBAction func onLoginButton(sender: AnyObject) {
        TwitterClient.sharedInstance?.login(success: {
            print("Logged in")
            self.dismiss(animated: true, completion: nil)
        }, failure: { error in
            fatalError(error.localizedDescription)
        })
    }
}
