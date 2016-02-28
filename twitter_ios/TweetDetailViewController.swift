//
//  TweetDetailViewController.swift
//  twitter_ios
//
//  Created by Priscilla Lok on 2/20/16.
//  Copyright © 2016 Priscilla Lok. All rights reserved.
//

import UIKit

class TweetDetailViewController: UIViewController {
  
    @IBOutlet weak var retweetTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var retweetsNumberLabel: UILabel!
    @IBOutlet weak var favoritesNumberLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tweetLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var retweetLabel: UILabel!
    @IBOutlet weak var thumbImageView: UIImageView!
    
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var replyButton: UIButton!
    
    var tweet: Tweet!
    var replyUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        if tweet != nil {
            if tweet.isRetweeted == true {
                retweetLabel.text = (tweet.retweetedUser?.name)! + " Retweeted"
            } else {
                retweetLabel.text = "this tweet was not retweeted"
                retweetTopConstraint.constant = -16
            }
            
            setFavoriteButtonImage()
            setRetweetButtonImage()
            thumbImageView.setImageWithURL(NSURL(string: (tweet.user?.profileImageUrl)!)!)
            nameLabel.text = tweet.user?.name
            usernameLabel.text = "@" + (tweet.user?.screenname)!
            tweetLabel.text = tweet.text
            retweetsNumberLabel.text = String(tweet.retweetCount!)
            favoritesNumberLabel.text = String(tweet.favoriteCount!)
            
            thumbImageView.layer.cornerRadius = 3
            thumbImageView.clipsToBounds = true
        }
        
    }


    
    @IBAction func retweetButtonPressed(sender: AnyObject) {
        if tweet.isCurrUserRetweeted == true {
            var tweetId = ""
            if tweet.isRetweeted == false {
                tweetId = tweet.id_str!
            } else {
                tweetId = tweet.originalTweetId_str!
            }
            TwitterClient.sharedInstance.getTweetWithCompletion(tweetId, params: ["include_my_retweet":true]) { (tweet, error) -> () in
                let retweetId = tweet?.retweetId_str
                TwitterClient.sharedInstance.deleteTweetWithCompletion(retweetId!, completion: { (tweet, error) -> () in
                    print("tweet successfully deleted")
                    TwitterClient.sharedInstance.getTweetWithCompletion(tweetId, params: nil, completion: { (tweet, error) -> () in
                        self.tweet = tweet!
                        self.setRetweetButtonImage()
                        self.retweetsNumberLabel.text = String(self.tweet.retweetCount!)
                    })
                    
                })
            }
        } else {
            TwitterClient.sharedInstance.retweetWithCompletion(tweet.id!) { (tweet, error) -> () in
                if tweet != nil {
                    TwitterClient.sharedInstance.getTweetWithCompletion((tweet?.id_str)!, params: nil, completion: { (tweet, error) -> () in
                        self.tweet = tweet!
                        self.setRetweetButtonImage()
                        self.retweetsNumberLabel.text = String(self.tweet.retweetCount!)
                    })
                }
            }
        }
    }
    
    @IBAction func favoriteButtonPressed(sender: AnyObject) {
        if tweet.isFavorited == true {
            TwitterClient.sharedInstance.deleteFavoriteWithCompletion(tweet.id!) { (tweet, error) -> () in
                print ("tweet favorited successfully deleted")
                TwitterClient.sharedInstance.getTweetWithCompletion((tweet?.id_str)!, params: nil, completion: { (tweet, error) -> () in
                    self.tweet = tweet!
                    self.setFavoriteButtonImage()
                    self.favoritesNumberLabel.text = String(self.tweet.favoriteCount!)
                })
            }
        } else {
            TwitterClient.sharedInstance.favoriteWithCompletion(tweet.id) { (tweet, error) -> () in
                if tweet != nil {
                    self.tweet = tweet!
                    self.setFavoriteButtonImage()
                    self.favoritesNumberLabel.text = String(self.tweet.favoriteCount!)
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func setFavoriteButtonImage() {
        if tweet.isFavorited == true {
            favoriteButton.setImage(UIImage(named: "star"), forState: UIControlState.Normal)
        } else {
            favoriteButton.setImage(UIImage(named: "star-unselected"), forState: UIControlState.Normal)
        }
    }
    
    func setRetweetButtonImage() {
        if tweet.isCurrUserRetweeted == true {
            retweetButton.setImage(UIImage(named: "retweet-true"), forState: UIControlState.Normal)
        } else {
            retweetButton.setImage(UIImage(named: "retweet"), forState: UIControlState.Normal)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "newTweetsSegue" {
            let navigationcontroller = segue.destinationViewController as! UINavigationController
            let newTweetViewController = navigationcontroller.topViewController as! NewTweetViewController
            if tweet.user != nil {
                newTweetViewController.newTweet = "@" + (tweet.user?.screenname)! + " "
            }
        }
    }


}
