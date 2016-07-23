//
//  TweetTableViewCell.swift
//  Smashtag
//
//  Created by Vadim on 23.07.16.
//  Copyright © 2016 Vadim Prosviryakov. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var tweetProfileImage: UIImageView!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var tweetCreatedLabel: UILabel!
    @IBOutlet weak var tweetScreenNameLabel: UILabel!
    
    var tweet: Twitter.Tweet? {
        didSet {
            updateUI()
        }
    }
    
    struct Palette {
        static let hashTagColor = UIColor.purpleColor()
        static let urlColor = UIColor.blueColor()
        static let userColor = UIColor.orangeColor()
    }
    
    private func setTextLabel(tweet: Tweet) -> NSMutableAttributedString {
        var tweetText: String = tweet.text
        
        for _ in tweet.media { tweetText += " 📷" }
        
        let attributedText = NSMutableAttributedString(string: tweetText)
        attributedText.setMensionsColor(tweet.hashtags, color: Palette.hashTagColor)
        attributedText.setMensionsColor(tweet.urls, color: Palette.urlColor)
        attributedText.setMensionsColor(tweet.userMentions, color: Palette.userColor)
        
        return attributedText
    }
    
    private func updateUI() {
        
        // переустанавливаем информацию существующего твита
        tweetTextLabel.attributedText = nil
        tweetCreatedLabel.text = nil
        tweetScreenNameLabel.text = nil
        tweetProfileImage.image = nil
        
        // загружаем новую информацию для нашего твита (если он есть)
        if let tweet = self.tweet {
            tweetTextLabel.attributedText = setTextLabel(tweet)
            if tweetTextLabel.text != nil {
                for _ in tweet.media {
                    tweetTextLabel.text! += " 📷"
                    
                }
            }
            
        }
        
        tweetScreenNameLabel.text = "\(tweet?.user)"
        
        if let profileImageURL = tweet!.user.profileImageURL {
            if let data = NSData(contentsOfURL: profileImageURL) {
                dispatch_async(dispatch_get_main_queue(), {
                    self.tweetProfileImage.image = UIImage(data: data)
                })
            }
        }
        
        let formatter = NSDateFormatter()
        if NSDate().timeIntervalSinceDate(tweet!.created) > 24*60*60 {
            formatter.dateStyle = NSDateFormatterStyle.ShortStyle
        } else {
            formatter.timeStyle = NSDateFormatterStyle.ShortStyle
        }
        tweetCreatedLabel.text = formatter.stringFromDate(tweet!.created)
    }
}

extension NSMutableAttributedString {
    func setMensionsColor(mensions:[Mention], color: UIColor) {
        for mension in mensions {
            addAttribute(NSForegroundColorAttributeName, value: color, range: mension.nsrange)
        }
    }
}
