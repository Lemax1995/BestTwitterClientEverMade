//
//  DetailsViewController.swift
//  Twitter
//
//  Created by Alexander Svetlichny & Grigory Setezhev in 2017
//  Copyright © 2017 CS333. All rights reserved.
//

import UIKit

final class DetailsViewController: TweetTableViewController {

    // MARK: - Properties

    // MARK: Public Properties
    var tweet: Tweet?
    var closeNavBarOnDisappear = false

    // MARK: Private Properties
    fileprivate var rootTweetID: NSNumber?

    fileprivate var tweetChain = [Tweet]()
    fileprivate var chainIsPopulated = false {
        didSet {
            if tweetChain.count > 1 {
                self.title = "Conversation"
            } else {
                self.title = "Tweet"
            }
        }
    }

    fileprivate var tweetComposedReply: Tweet?

    fileprivate var lastIndexPath: IndexPath?

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
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 160.0

        rootTweetID = tweet!.TweetID

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: AppInfo.notifications.DetailsTweetChainReady), object: nil, queue: OperationQueue.main) { _ in
            while(self.tweet != nil) {
                self.tweetChain.insert(self.tweet!, at: 0)
                self.tweet = self.tweet!.precedingTweet
            }
            self.chainIsPopulated = true
            self.tableView.reloadData()
        }

        TwitterClient.sharedInstance?.populatePreviousTweets(tweet: tweet!, completion: { _ in
            NotificationCenter.default.post(name: Notification.Name(rawValue: AppInfo.notifications.DetailsTweetChainReady), object: nil)
        })
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if closeNavBarOnDisappear {
            self.navigationController?.isNavigationBarHidden = true
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.navigationController?.isNavigationBarHidden = false
        tableViewScrollToBottom(true)
    }

}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension DetailsViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chainIsPopulated ? tweetChain.count : 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellTweet = tweetChain[indexPath.row]

        var cellType = "TweetCompactCell"
        if cellTweet.TweetID == rootTweetID {
            cellType = "TweetExpandedCell"
            lastIndexPath = indexPath
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: cellType, for: indexPath) as! TweetCell
        cell.indexPath = indexPath
        cell.tweet = cellTweet
        cell.delegate = self
        return cell
    }

}
