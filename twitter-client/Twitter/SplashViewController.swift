//
//  SplashViewController.swift
//  Twitter
//
//  Created by Alexander Svertlichny and Grigory Setezhev.
//  Copyright © 2017 MMCS SFEDU. All rights reserved.
//

import UIKit

final class SplashViewController: UIViewController {

    // MARK: - Properties

    // MARK: Private Properties
    fileprivate var attemptingLogin = false

    // MARK: - IBOutlets
    @IBOutlet var LogoHeightOriginalConstraint: NSLayoutConstraint!
    @IBOutlet var LogoHeightLargeConstraint: NSLayoutConstraint!

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        TwitterClient.sharedInstance?.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard !attemptingLogin else {
            // user's returning from safari with oauth token...
            return
        }

        proceed()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        LogoHeightLargeConstraint.isActive = false
        LogoHeightOriginalConstraint.isActive = true
    }

    // MARK: - Private Methods
    fileprivate func goToLogin() {
        self.performSegue(withIdentifier: "toLogin", sender: self)
    }

    fileprivate func goToApp() {
        LogoHeightOriginalConstraint.isActive = false
        LogoHeightLargeConstraint.isActive = true
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        }) 

        self.performSegue(withIdentifier: "toTabbedView", sender: self)
    }

    fileprivate func proceed() {
        delay(0.5, closure: User.currentUser == nil ? goToLogin : goToApp)
    }

}

// MARK: - TwitterLoginLoungeDelegate
extension SplashViewController: TwitterLoginLoungeDelegate {

    func continueLogin() {
        attemptingLogin = false
        proceed()
    }

    func doNotContinueLogin() {
        attemptingLogin = true
    }

}
