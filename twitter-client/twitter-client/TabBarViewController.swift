//
//  TabBarViewController.swift
//  Twitter
//
//  Created by Alexander Svetlichny & Grigory Setezhev in 2017
//  Copyright © 2017 CS333. All rights reserved.
//

import UIKit

final class TabBarViewController: UITabBarController {

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: AppInfo.notifications.UserDidLogout), object: nil, queue: OperationQueue.main) { _ in
            self.dismiss(animated: true, completion: nil)
        }

        AppInfo.tabBarController = self
    }

}
