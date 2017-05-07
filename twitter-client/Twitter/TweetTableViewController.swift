//
//  TweetTableViewController.swift
//  Twitter
//
//  Created by Alexander Svertlichny and Grigory Setezhev.
//  Copyright © 2017 MMCS SFEDU. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class TweetTableViewController: UIViewController {

    // MARK: - Properties

    // MARK: Private Properties
    fileprivate var refreshControl: UIRefreshControl!
    fileprivate var loadingMoreView: InfiniteScrollActivityView?
    fileprivate var isMoreDataLoading = false
    fileprivate var reloadedIndexPaths = [Int]()
    fileprivate var tweets: [Tweet]? {
        didSet {
            if tweets?.count > 0 {
                lastTweetId = tweets![tweets!.endIndex - 1].TweetID as? Int
            }
        }
    }

    // MARK: Public Properties
    var tableView: UITableView!
    var lastTweetId: Int?

    // MARK: - Lifecycle Methods
    func configureViewController() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 160.0

        reloadData()

        // Set up Pull To Refresh loading indicator
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(pullRefresh), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)

        // Set up Infinite Scroll loading indicator
        let frame = CGRect(
            x: 0,
            y: tableView.contentSize.height,
            width: tableView.bounds.size.width,
            height: InfiniteScrollActivityView.defaultHeight
        )
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        var insets = tableView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        tableView.contentInset = insets
    }

    // MARK: - Internal Methods
    func reloadCompletion(_ append: Bool = false) -> (([Tweet]) -> ()) {
        var completion = { (tweets: [Tweet]) -> () in
            self.tweets = tweets
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }

        if append {
            completion = { (tweets: [Tweet]) -> () in
                var cleaned = tweets
                if tweets.count > 0 {
                    cleaned.remove(at: 0) // api param "max_id" is inclusive
                }
                if cleaned.count > 0 {
                    self.tweets?.append(contentsOf: cleaned)
                    self.isMoreDataLoading = false
                    self.loadingMoreView!.stopAnimating()
                    self.tableView.reloadData()
                }
            }
        } else {
            lastTweetId = nil
        }

        return completion
    }

    func pullRefresh() {
        lastTweetId = nil
        reloadData()
    }

    func reloadData(_ append: Bool = false) {
        // must be overidden by subclasses (ie. HomeViewController, ProfileViewController, etc...)
        fatalError("reloadData() called without being overridden by specific view controller subclass.")
    }

    func tableViewScrollToBottom(_ animated: Bool) {
        delay(0.1) {
            let numberOfSections = self.tableView.numberOfSections
            let numberOfRows = self.tableView.numberOfRows(inSection: numberOfSections-1)

            if numberOfRows > 1 {
                let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
                self.tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: animated)
                self.tableView.cellForRow(at: indexPath)?.layer.backgroundColor = UIColor(red: 1.0, green: 241/255.0, blue: 156/255.0, alpha: 1).cgColor
                UIView.animate(withDuration: 2, animations: { () -> Void in
                    self.tableView.cellForRow(at: indexPath)?.layer.backgroundColor = UIColor.clear.cgColor
                })
            }
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "toDetails" else {
            return // no preprocessing needed
        }

        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem

        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)
        let tweet = tweets![indexPath!.row]
        let detailViewController = segue.destination as! DetailsViewController
        detailViewController.tweet = tweet
    }

}

// MARK: - TweetTableViewDelegate
extension TweetTableViewController: TweetTableViewDelegate {

    func reloadTableCellAtIndexPath(_ cell: UITableViewCell, indexPath: IndexPath) {
        guard reloadedIndexPaths.index(of: indexPath.row) == nil else {
            return // already reloaded
        }
        reloadedIndexPaths.append(indexPath.row)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    func openProfile(_ userScreenname: NSString) {
        let vc = AppInfo.storyboard.instantiateViewController(withIdentifier: "ProfileViewNavigationController") as! UINavigationController
        let pVc = vc.viewControllers.first as! ProfileViewController
        pVc.userScreenname = userScreenname
        self.present(vc, animated: true, completion: nil)
    }

    func openCompose(_ vc: UIViewController) {
        self.present(vc, animated: true, completion: nil)
    }

}

// MARK: - UIScrollViewDelegate
extension TweetTableViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !isMoreDataLoading && tweets?.count > 0 {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height

            // When the user has scrolled past the threshold, start requesting
            if scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging {
                isMoreDataLoading = true
                reloadData(true)
            }
        }
    }

}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension TweetTableViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delay(0.2) {
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCompactCell", for: indexPath) as! TweetCompactCell
        cell.indexPath = indexPath
        cell.tweet = tweets![indexPath.row]
        cell.delegate = self
        return cell
    }

}
