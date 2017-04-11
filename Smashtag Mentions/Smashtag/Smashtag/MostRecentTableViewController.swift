//
//  MostRecentTableViewController.swift
//  Smashtag
//
//  Created by JHLin on 2017/3/23.
//  Copyright © 2017年 Stanford University. All rights reserved.
//

import UIKit

class MostRecentTableViewController: UITableViewController
{
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return MostRecnetQuery.queries.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Most Rencety Hashtags", for: indexPath)

        cell.textLabel?.text = MostRecnetQuery.queries[indexPath.row]

        return cell
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            MostRecnetQuery.removeQuery(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "Show Smash Tweet":
                if let smashTweetTVC = segue.destination as? SmashTweetTableViewController {
                    if let cell = sender as? UITableViewCell {
                        let text = cell.textLabel?.text
                        smashTweetTVC.searchText = text
                    }
                }
            case "Show Popularity":
                if let populartyTVC = segue.destination as? PopularityTableViewController {
                    if let cell = sender as? UITableViewCell , let text = cell.textLabel?.text {
                        populartyTVC.mention = text
                    }
                }         
            default:
                break
            }

        }
    }

}
