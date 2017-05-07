//
//  HomeViewDelegate.swift
//  Twitter
//
//  Created by Alexander Svertlichny and Grigory Setezhev.
//  Copyright © 2017 MMCS SFEDU. All rights reserved.
//

import UIKit

protocol TweetTableViewDelegate: class {

    func reloadTableCellAtIndexPath(_ cell: UITableViewCell, indexPath: IndexPath)

    func openProfile(_ userScreenname: NSString)

    func openCompose(_ viewController: UIViewController)

}
