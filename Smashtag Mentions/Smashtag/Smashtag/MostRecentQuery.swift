//
//  MostRecentQuery.swift
//  Smashtag
//
//  Created by JHLin on 2017/3/24.
//  Copyright © 2017年 Stanford University. All rights reserved.
//

import Foundation

struct MostRecnetQuery {
    private static let defaults = UserDefaults.standard

    static var queries: [String] {
        return defaults.array(forKey: "MostRecnetQueries") as? [String] ?? []
    }
    
    static func add(_ key:String) {
        var queryArray = queries
        queryArray.insert(key, at: 0)
        if queryArray.count > 100 {
            queryArray.removeLast()
        }
        defaults.set(queryArray, forKey: "MostRecnetQueries")
    }

    static func removeQuery(at index:Int) {
        var queryArray = queries
        queryArray.remove(at: index)
        defaults.set(queryArray, forKey: "MostRecnetQueries")
    }
}
