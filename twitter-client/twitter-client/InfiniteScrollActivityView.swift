//
//  InfiniteScrollActivityView.swift
//  Twitter
//
//  Created by Alexander Svetlichny & Grigory Setezhev in 2017
//  Copyright © 2017 CS333. All rights reserved.
//

import UIKit

final class InfiniteScrollActivityView: UIView {

    // MARK: - Constants
    static let defaultHeight: CGFloat = 60.0

    // MARK: Private Properties
    fileprivate var activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView()

    // MARK: - Lifecycle Methods
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupActivityIndicator()
    }

    override init(frame aRect: CGRect) {
        super.init(frame: aRect)
        setupActivityIndicator()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        activityIndicatorView.center = CGPoint(x: self.bounds.size.width / 2, y: self.bounds.size.height / 2)
    }

    // MARK: Private Methods
    fileprivate func setupActivityIndicator() {
        activityIndicatorView.activityIndicatorViewStyle = .gray
        activityIndicatorView.hidesWhenStopped = true
        addSubview(activityIndicatorView)
    }

    // MARK: Public Methods
    internal func stopAnimating() {
        activityIndicatorView.stopAnimating()
        isHidden = true
    }

    internal func startAnimating() {
        isHidden = false
        activityIndicatorView.startAnimating()
    }

}
