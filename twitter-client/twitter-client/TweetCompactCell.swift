//
//  TweetCompactCell.swift
//  Twitter
//
//  Created by Alexander Svetlichny & Grigory Setezhev in 2017
//  Copyright © 2017 CS333. All rights reserved.
//

import UIKit

final class TweetCompactCell: TweetCell {

    // MARK: - Lifecycle Methods
    override func tweetSetConfigureSubviews() {
        super.tweetSetConfigureSubviews()

        retweetCountLabel.text = tweet.retweetCount > 0 ? String(tweet.retweetCount) : ""
        favoriteCountLabel.text = tweet.favoritesCount > 0 ? String(tweet.favoritesCount) : ""
        tweetAgeLabel.text = tweet.timestamp!.ago
    }

}
