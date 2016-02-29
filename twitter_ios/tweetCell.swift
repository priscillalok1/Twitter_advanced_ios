//
//  tweetCell.swift
//  twitter_ios
//
//  Created by Priscilla Lok on 2/19/16.
//  Copyright © 2016 Priscilla Lok. All rights reserved.
//

import UIKit

extension String {
    public func indexOfCharacter(char: Character) -> Int? {
        if let idx = self.characters.indexOf(char) {
            return self.startIndex.distanceTo(idx)
        }
        return nil
    }
}

@objc protocol tweetCellDelegate {
    optional func tweetedCell (tweetedCell: tweetCell, retweetButtonPressed value:Bool)
    optional func tweetedCell (tweetedCell: tweetCell, favoriteButtonPressed value:Bool)
    optional func tweetedCell (tweetedCell: tweetCell, replyButtonPressed value: Bool)
    optional func tweetedCell (tweetedCell: tweetCell, thumbImageButtonPressed value: Bool)
}

class tweetCell: UITableViewCell {

    @IBOutlet weak var favoriteCountLabel: UILabel!
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var tweetLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var retweetLabel: UILabel!
    @IBOutlet weak var retweetTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var thumbImageButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var replyButton: UIButton!
    
    weak var delegate: tweetCellDelegate?
    
    var timeAtLoad: NSDate!
    
    let calendar = NSCalendar.currentCalendar()
    
    var tweet: Tweet! {
        didSet {
            if tweet.isRetweeted == true {
                retweetLabel.text = (tweet.retweetedUser?.name)! + " Retweeted"
                let indexSemicolon = tweet.text?.indexOfCharacter(":")
                let index1 = tweet.text?.startIndex.advancedBy(indexSemicolon! + 2)
                let substring1 = tweet.text!.substringFromIndex(index1!)
                tweetLabel.text = substring1
            } else {
                retweetLabel.text = "this tweet was not retweeted"
                retweetTopConstraint.constant = -16
                tweetLabel.text = tweet.text
            }
            setRetweetButtonImage()
            setFavoriteButtonImage()
            thumbImageView.setImageWithURL(NSURL(string: (tweet.user?.profileImageUrl)!)!)
            nameLabel.text = tweet.user?.name
            usernameLabel.text = "@" + (tweet.user?.screenname)!
            timeLabel.text = formattedCreatedAtString(tweet.createdAt!)
            favoriteCountLabel.text = String(tweet.favoriteCount!)
            retweetCountLabel.text = String(tweet.retweetCount!)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tweetLabel.preferredMaxLayoutWidth = tweetLabel.frame.width

    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = UITableViewCellSelectionStyle.None
        
        thumbImageView.layer.cornerRadius = 3
        thumbImageView.clipsToBounds = true
        
        tweetLabel.preferredMaxLayoutWidth = tweetLabel.frame.width
        
        retweetButton.addTarget(self, action: "retweetButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
        favoriteButton.addTarget(self, action: "favoriteButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
        replyButton.addTarget(self, action: "replyButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
//        print(thumbImageButton)
//        thumbImageButton.addTarget(self, action: "thumbImageButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onThumbImageButtonPressed(sender: AnyObject) {
        delegate?.tweetedCell!(self, thumbImageButtonPressed: thumbImageButton.touchInside)
    }
    
    //MARK: -Private Methods
    func thumbImageButtonPressed() {
        delegate?.tweetedCell!(self, thumbImageButtonPressed: thumbImageButton.touchInside)
    }
    
    func retweetButtonPressed() {
        delegate?.tweetedCell!(self, retweetButtonPressed: retweetButton.touchInside)
    }
    
    func setRetweetButtonImage() {
        if tweet.isCurrUserRetweeted == true {
            retweetButton.setImage(UIImage(named: "retweet-true"), forState: UIControlState.Normal)
        } else {
            retweetButton.setImage(UIImage(named: "retweet"), forState: UIControlState.Normal)
        }
    }
    
    func favoriteButtonPressed() {
        delegate?.tweetedCell!(self, favoriteButtonPressed: favoriteButton.touchInside)
    }
    
    func setFavoriteButtonImage() {
        if tweet.isFavorited == true {
            favoriteButton.setImage(UIImage(named: "star"), forState: UIControlState.Normal)
        } else {
            favoriteButton.setImage(UIImage(named: "star-unselected"), forState: UIControlState.Normal)
        }
    }
    
    func replyButtonPressed() {
        delegate?.tweetedCell!(self, replyButtonPressed: replyButton.touchInside)
    }
    
    func formattedCreatedAtString (date: NSDate) -> String {
        var formattedDateString = ""
        let elapsedTimeComponents = calendar.components(
            [.Second, .Minute, .Hour, .Day],
            fromDate: tweet.createdAt!,
            toDate: NSDate(),
            options: [])
        if elapsedTimeComponents.day >= 1 {
            formattedDateString = String(elapsedTimeComponents.day) + "days"
        } else if elapsedTimeComponents.hour >= 1 {
            formattedDateString = String(elapsedTimeComponents.hour) + " h"
        } else if elapsedTimeComponents.minute >= 1 {
            formattedDateString = String(elapsedTimeComponents.minute) + " min"
        } else if elapsedTimeComponents.second >= 1 {
            formattedDateString = String(elapsedTimeComponents.second) + " s"
        } else {
            formattedDateString = "now"
        }
        return formattedDateString
        
    }
}
