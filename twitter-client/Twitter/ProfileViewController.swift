//
//  ProfileViewController.swift
//  Twitter
//
//  Created by Tejen Hasmukh Patel on 2/28/16.
//  Copyright © 2016 Tejen. All rights reserved.
//

import UIKit

final class ProfileViewController: TweetTableViewController {

    // MARK: - Properties

    // MARK: Public Properties
    var user: User!
    var userScreenname: NSString?

    // MARK: Private Properties
    fileprivate var pagedView: ProfileDescriptionPageViewController?

    // MARK: - IBOutlets
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var profileImageSuperview: UIView!

    @IBOutlet var shadowEffectView: UIView!
    @IBOutlet var tableViewOutlet: UITableView! {
        didSet {
            tableView = tableViewOutlet
        }
    }

    @IBOutlet var closeModalButton: UIButton!

    @IBOutlet var profileDescriptionContainer: UIView!

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: AppInfo.notifications.ProfileConfigureView), object: nil, queue: OperationQueue.main) { _ in
            self.user = User.bufferUser
            self.populateSubviews()
        }

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = shadowEffectView.bounds
        let topColor = UIColor(white: 0, alpha: 0.3).cgColor as CGColor
        let bottomColor = UIColor(white: 0, alpha: 0.0).cgColor as CGColor
        gradientLayer.colors = [topColor, bottomColor]
        gradientLayer.locations = [0.0, 1.0]
        shadowEffectView.layer.addSublayer(gradientLayer)

        // Set up Table
        tableView.delegate = self
        tableView.dataSource = self

        configureViewController()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        lastTweetId = nil
        User.bufferUser = nil

        if userScreenname == nil {
            user = User.currentUser!
            populateSubviews()
        } else {
            // populate User by screenname via API
            TwitterClient.sharedInstance?.getUserByScreenname(screenname: userScreenname!, success: { user in
                User.bufferUser = user
                NotificationCenter.default.post(name: Notification.Name(rawValue: AppInfo.notifications.ProfileConfigureView), object: nil)
            })
        }
    }

    fileprivate func populateSubviews() {
        User.bufferUser = user // ensure it's there, for the paged views.
        NotificationCenter.default.post(name: Notification.Name(rawValue: AppInfo.notifications.ProfileConfigureSubviews), object: nil)

        reloadData()

        let profileImageUrl = user.profileUrl
        let backgroundImageUrl = user.backgroundImageURL

        profileImageView.setImageWith(profileImageUrl! as URL)
        if let backgroundImageUrl = backgroundImageUrl {
            backgroundImageView.setImageWith(URL(string: backgroundImageUrl)!)
            backgroundImageView.contentMode = user.hasBannerImage ? .redraw : .scaleAspectFill
        }
        profileImageView.clipsToBounds = true
        [profileImageView, profileImageSuperview].forEach { $0.layer.cornerRadius = 5 }

        if user.screenname != User.currentUser?.screenname {
            let tapGestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(closeProfileModal))
            closeModalButton.isUserInteractionEnabled = true
            closeModalButton.addGestureRecognizer(tapGestureRecognizer2)
            closeModalButton.isHidden = false
        } else {
            closeModalButton.isHidden = true
        }
    }

    // MARK: - Internal Methods
    func closeProfileModal() {
        dismiss(animated: true, completion: nil)
    }

    override func reloadData(_ append: Bool = false) {
        guard user != nil else {
            return
        }

        TwitterClient.sharedInstance?.user_timeline(user: user, maxId: lastTweetId, success: reloadCompletion(append), failure: { error in
            print(error.localizedDescription)
        })
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender) // defined in parent class

        guard segue.identifier == "toDetails" else {
            return // no preprocessing needed
        }

        (segue.destination as! DetailsViewController).closeNavBarOnDisappear = true
    }

}
