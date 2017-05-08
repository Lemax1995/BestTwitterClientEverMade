//
//  TwitterClient.swift
//  Twitter
//
//  Created by Alexander Svertlichny and Grigory Setezhev.
//  Copyright © 2017 MMCS SFEDU. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

final class TwitterClient: BDBOAuth1SessionManager {

    // MARK: Constants
    static let sharedInstance = TwitterClient(
        baseURL: URL(string: "https://api.twitter.com"),
        consumerKey: "U04FBOTu0NpvIxZnxehbXjqE3",
        consumerSecret: "cT8OrcKsG3kXTC8QLYXmwm1iUECvVqc0VHnq8NhUAMpytm7Uh8"
    )

    // MARK: Private Properties
    var loginSuccess: (() -> ())?
    var loginFailure: ((NSError) -> ())?

    var buffer: Tweet?
    var bufferComplete: (() -> ())?

    var attemptingLogin = false {
        didSet {
            if attemptingLogin {
                delegate?.doNotContinueLogin()
            }
        }
    }

    weak var delegate: TwitterLoginLoungeDelegate? {
        didSet {
            if attemptingLogin {
                delegate!.doNotContinueLogin()
            }
        }
    }

    // MARK: - Private Methods
    func login(success: @escaping () -> (), failure: @escaping (NSError) -> ()) {
        loginSuccess = success
        loginFailure = failure
        
        deauthorize()
        fetchRequestToken(withPath: "oauth/request_token", method: "GET", callbackURL: URL(string: "twitterTejen://oauth")!, scope: nil, success: { (requestToken: BDBOAuth1Credential!) -> Void in
            let url = URL(string: "https://api.twitter.com/oauth/authorize?oauth_token="+requestToken.token)!
            UIApplication.shared.openURL(url)
        }, failure: { (error: Error!) -> Void in
            print("API Error: \(error.localizedDescription)")
            self.loginFailure!(error! as NSError) // can force. value was set earlier on in login().
        })
    }
    func logout() {
        User.currentUser = nil
        deauthorize()

        NotificationCenter.default.post(name: NSNotification.Name(rawValue: AppInfo.notifications.UserDidLogout), object: nil)
    }

    func handleOpenUrl(url: NSURL) {
        attemptingLogin = true

        let requestToken = BDBOAuth1Credential(queryString: url.query)

        fetchAccessToken(withPath: "oauth/access_token", method: "POST", requestToken: requestToken, success: { (accessToken: BDBOAuth1Credential!) -> Void in
            self.currentAccount(success: { user in
                User.currentUser = user
                self.loginSuccess?()
                self.attemptingLogin = false
                self.delegate?.continueLogin()
            }, failure: { error in
                self.loginFailure?(error! as NSError)
            })
            self.loginSuccess?()
        }, failure: { (error: Error!) -> Void in
            print("error: " + error.localizedDescription)
            self.loginFailure?(error! as NSError)
        })
    }

     func currentAccount(success: @escaping (User) -> (), failure: @escaping (Error?) -> ()) {
        self.get(
            "1.1/account/verify_credentials.json",
            parameters: nil,
            progress: nil,
            success: { (task, response) in
                let userDict = response as! NSDictionary
                let user = User(dictionary: userDict)
                success(user)
        }, failure: { (task, error) in
            failure(error)
        }
        )
    }
    /**func currentAccount(success: @escaping (User) -> (), failure: @escaping (NSError) -> ()) {
        get("1.1/account/verify_credentials.json", parameters: nil, success: { (task: URLSessionDataTask, response: AnyObject?) -> Void in
            let userDictionary = response as! NSDictionary
            let user = User(dictionary: userDictionary)
            success(user)
        } as! (URLSessionDataTask, Any?) -> Void, failure: { (task: URLSessionDataTask?, error: NSError) -> Void in
            print("error: \(error.localizedDescription)")
            failure(error)
        } as! (URLSessionDataTask?, Error) -> Void)
    } */

