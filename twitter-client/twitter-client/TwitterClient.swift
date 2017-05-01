//
//  TwitterClient.swift
//  Twitter
//
//  Created by Alexander Svetlichny & Grigory Setezhev in 2017
//  Copyright © 2017 CS333. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

final class TwitterClient: BDBOAuth1SessionManager {

    // MARK: Constants
    static let sharedInstance = TwitterClient(
        baseURL: URL(string: "https://api.twitter.com")!,
        consumerKey: "FfO8yyWc4a8jWoiSVU2OKS3ko",
        consumerSecret: "JMBKfoPjeRSeSYBschJj3uP3vdgG9yxRMvi7dp0j3MXJOxiRTP"
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
        fetchRequestToken(withPath: "oauth/request_token", method: "GET", callbackURL: URL(string: "twittersvetly://oauth")!, scope: nil, success: { (requestToken: BDBOAuth1Credential!) -> Void in
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
                self.loginFailure?(error)
            })
            self.loginSuccess?()
        }, failure: { (error: NSError!) -> Void in
            print("error: " + error.localizedDescription)
            self.loginFailure?(error)
        } as! (Error?) -> Void)
    }

    func currentAccount(success: @escaping (User) -> (), failure: @escaping (NSError) -> ()) {
        get("1.1/account/verify_credentials.json", parameters: nil, success: { (task: URLSessionDataTask, response: AnyObject?) -> Void in
            let userDictionary = response as! NSDictionary
            let user = User(dictionary: userDictionary)
            success(user)
        } as! (URLSessionDataTask, Any?) -> Void, failure: { (task: URLSessionDataTask?, error: NSError) -> Void in
            print("error: \(error.localizedDescription)")
            failure(error)
        } as! (URLSessionDataTask?, Error) -> Void)
    }

    func homeTimeline(maxId: Int? = nil, success: @escaping ([Tweet]) -> (), failure: @escaping (NSError) -> ()) {
        var params = ["count": 10]
        if maxId != nil {
            params["max_id"] = maxId
        }
        
        // dummy api to overcome rate limit problems:
        // https://tejen.net/sub/codepath/twitter/#home_timeline.json
        get(endpoint: "1.1/statuses/home_timeline.json", parameters: params as NSDictionary, success: { (task: URLSessionDataTask, response: AnyObject?) -> Void in
            let dictionaries = response as! [NSDictionary]
            let tweets = Tweet.tweetsWithArray(dictionaries)
            success(tweets)
            } as! (URLSessionDataTask, Any?) -> Void, failure: { (task: URLSessionDataTask?, error: NSError) -> Void in
                failure(error)
                } as! (URLSessionDataTask?, Error) -> Void)
    }

    func user_timeline(user: User, maxId: Int? = nil, success: @escaping ([Tweet]) -> (), failure: @escaping (NSError) -> ()) {
        var params = ["count": 10]
        params["user_id"] = user.id!
        if maxId != nil {
            params["max_id"] = maxId
        }
        
        get(endpoint: "1.1/statuses/user_timeline.json", parameters: params as NSDictionary, success: { (task: URLSessionDataTask, response: AnyObject?) -> Void in
            let dictionaries = response as! [NSDictionary]
            let tweets = Tweet.tweetsWithArray(dictionaries)
            success(tweets)
            } as! (URLSessionDataTask, Any?) -> Void, failure: { (task: URLSessionDataTask?, error: NSError) -> Void in
                failure(error)
                } as! (URLSessionDataTask?, Error) -> Void)
    }

    func favorite(params: NSDictionary?, favorite: Bool, completion: @escaping (_ tweet: Tweet?, _ error: NSError?) -> (Void) = {_, _ in }) {
        let endpoint = favorite ? "create" : "destroy"
        post(endpoint: "1.1/favorites/\(endpoint).json", parameters: params, success: { (operation: URLSessionDataTask, response: AnyObject?) -> Void in
            let tweet = Tweet(dictionary: response as! NSDictionary)
            completion(tweet, nil)
            } as! (URLSessionDataTask, Any?) -> Void, failure: { (operation: URLSessionDataTask?, error: NSError) -> Void in
                completion(nil, error)
                } as! (URLSessionDataTask?, Error) -> Void)
    }
    
    func retweet(params: NSDictionary?, retweet: Bool, completion: @escaping (_ tweet: Tweet?, _ error: NSError?) -> (Void) = {_, _ in }) {
        let tweetID = params!["id"] as! Int
        let endpoint = retweet ? "retweet" : "unretweet"
        post(endpoint: "1.1/statuses/\(endpoint)/\(tweetID).json", parameters: params, success: { (operation: URLSessionDataTask, response: AnyObject?) -> Void in
            let tweet = Tweet(dictionary: response as! NSDictionary)
            completion(tweet, nil)
            } as! (URLSessionDataTask, Any?) -> Void, failure: { (operation: URLSessionDataTask?, error: NSError) -> Void in
                completion(nil, error)
                } as! (URLSessionDataTask?, Error) -> Void)
    }
    
    func populateTweetByID(TweetID: Int, completion: ((_ tweet: Tweet?, _ error: NSError?) -> (Void))? = nil) {
        get(endpoint: "1.1/statuses/show.json?id=\(TweetID)", parameters: nil, success: { (task: URLSessionDataTask, response: AnyObject?) -> Void in
            let dictionary = response as! NSDictionary
            let tweet = Tweet(dictionary: dictionary)
            completion?(tweet, nil)
            } as! (URLSessionDataTask, Any?) -> Void, failure: { (task: URLSessionDataTask?, error: NSError) -> Void in
                (completion?(nil, error))!
                } as! (URLSessionDataTask?, Error) -> Void)
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
        let params = ["status": text, "in_reply_to_status_id": Int(replyToTweetID!)] as [String : Any]
        post(endpoint: "1.1/statuses/update.json", parameters: params as NSDictionary, success: { (operation: URLSessionDataTask, response: AnyObject?) -> Void in
            let tweet = Tweet(dictionary: response as! NSDictionary)
            success(tweet)
            } as! (URLSessionDataTask, Any?) -> Void)
    }
    
    func getUserByScreenname(screenname: NSString, success: @escaping (User) -> (), failure: ((NSError) -> ())? = nil) {
        get(endpoint: "1.1/users/lookup.json?screen_name=" + String(screenname), parameters: nil, success: { (task: URLSessionDataTask, response: AnyObject?) -> Void in
            let userDictionary = response as! [NSDictionary]
            let user = User(dictionary: userDictionary[0])
            success(user)
            } as! (URLSessionDataTask, Any?) -> Void, failure: { (task: URLSessionDataTask?, error: NSError) -> Void in
                print("error: \(error.localizedDescription)")
                failure?(error)
                } as! (URLSessionDataTask?, Error) -> Void)
    }
    
    func get(endpoint: String, parameters: NSDictionary?, success: @escaping ((_ operation: URLSessionDataTask, _ response: AnyObject?) -> ()), failure: ((_ operation: URLSessionDataTask?, _ error: NSError) -> ())? = nil) {
        get(endpoint: endpoint, parameters: parameters, success: success as! (URLSessionDataTask, Any?) -> Void, failure: failure as! (URLSessionDataTask?, Error) -> Void)
    }
    
    func post(endpoint: String, parameters: NSDictionary?, success: @escaping ((_ operation: URLSessionDataTask, _ response: AnyObject?) -> ()), failure: ((_ operation: URLSessionDataTask?, _ error: NSError) -> ())? = nil) {
        post(endpoint: endpoint, parameters: parameters, success: success as! (URLSessionDataTask, Any?) -> Void, failure: failure as! (URLSessionDataTask?, Error) -> Void)
    }
}
