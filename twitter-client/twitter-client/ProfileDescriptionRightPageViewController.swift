//
//  ProfileDescriptionRightPageViewController.swift
//  Twitter
//
//  Created by Alexander Svetlichny & Grigory Setezhev in 2017
//  Copyright © 2017 CS333. All rights reserved.
//

import UIKit

final class ProfileDescriptionRightPageViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet var taglineLabel: UILabel!

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: AppInfo.notifications.ProfileConfigureRightSubviews), object: nil, queue: OperationQueue.main) { _ in
            self.grabLoadedUser()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        grabLoadedUser()
    }

    // MARK: - Private Methods
    fileprivate func grabLoadedUser() {
        if User.bufferUser != nil {
            taglineLabel.text = User.bufferUser?.tagline as? String
        }
    }

}