    func homeTimeline(
        maxId: Int?,
        success: @escaping ([Tweet]) -> (),
        failure: @escaping (Error?) -> ()) {
        
        var params = ["count": 10]
        if maxId != nil {
            params["max_id"] = maxId
        }
        
        self.get(
            "1.1/statuses/home_timeline.json",
            parameters: params,
            progress: nil,
            success: { (task, response) in
                let dictionaries = response as! [NSDictionary]
                let tweets = Tweet.tweetsWithArray(dictionaries)
                success(tweets)
        }, failure: { (task, error) in
            failure(error)
        }
        )
    }
    
    /**func homeTimeline(maxId: Int? = nil, success: @escaping ([Tweet]) -> (), failure: @escaping (NSError) -> ()) {
        var params = ["count": 10]
        if maxId != nil {
            params["max_id"] = maxId
        }

        // dummy api to overcome rate limit problems:
        // https://tejen.net/sub/codepath/twitter/#home_timeline.json
        get("1.1/statuses/home_timeline.json", parameters: params, success: { (task: URLSessionDataTask, response: AnyObject?) -> Void in
            let dictionaries = response as! [NSDictionary]
            let tweets = Tweet.tweetsWithArray(dictionaries)
            success(tweets)
        } as! (URLSessionDataTask, Any?) -> Void, failure: { (task: URLSessionDataTask?, error: NSError) -> Void in
            failure(error)
        } as! (URLSessionDataTask?, Error) -> Void)
    }*/

    func user_timeline(user: User, maxId: Int? = nil, success: @escaping ([Tweet]) -> (), failure: @escaping (NSError) -> ()) {
        var params = ["count": 10]
        params["user_id"] = user.id!
        if maxId != nil {
            params["max_id"] = maxId
        }
        
        self.get(
            "/1.1/statuses/user_timeline.json",
            parameters: params,
            progress: nil,
            success: { (task, response) in
                let tweetsArray = response as! [NSDictionary]
                let tweets = Tweet.tweetsWithArray(tweetsArray)
                success(tweets)
        }
        )
        
    /**  self.get("1.1/statuses/user_timeline.json", parameters: params, success: { (task: URLSessionDataTask, response: AnyObject?) -> Void in
            let dictionaries = response as! [NSDictionary]
            let tweets = Tweet.tweetsWithArray(dictionaries)
            success(tweets)
        } as? (URLSessionDataTask, Any?) -> Void, failure: { (task: URLSessionDataTask?, error: NSError) -> Void in
            failure(error)
        } as? (URLSessionDataTask?, Error) -> Void) */
    }

    func favorite(params: NSDictionary?, favorite: Bool, completion: @escaping (_ tweet: Tweet?, _ error: NSError?) -> (Void) = {_, _ in }) {
        let endpoint = favorite ? "create" : "destroy"
        self.post("1.1/favorites/\(endpoint).json", parameters: params, success: { (operation: URLSessionDataTask, response: AnyObject?) -> Void in
            let tweet = Tweet(dictionary: response as! NSDictionary)
            completion(tweet, nil)
        } as? (URLSessionDataTask, Any?) -> Void, failure: { (operation: URLSessionDataTask?, error: NSError) -> Void in
            completion(nil, error)
        } as? (URLSessionDataTask?, Error) -> Void)
    }

    func retweet(params: NSDictionary?, retweet: Bool, completion: @escaping (_ tweet: Tweet?, _ error: NSError?) -> (Void) = {_, _ in }) {
        let tweetID = params!["id"] as! Int
        let endpoint = retweet ? "retweet" : "unretweet"
        self.post("1.1/statuses/\(endpoint)/\(tweetID).json", parameters: params, success: { (operation: URLSessionDataTask, response: AnyObject?) -> Void in
            let tweet = Tweet(dictionary: response as! NSDictionary)
            completion(tweet, nil)
        } as? (URLSessionDataTask, Any?) -> Void, failure: { (operation: URLSessionDataTask?, error: NSError) -> Void in
            completion(nil, error)
        } as? (URLSessionDataTask?, Error) -> Void)
    }

//    func populateTweetByID(TweetID: Int, completion: ((tweet: Tweet?, error: NSError?) -> (Void))? = nil) {
//        get("1.1/statuses/show.json?id=\(TweetID)", parameters: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
//            let dictionary = response as! NSDictionary
//            let tweet = Tweet(dictionary: dictionary)
//            completion?(tweet: tweet, error: nil)
//        }, failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
//            completion?(tweet: nil, error: error)
//        })
//    }
    
