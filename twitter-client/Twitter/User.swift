//
//  User.swift
//  Twitter
//
//  Created by Tejen Hasmukh Patel on 2/19/16.
//  Copyright © 2016 Tejen. All rights reserved.
//

import UIKit

final class User: NSObject {

    // MARK: Private Properties
    var id: Int?

    var name: NSString?
    var screenname: NSString?
    var profileUrl: URL?
    var tagline: NSString?
    var backgroundImageURL: String?
    var hasBannerImage = true

    var followersCount: Int?
    var followingCount: Int?

    var locationString: NSString?
    var protected: Bool?

    var dictionary: NSDictionary?

    // MARK: Public Properties
    static var _currentUser: User?
    static var bufferUser: User?

    class var currentUser: User? {
        get {
            if _currentUser == nil {
                let defaults = UserDefaults.standard
                let userData = defaults.object(forKey: "currentUser") as? Data

                if let userData = userData {
                    let dictionary = try! JSONSerialization.jsonObject(with: userData, options: []) as! NSDictionary
                    _currentUser = User(dictionary: dictionary)
                }
            }
            return _currentUser
        }
        set(user) {
            _currentUser = user

            let defaults = UserDefaults.standard

            if let user = user {
                let data = try! JSONSerialization.data(withJSONObject: user.dictionary!, options: [])
                defaults.set(data, forKey: "currentUser")
            } else {
                defaults.set(nil, forKey: "currentUser")
            }

            defaults.synchronize()
        }
    }

    // MARK: - Lifecycle Methods
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary

        id = dictionary["id"] as? Int

        name = dictionary["name"] as? String as! NSString
        screenname = dictionary["screen_name"] as? String as! NSString

        backgroundImageURL = dictionary["profile_banner_url"] as? String
        if backgroundImageURL != nil {
            backgroundImageURL?.append("/600x200")
        } else {
            backgroundImageURL = dictionary["profile_background_image_url_https"] as? String
            hasBannerImage = false
        }
        let profileUrlString = dictionary["profile_image_url_https"] as? String
        profileUrl = URL(string: profileUrlString!.replace("normal.png", withString: "bigger.png"))

        followersCount = dictionary["followers_count"] as? Int
        followingCount = dictionary["friends_count"] as? Int

        locationString = dictionary["location"] as? String as! NSString

        protected = dictionary["protected"] as? Bool

        tagline = dictionary["description"] as? String as! NSString
    }

}
