//
//  PopularityTableViewController.swift
//  Smashtag
//
//  Created by JHLin on 2017/4/7.
//  Copyright © 2017年 Stanford University. All rights reserved.
//

import UIKit
import CoreData

class PopularityTableViewController: FetchedResultsTableViewController
{
    var mention: String? { didSet { updateUI() } }
    
    var container: NSPersistentContainer? =
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
        { didSet { updateUI() } }
    
    var fetchedResultsController: NSFetchedResultsController<Popularity>?
    
    private func updateUI() {
        if let context = container?.viewContext, mention != nil {
            let request: NSFetchRequest<Popularity> = Popularity.fetchRequest()
            
            //request.predicate = NSPredicate(format: "count > %@ AND query =[cd] %@", 1, mention!)
            request.predicate = NSPredicate(format: "query contains[c] %@ and count > %@", mention!, NSNumber(value: 1))
            let sortDescriptor1 = NSSortDescriptor(
                key: "count",
                ascending: false
            )
            let sortDescriptor2 = NSSortDescriptor(
                key: "text",
                ascending: true,
                selector: #selector(NSString.localizedStandardCompare(_:))
            )
            
            request.sortDescriptors = [sortDescriptor1, sortDescriptor2]
            
            fetchedResultsController = NSFetchedResultsController<Popularity>(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            fetchedResultsController?.delegate = self
            try? fetchedResultsController?.performFetch()
            tableView.reloadData()
        }
    }
   
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Popularity Cell", for: indexPath)
        
        // Configure the cell...
        if let mention = fetchedResultsController?.object(at: indexPath) {
            cell.textLabel?.text = mention.text
            cell.detailTextLabel?.text = "tweets.count: " + String(mention.count)
        }
        

        return cell
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
            return sections[section].name
        } else {
            return nil
        }
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return fetchedResultsController?.sectionIndexTitles
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return fetchedResultsController?.section(forSectionIndexTitle: title, at: index) ?? 0
    }


}
