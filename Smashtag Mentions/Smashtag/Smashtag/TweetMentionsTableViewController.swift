//
//  TweetMentionsTableViewController.swift
//  Smashtag
//
//  Created by JHLin on 2017/3/23.
//  Copyright © 2017年 Stanford University. All rights reserved.
//

import UIKit
import Twitter

class TweetMentionsTableViewController: UITableViewController
{

    var tweet: Twitter.Tweet? { didSet { updateUI() } }
    
    private var tweetMentions = [TweetMentions]()
    
    private struct TweetMentions {
        var title: String
        var mentions: [TweetContents]
    }
    
    private enum TweetContents {
        case keyword(String)
        case image(URL, Double)
    }

    
    private func updateUI() {
        
        if let media = tweet?.media, !media.isEmpty {
            tweetMentions.append(TweetMentions(title: "Images", mentions: media.map{TweetContents.image($0.url, $0.aspectRatio)}))
        }
        
        if let hashtags = tweet?.hashtags, !hashtags.isEmpty {
            tweetMentions.append(TweetMentions(title: "Hashtags", mentions: hashtags.map{TweetContents.keyword($0.keyword)}))
        }
        
        if let users = tweet?.user {
            tweetMentions.append(TweetMentions(title: "Users", mentions: [TweetContents.keyword(users.screenName)]))
        }
        
        if let urls = tweet?.urls, !urls.isEmpty {
            tweetMentions.append(TweetMentions(title: "Urls", mentions: urls.map{TweetContents.keyword($0.keyword)}))
        }
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return tweetMentions.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tweetMentions[section].mentions.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tweetMention = tweetMentions[indexPath.section].mentions[indexPath.row]
        switch tweetMention {
        case .keyword(let keyword) :
            let cell = tableView.dequeueReusableCell(withIdentifier: "Tweet Title", for: indexPath)
            cell.textLabel?.text = keyword
            return cell
        case .image (let url, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: "Tweet Image", for: indexPath)
            if let tmitvc = cell as? TweetMentionsImageTableViewCell {
                tmitvc.url = url
            }
            return cell
        }
    }
    

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tweetMentions[section].title
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let tweetMention = tweetMentions[indexPath.section].mentions[indexPath.row]
        switch tweetMention {
        case .image(_, let ratio):
            return tableView.bounds.size.width / CGFloat(ratio)
        default:
            return UITableViewAutomaticDimension
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier{
            switch identifier {
            case "Show Keyword" :
                if let smashTweetTVC = segue.destination as? SmashTweetTableViewController {
                    if let cell = sender as? UITableViewCell {
                        let text = cell.textLabel?.text
                        smashTweetTVC.searchText = text
                    }
                }
                
            case "Show Mention Image" :
                if let ivc = segue.destination as? ImageViewController {
                    if let cell = sender as? TweetMentionsImageTableViewCell {
                        let url = cell.url
                        ivc.imageURL = url
                    }
                }
                
            default:
                break
            }
        }
        
    }
    
    
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "Show Keyword" {
            if let cell = sender as? UITableViewCell {
                let indexPath =  tableView.indexPath(for: cell)
                let url = cell.textLabel?.text
                if tweetMentions[(indexPath?.section)!].title == "Urls" {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(URL(string:url!)!)
                    }
                    return false

                }
            }
        }
        
        return true
    }
    

}
