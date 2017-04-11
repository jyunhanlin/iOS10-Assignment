//
//  Popularity.swift
//  Smashtag
//
//  Created by JHLin on 2017/4/9.
//  Copyright © 2017年 Stanford University. All rights reserved.
//

import UIKit
import CoreData
import Twitter

class Popularity: NSManagedObject {
    
    class func addOrCreatePopularityCount(_ keyword: String, matching userMentionInfo: Twitter.Mention , in context: NSManagedObjectContext) throws -> Popularity {
        let request: NSFetchRequest<Popularity> = Popularity.fetchRequest()
        request.predicate = NSPredicate(format: "text =[cd] %@ AND query = %@", userMentionInfo.keyword, keyword)
        //request.predicate = NSPredicate(format: "name = %@", userMentionInfo.keyword)
        
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                assert(matches.count == 1, "Popularity.addOrCreatePopularityCount -- database inconsistency")
                matches[0].count = matches[0].count + 1
                return matches[0]
            }
        } catch {
            throw error
        }
        
        let popularity = Popularity(context: context)
        popularity.query = keyword
        popularity.text = userMentionInfo.keyword
        popularity.count = 1
        return popularity
    }
    
}
