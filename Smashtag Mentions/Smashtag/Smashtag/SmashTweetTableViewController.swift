//
//  SmashTweetTableViewController.swift
//  Smashtag
//
//  Created by CS193p Instructor on 2/15/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit
import Twitter
import CoreData

class SmashTweetTableViewController: TweetTableViewController
{
    var container: NSPersistentContainer? =
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    override func insertTweets(_ newTweets: [Twitter.Tweet]) {
        super.insertTweets(newTweets)
        updateDatabase(with: newTweets)
        //print(newTweets)
    }
    
    private func updateDatabase(with tweets: [Twitter.Tweet]) {
        print("starting database load")
        container?.performBackgroundTask { [weak self] context in
            for twitterInfo in tweets {
                _ = try? Tweet.findOrCreateTweet((self?.searchText)!, matching: twitterInfo, in: context)
            }
            try? context.save()
            print("done loading database")
            self?.printDatabaseStatistics()
        }
    }
    
    private func printDatabaseStatistics() {
        if let context = container?.viewContext {
            context.perform {
                if Thread.isMainThread {
                    print("on main thread")
                } else {
                    print("off main thread")
                }
                // bad way to count
                let fr: NSFetchRequest<Tweet> = Tweet.fetchRequest()
                if let tweetCount = (try? context.fetch(fr))?.count {
                    print("\(tweetCount) tweets")
                }
                // good way to count
                if let tweeterCount = try? context.count(for: TwitterUser.fetchRequest()) {
                    print("\(tweeterCount) Twitter users")
                }
            }
        }
    }
    
    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "Tweeters Mentioning Search Term":
                if let tweetersTVC = segue.destination as? SmashTweetersTableViewController {
                    tweetersTVC.mention = searchText
                    tweetersTVC.container = container
                }
            case "Show Tweet Mentions" :
                if let tweetMentionsTVC = segue.destination as? TweetMentionsTableViewController {
                    if let cell = sender as? TweetTableViewCell {
                        tweetMentionsTVC.navigationItem.title = cell.tweet?.user.name
                        tweetMentionsTVC.tweet = cell.tweet
                    }
                }
            default:
                break
            }
        }
    }
}
