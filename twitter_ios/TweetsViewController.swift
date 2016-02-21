//
//  TweetsViewController.swift
//  twitter_ios
//
//  Created by Priscilla Lok on 2/19/16.
//  Copyright © 2016 Priscilla Lok. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, tweetCellDelegate, UIScrollViewDelegate {
    
    var tweets: [Tweet]?
    var retweetStates = [Int: Bool]()
    var favoriteStates = [Int: Bool]()
    
    var isMoreDataLoading = false
    
    var lastTweetId: Int?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        TwitterClient.sharedInstance.homeTimelineWithCompletion(nil, completion: { (tweets, error) -> () in
            self.tweets = tweets
            self.tableView.reloadData()
            self.lastTweetId = self.tweets![(self.tweets?.count)!-1].id
        })
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func onLogout(sender: AnyObject) {
        User.currentUser?.logout()
    }
    
    // MARK: - Table View methods
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("tweetCell", forIndexPath: indexPath) as! tweetCell
        cell.tweet = tweets![indexPath.row]
        cell.delegate = self
        
//        cell.isRetweeted = tweets![indexPath.row].isRetweeted ?? false
//        cell.setRetweetButtonImage()
//        
//        cell.isFavorited = tweets![indexPath.row].isFavorited ?? false
//        cell.setFavoriteButtonImage()
        
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
        TwitterClient.sharedInstance.retweetWithCompletion(tweets![indexPath.row].id!) { (tweet, error) -> () in
            if tweet != nil {
                self.tweets![indexPath.row] = tweet!
                self.tableView.reloadData()
            }
        }

    }
    
    func tweetedCell(tweetedCell: tweetCell, favoriteButtonPressed value: Bool) {
        let indexPath = tableView.indexPathForCell(tweetedCell)!
        TwitterClient.sharedInstance.favoriteWithCompletion(tweets![indexPath.row].id) { (tweet, error) -> () in
            if tweet != nil {
                self.tweets![indexPath.row] = tweet!
                self.tableView.reloadData()
            }
        }
        
    }
    // MARK: - Refresh Methods
    
    // Makes a network request to get updated data
    // Updates the tableView with the new data
    // Hides the RefreshControl
    func refreshControlAction(refreshControl: UIRefreshControl) {
        TwitterClient.sharedInstance.homeTimelineWithCompletion(nil, completion: { (tweets, error) -> () in
            self.tweets = tweets
            self.tableView.reloadData()
            self.lastTweetId = self.tweets![(self.tweets?.count)!-1].id
            refreshControl.endRefreshing()
        })
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging) {
                isMoreDataLoading = true
                // Code to load more results
                loadMoreData()
            }
        }
    }
    
    func loadMoreData() {
        TwitterClient.sharedInstance.homeTimelineWithCompletion(["max_id":lastTweetId!], completion: { (tweets, error) -> () in
            self.isMoreDataLoading = false
            for tweet in tweets!{
                self.tweets?.append(tweet)
            }
            self.tableView.reloadData()
        })
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "newTweetsSegue" {
         //   let navigationcontroller = segue.destinationViewController as! UINavigationController
        } else if segue.identifier == "tweetDetailSegue" {
            let indexPath: NSIndexPath = tableView.indexPathForSelectedRow!
            let detailViewController = segue.destinationViewController as! TweetDetailViewController
            detailViewController.tweet = self.tweets![indexPath.row]
        } else if segue.identifier == "replyTweetSegue" {
            
        }
    }


}
