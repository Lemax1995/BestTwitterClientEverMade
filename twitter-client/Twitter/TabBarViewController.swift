//
//  TabBarViewController.swift
//  Twitter
//
//  Created by Alexander Svertlichny and Grigory Setezhev.
//  Copyright © 2017 MMCS SFEDU. All rights reserved.
//

import UIKit

final class TabBarViewController: UITabBarController {

    // MARK: - Lifecycle Methods
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: AppInfo.notifications.UserDidLogout), object: nil, queue: OperationQueue.main) { _ in
            self.dismiss(animated: true, completion: nil)
        }

        AppInfo.tabBarController = self
    }

}