    func populateTweetByID(TweetID: Int, completion: ((_ tweet: Tweet?, _ error: NSError?) -> (Void))? = nil) {
        self.get("1.1/statuses/show.json?id=\(TweetID)", parameters: nil, success: { (task: URLSessionDataTask, response: AnyObject?) -> Void in
            let dictionary = response as! NSDictionary
            let tweet = Tweet(dictionary: dictionary)
            completion?(tweet, nil)
        } as? (URLSessionDataTask, Any?) -> Void, failure: { (task: URLSessionDataTask?, error: NSError) -> Void in
            (completion?(nil, error))!
        } as? (URLSessionDataTask?, Error) -> Void)
    }

    func populatePreviousTweets(tweet: Tweet, completion: (()->())? = nil) {
        bufferComplete = completion ?? bufferComplete

        print("populating previous tweet for: \(tweet.TweetID)")

        guard tweet.precedingTweetID != nil else { // base case
            print("chain complete")
            self.buffer = nil
            self.bufferComplete?()
            return
        }

        buffer = tweet
        populateTweetByID(TweetID: tweet.precedingTweetID!) { (tweet, error) -> (Void) in
            self.buffer?.precedingTweet = tweet
            self.populatePreviousTweets(tweet: tweet!)
        }
    }

    func publishTweet(text: String, replyToTweetID: NSNumber? = 0, success: @escaping (Tweet) -> ()) {
        // Warning: this'll create a live tweet with the given text on behalf of the current user!
        guard text.characters.count > 0 else {
            return
        }
        var params = ["status": text as AnyObject]
        if let replyToTweetID = replyToTweetID {
            params["in_reply_to_status_id"] = replyToTweetID as AnyObject
        }

        self.post("1.1/statuses/update.json", parameters: params, success: { (operation: URLSessionDataTask, response: AnyObject?) -> Void in
            let tweet = Tweet(dictionary: response as! NSDictionary)
            success(tweet)
        } as? (URLSessionDataTask, Any?) -> Void)
    }

    func getUserByScreenname(screenname: NSString, success: @escaping (User) -> (), failure: ((NSError) -> ())? = nil) {
        self.get("1.1/users/lookup.json?screen_name=" + String(screenname), parameters: nil, success: { (task: URLSessionDataTask, response: AnyObject?) -> Void in
            let userDictionary = response as! [NSDictionary]
            let user = User(dictionary: userDictionary[0])
            success(user)
        } as? (URLSessionDataTask, Any?) -> Void, failure: { (task: URLSessionDataTask?, error: NSError) -> Void in
            print("error: \(error.localizedDescription)")
            failure?(error)
        } as? (URLSessionDataTask?, Error) -> Void)
    }

//    func get(endpoint: String, parameters: NSDictionary?, success: @escaping ((_ operation: URLSessionDataTask, _ response: AnyObject?) -> ()), failure: ((_ operation: URLSessionDataTask?, _ error: NSError) -> ())? = nil) {
//        get(endpoint, parameters: parameters, success: success as! (URLSessionDataTask, Any?) -> Void, failure: failure as! (URLSessionDataTask?, Error) -> Void)
//    }
//
//    func post(endpoint: String, parameters: NSDictionary?, success: @escaping ((_ operation: URLSessionDataTask, _ response: AnyObject?) -> ()), failure: ((_ operation: URLSessionDataTask?, _ error: NSError) -> ())? = nil) {
//        post(endpoint, parameters: parameters, success: success as! (URLSessionDataTask, Any?) -> Void, failure: failure as! (URLSessionDataTask?, Error) -> Void)
//    }

}
