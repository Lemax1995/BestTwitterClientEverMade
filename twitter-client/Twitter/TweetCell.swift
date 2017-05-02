//
//  TweetCell.swift
//  Twitter
//
//  Created by Tejen Hasmukh Patel on 3/3/16.
//  Copyright © 2016 Tejen. All rights reserved.
//

import UIKit

class TweetCell: UITableViewCell {

    // MARK: - Properties
    var tweetID: NSNumber?

    weak var delegate: TweetTableViewDelegate?

    var indexPath: IndexPath!

    var tweetTextFontSize: CGFloat { get { return 15.0 } }
    var tweetTextFontWeight: CGFloat { get { return UIFontWeightRegular } }

    var tweet: Tweet! {
        didSet {
            tweetSetConfigureSubviews()
        }
    }

    // MARK: - IBOutlets
    @IBOutlet var profilePictureImageView: UIImageView!
    @IBOutlet var authorNameLabel: UILabel!
    @IBOutlet var authorScreennameLabel: UILabel!

    @IBOutlet var tweetContentsLabel: UILabel!
    @IBOutlet var tweetAgeLabel: UILabel!

    @IBOutlet var retweetCountLabel: UILabel!
    @IBOutlet var favoriteCountLabel: UILabel!
    @IBOutlet var favoriteButton: DOFavoriteButton!
    @IBOutlet var retweetButton: DOFavoriteButton!

    @IBOutlet var mediaImageView: UIImageView!
    @IBOutlet var mediaImageVerticalSpacingConstraint: NSLayoutConstraint!
    @IBOutlet var mediaImageHeightConstraint: NSLayoutConstraint!

    // MARK: - Lifecycle Methods
    func tweetSetConfigureSubviews() {
        tweetID = tweet.TweetID
        tweetID = tweet.TweetID
        profilePictureImageView.setImageWith(tweet.authorProfilePicURL! as URL)
        profilePictureImageView.layer.cornerRadius = 5
        profilePictureImageView.clipsToBounds = true
        authorNameLabel.text = tweet.author as String?
        authorScreennameLabel.text = "@" + (tweet.screenname!)

        tweetContentsLabel.text = tweet.text

        let urls = tweet.urls
        let media = tweet.media

        retweetButton.isSelected = tweet.retweeted
        favoriteButton.isSelected = tweet.favorited

        mediaImageView.image = nil

        var displayUrls = [String]()

        if let urls = urls {
            for url in urls {
                let urltext = url["url"] as! String
                tweetContentsLabel.text = tweetContentsLabel.text?.replace(urltext, withString: "")

                var displayurl = url["display_url"] as! String
                if let expandedURL = url["expanded_url"] {
                    displayurl = expandedURL as! String
                }
                displayUrls.append(displayurl)
            }
        }

        if let media = media {
            for medium in media {
                let urltext = medium["url"] as! String
                tweetContentsLabel.text = tweetContentsLabel.text?.replace(urltext, withString: "")
                if((medium["type"] as? String) == "photo") {

                    revealPhoto()

                    let mediaurl = medium["media_url_https"] as! String
                    
                    
                    mediaImageHeightConstraint.isActive = false
                    mediaImageView.layer.cornerRadius = 5
                    mediaImageView.clipsToBounds = true

//                    print(mediaurl)
                    DispatchQueue.main.async {
                        self.mediaImageView.setImageWith(URL(string: mediaurl)!)
                        self.delegate?.reloadTableCellAtIndexPath(self, indexPath: self.indexPath)
                    }
                }
            }
        }

        if(displayUrls.count > 0) {
            let content = tweetContentsLabel.text ?? ""

            let urlText = " " + displayUrls.joined(separator: " ")

            let text = NSMutableAttributedString(string: content)

            text.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: tweetTextFontSize, weight: tweetTextFontWeight), range: NSRange(location: 0, length: content.characters.count))

            let links = NSMutableAttributedString(string: urlText)
            links.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: tweetTextFontSize, weight: tweetTextFontWeight), range: NSRange(location: 0, length: urlText.characters.count))

            links.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 36/255.0, green: 144/255.0, blue: 212/255.0, alpha: 1), range: NSRange(location: 0, length: urlText.characters.count))

            text.append(links)

            let style = NSMutableParagraphStyle()
            style.lineSpacing = 5
            style.lineBreakMode = .byCharWrapping
            text.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSRange(location: 0, length: text.string.characters.count))

            tweetContentsLabel.attributedText = text


            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(openProfile))
            authorNameLabel.isUserInteractionEnabled = true
            authorNameLabel.addGestureRecognizer(tapGestureRecognizer)

        }
    }

    // MARK: - IBActions
    @IBAction func onReplyButton(_ sender: DOFavoriteButton) {
        let vNc = AppInfo.storyboard.instantiateViewController(withIdentifier: "ComposeViewNavigationController") as! UINavigationController
        let vc = vNc.viewControllers.first as! ComposeViewController
        vc.replyToTweet = tweet
        delegate!.openCompose(vNc)
    }

    @IBAction func onRetweetButton(_ sender: DOFavoriteButton) {
        if(sender.isSelected) {
            // deselect
            sender.deselect()
            tweet.retweeted = false
            retweetCountLabel.text = String(tweet.retweetCount) 
        } else {
            // select with animation
            sender.select()
            tweet.retweeted = true
            retweetCountLabel.text = String(tweet.retweetCount) 
        }
    }

    @IBAction func onFavoriteButton(_ sender: DOFavoriteButton) {
        if(sender.isSelected) {
            // deselect
            sender.deselect()
            tweet.favorited = false
            favoriteCountLabel.text = String(tweet.favoritesCount) 
        } else {
            // select with animation
            sender.select()
            tweet.favorited = true
            favoriteCountLabel.text = String(tweet.favoritesCount) 
        }
    }

    // MARK: - Private Methods
    func openProfile() {
        let handle = authorScreennameLabel.text

        guard let _ = handle, handle != "@"+((User.currentUser?.screenname)! as String) else {
            AppInfo.switchToProfileTab()
            return
        }

        authorNameLabel.layer.cornerRadius = 5
        authorNameLabel.backgroundColor = UIColor.lightGray
        self.delegate!.openProfile(tweet.screenname! as NSString)
        delay(1.0) {
            self.authorNameLabel.backgroundColor = UIColor.clear
        }
    }

    func revealPhoto() {
        mediaImageVerticalSpacingConstraint.constant = 8
        mediaImageView.isHidden = false
    }

}
