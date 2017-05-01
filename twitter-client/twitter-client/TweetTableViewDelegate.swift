//
//  HomeViewDelegate.swift
//  Twitter
//
//  Created by Alexander Svetlichny & Grigory Setezhev in 2017
//  Copyright © 2017 CS333. All rights reserved.
//

import UIKit

protocol TweetTableViewDelegate: class {

    func reloadTableCellAtIndexPath(_ cell: UITableViewCell, indexPath: IndexPath)

    func openProfile(_ userScreenname: NSString)

    func openCompose(_ viewController: UIViewController)

}
