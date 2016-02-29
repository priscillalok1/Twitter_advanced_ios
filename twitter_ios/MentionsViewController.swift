//
//  MentionsViewController.swift
//  twitter_ios
//
//  Created by Priscilla Lok on 2/27/16.
//  Copyright © 2016 Priscilla Lok. All rights reserved.
//

import UIKit

class MentionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, tweetCellDelegate, NewTweetViewControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    var tweets: [Tweet]!
    var replyUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        TwitterClient.sharedInstance.mentionsTimelineWithCompletion(nil) { (tweets, error) -> () in
            self.tweets = tweets
            self.tableView.reloadData()
            
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table View methods
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("tweetCell", forIndexPath: indexPath) as! tweetCell
        cell.tweet = tweets![indexPath.row]
        cell.delegate = self
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tweets == nil {
            return 0
        } else {
            return tweets!.count
        }
    }
    
    
    // MARK: - TweetCell Delegate Methods
    func tweetedCell(tweetedCell: tweetCell, retweetButtonPressed value: Bool) {
        let indexPath = tableView.indexPathForCell(tweetedCell)!
        
        if tweetedCell.tweet.isCurrUserRetweeted == true {
            unretweet(tweetedCell.tweet, index: indexPath)
        } else {
            TwitterClient.sharedInstance.retweetWithCompletion(tweets![indexPath.row].id!) { (tweet, error) -> () in
                if tweet != nil {
                    TwitterClient.sharedInstance.getTweetWithCompletion(tweetedCell.tweet.id_str!, params: nil, completion: { (tweet, error) -> () in
                        self.tweets![indexPath.row] = tweet!
                        self.tableView.reloadData()
                    })
                }
            }
        }
    }
    
    func tweetedCell(tweetedCell: tweetCell, favoriteButtonPressed value: Bool) {
        let indexPath = tableView.indexPathForCell(tweetedCell)!
        
        if tweetedCell.tweet.isFavorited == true {
            unfavorite(tweetedCell.tweet, index: indexPath)
        } else {
            TwitterClient.sharedInstance.favoriteWithCompletion(tweets![indexPath.row].id) { (tweet, error) -> () in
                if tweet != nil {
                    self.tweets![indexPath.row] = tweet!
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func tweetedCell(tweetedCell: tweetCell, replyButtonPressed value: Bool) {
        replyUser = tweetedCell.tweet.user
        self.performSegueWithIdentifier("newTweetFromMentionSegue", sender: self)
    }
    
    //MARK: - Private methods
    func unretweet(tweet: Tweet, index: NSIndexPath) {
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
                    self.tweets![index.row] = tweet!
                    self.tableView.reloadData()
                })
                
            })
        }
    }
    
    func unfavorite(tweet: Tweet, index: NSIndexPath) {
        TwitterClient.sharedInstance.deleteFavoriteWithCompletion(tweet.id!) { (tweet, error) -> () in
            print ("tweet favorited successfully deleted")
            TwitterClient.sharedInstance.getTweetWithCompletion((tweet?.id_str)!, params: nil, completion: { (tweet, error) -> () in
                self.tweets![index.row] = tweet!
                self.tableView.reloadData()
            })
        }
    }
    
    // MARK: - NewTweetViewController Delegate Method
    func newTweetViewController(newTweetViewController: NewTweetViewController, didCreateTweet newTweet: String) {
        TwitterClient.sharedInstance.tweetWithCompletion(["status": newTweetViewController.newTweet!]) { (tweet, error) -> () in
            if tweet != nil {
                self.tweets?.insert(tweet!, atIndex: 0)
                self.tableView.reloadData()
                print("new tweet created")
                
            }
        }
    }


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "newTweetFromMentionSegue" {
            let navigationcontroller = segue.destinationViewController as! UINavigationController
            let newTweetViewController = navigationcontroller.topViewController as! NewTweetViewController
            if replyUser != nil {
                newTweetViewController.newTweet = "@" + (replyUser?.screenname)! + " "
            }
            newTweetViewController.delegate = self
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
