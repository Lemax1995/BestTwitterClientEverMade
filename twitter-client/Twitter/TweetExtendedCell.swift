//
//  TweetExtendedCell.swift
//  Twitter
//
//  Created by Alexander Svertlichny and Grigory Setezhev.
//  Copyright © 2017 MMCS SFEDU. All rights reserved.
//

import UIKit

final class TweetExtendedCell: TweetCell {

    // MARK: Private Properties
    override var tweetTextFontSize: CGFloat { get { return 20.0 } }
    override var tweetTextFontWeight: CGFloat { get { return UIFontWeightLight } }

    // MARK: - Lifecycle Methods
    override func tweetSetConfigureSubviews() {
        super.tweetSetConfigureSubviews()

        retweetCountLabel.text = String(tweet.retweetCount)
        favoriteCountLabel.text = String(tweet.favoritesCount)
        tweetAgeLabel.text = tweet.timestamp!.humanReadable.datetime
    }

    // MARK: - Private Methods
    override func revealPhoto() {
        mediaImageVerticalSpacingConstraint.constant = 16
        mediaImageView.alpha = 1
    }

}
