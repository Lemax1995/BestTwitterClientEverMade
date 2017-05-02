//
//  HomeViewDelegate.swift
//  Twitter
//
//  Created by Tejen Hasmukh Patel on 2/27/16.
//  Copyright © 2016 Tejen. All rights reserved.
//

import UIKit

protocol TweetTableViewDelegate: class {

    func reloadTableCellAtIndexPath(_ cell: UITableViewCell, indexPath: IndexPath)

    func openProfile(_ userScreenname: NSString)

    func openCompose(_ viewController: UIViewController)

}
