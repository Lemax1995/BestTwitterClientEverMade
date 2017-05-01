//
//  ProfileDescriptionLeftPageViewController.swift
//  Twitter
//
//  Created by Alexander Svetlichny & Grigory Setezhev in 2017
//  Copyright © 2017 CS333. All rights reserved.
//

import UIKit

final class ProfileDescriptionLeftPageViewController: UIViewController {

    // MARK: - Properties

    // MARK: Private Properties
    fileprivate var user: User! {
        didSet {
            configureViewController()
        }
    }

    // MARK: - IBOutlets
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var screennameLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!

    @IBOutlet var followingCountLabel: UILabel!
    @IBOutlet var followersCountLabel: UILabel!

    @IBOutlet var imageLockIcon: UIImageView!
    @IBOutlet var imageCogIcon: UIImageView!
    @IBOutlet var imageProfileOptions: UIImageView!

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: AppInfo.notifications.ProfileConfigureSubviews), object: nil, queue: OperationQueue.main) { _ in
            self.grabLoadedUser()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        grabLoadedUser()
    }

    fileprivate func configureViewController() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: AppInfo.notifications.ProfileConfigureRightSubviews), object: nil)

        let name = user.name
        let screenname = user.screenname
        let protected = user.protected
        let location = user.locationString
        let followingCount = user.followingCount
        let followersCount = user.followersCount

        imageLockIcon.isHidden = protected == nil

        nameLabel.text = String(name!)

        screennameLabel.text = "@" + String(screenname!)
        locationLabel.text = String(location!)

        followersCountLabel.text = Double(followersCount!).abbreviation
        followingCountLabel.text = Double(followingCount!).abbreviation

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(profileCogMenu))
        imageCogIcon.isUserInteractionEnabled = true
        imageCogIcon.addGestureRecognizer(tapGestureRecognizer)

        [imageProfileOptions, imageCogIcon].forEach { $0.isHidden = (user.screenname != User.currentUser?.screenname) }
    }

    // MARK: - Private Methods
    fileprivate func grabLoadedUser() {
        if User.bufferUser != nil {
            user = User.bufferUser
        }
    }

    // MARK: - Internal Methods
    func profileCogMenu() {
        guard user == User.currentUser else {
            return
        }

        let sheet = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )

        sheet.addAction(
            UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        )

        sheet.addAction(
            UIAlertAction(title: "Sign Out", style: .destructive) { _ in
                TwitterClient.sharedInstance?.logout()
            }
        )

        present(sheet, animated: true, completion: nil)
    }

}
