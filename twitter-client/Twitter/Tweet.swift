//
//  Tweet.swift
//  Twitter
//
//  Created by Tejen Hasmukh Patel on 2/19/16.
//  Copyright © 2016 Tejen. All rights reserved.
//

import UIKit

final class Tweet: NSObject {

    // MARK: - Properties
    var TweetID: NSNumber!
    var screenname: NSString?
    var author: NSString?
    var authorProfilePicURL: URL?

    var urls: [NSDictionary]?
    var media: [NSDictionary]?

    var text: String?
    var timestamp: Date?
    var retweetCount: Int = 0
    var favoritesCount: Int = 0

    var precedingTweetID: Int?
    var precedingTweet: Tweet?

    var favorited: Bool {
        didSet {
            if favorited {
                favoritesCount += 1
                TwitterClient.sharedInstance?.favorite(params: ["id": TweetID], favorite: true)
            } else {
                favoritesCount -= 1
                TwitterClient.sharedInstance?.favorite(params: ["id": TweetID], favorite: false)
            }
        }
    }
    var retweeted: Bool {
        didSet {
            if retweeted {
                retweetCount += 1
                TwitterClient.sharedInstance?.retweet(params: ["id": TweetID], retweet: true) { (tweet, error) in
                    print("retweeted")
                }
            } else {
                retweetCount -= 1
                TwitterClient.sharedInstance?.retweet(params: ["id": TweetID], retweet: false) { (tweet, error) in
                    print("unretweeted")
                }
            }
        }
    }

    // MARK: - Lifecycle Methods
    init(dictionary: NSDictionary) {
        TweetID = dictionary["id"] as! NSNumber
        precedingTweetID = dictionary["in_reply_to_status_id"] as? Int

        urls = (dictionary["entities"] as? NSDictionary)?["urls"] as? [NSDictionary]
        media = (dictionary["entities"] as? NSDictionary)?["media"] as? [NSDictionary]
        screenname = (dictionary["user"] as! NSDictionary)["screen_name"] as? NSString
        author = (dictionary["user"] as! NSDictionary)["name"] as? NSString
        authorProfilePicURL = URL(string: ((dictionary["user"] as! NSDictionary)["profile_image_url_https"] as! String).replace("normal.png", withString: "bigger.png"))!

        text = dictionary["text"] as? String

        retweetCount = (dictionary["retweet_count"] as? Int) ?? 0
        favoritesCount = (dictionary["favorite_count"] as? Int) ?? 0

        retweeted = (dictionary["retweeted"] as? Bool) ?? false
        favorited = (dictionary["favorited"] as? Bool) ?? false

        let timestampString = dictionary["created_at"] as? String

        if let timestampString = timestampString {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            timestamp = formatter.date(from: timestampString)
        }
    }

    // MARK: - Public Helper Functions
    class func tweetsWithArray(_ dictionaries: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()

        for dictionary in dictionaries {
            let tweet = Tweet(dictionary: dictionary)
            tweets.append(tweet)
        }

        return tweets
    }

}
