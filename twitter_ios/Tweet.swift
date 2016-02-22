//
//  Tweet.swift
//  twitter_ios
//
//  Created by Priscilla Lok on 2/19/16.
//  Copyright © 2016 Priscilla Lok. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    var id: Int?
    var id_str: String?
    var user: User?
    var text: String?
    var createdAtString: String?
    var createdAt: NSDate?
    var isRetweeted: Bool?
    var retweetedUser: User?
    var retweetCount: Int?
    var isFavorited: Bool?
    var favoriteCount: Int?
    var isCurrUserRetweeted: Bool?
    var originalTweetId_str: String?
    var retweetId_str: String?
    
    init(dictionary: NSDictionary) {
        id = dictionary["id"] as? Int
        id_str = dictionary["id_str"] as? String
        isRetweeted = dictionary["retweeted_status"] != nil ? true: false
        isFavorited = dictionary["favorited"] as? Bool
        if isRetweeted == true {
            user = User(dictionary: dictionary["retweeted_status"]!["user"] as! NSDictionary)
            retweetedUser = User(dictionary: dictionary["user"] as! NSDictionary)
            favoriteCount = dictionary["retweeted_status"]!["favorite_count"] as? Int
            originalTweetId_str = dictionary["retweeted_status"]!["id_str"] as? String

        } else {
            user = User(dictionary: dictionary["user"] as! NSDictionary)
            retweetedUser = nil
            favoriteCount = dictionary["favorite_count"] as? Int
        }
        
        if dictionary["current_user_retweet"] != nil {
            retweetId_str = dictionary["current_user_retweet"]!["id_str"] as? String
        }
        isCurrUserRetweeted = dictionary["retweeted"] as? Bool
        text = dictionary["text"] as? String
        createdAtString = dictionary["created_at"] as? String

        retweetCount = dictionary["retweet_count"] as? Int
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        createdAt = formatter.dateFromString(createdAtString!)
    }
    
    class func tweetsWithArray(array: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        for dictionary in array {
            tweets.append(Tweet(dictionary: dictionary))
        }
        return tweets
    }
}
