//
//  HomeViewController.swift
//  Twitter
//
//  Created by Tejen Hasmukh Patel on 2/21/16.
//  Copyright © 2016 Tejen. All rights reserved.
//

import UIKit

final class HomeViewController: TweetTableViewController {

    // MARK: - IBOutlets
    @IBOutlet var tableViewOutlet: UITableView! {
        didSet {
            tableView = tableViewOutlet
        }
    }

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        UIApplication.shared.statusBarStyle = .default

        let logo = UIImage(named: "Icon-Twitter")
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        imageView.contentMode = .scaleAspectFit
        imageView.image = logo
        self.navigationItem.titleView = imageView

        // Set up Table
        tableView.delegate = self
        tableView.dataSource = self

        configureViewController()
    }

    // MARK: - Internal Methods
    override func reloadData(_ append: Bool = false) {
        TwitterClient.sharedInstance?.homeTimeline(maxId: lastTweetId, success: reloadCompletion(append), failure: { error in
            print(error?.localizedDescription)
        })
    }

    // MARK: - Navigation
      // prepareForSegue is defined in parent class (TweetTableViewController)

}
