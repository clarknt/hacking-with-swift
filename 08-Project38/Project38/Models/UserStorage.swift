//
//  NewestCommitDate.swift
//  Project38
//
//  Created by clarknt on 2020-04-03.
//  Copyright © 2020 clarknt. All rights reserved.
//

import Foundation

// challenge 3

struct UserStorage {
    static let newestCommitDateKey = "newestCommitDate"

    var newestCommitDate: Date {
        set {
            let userDefaults = UserDefaults.standard
            userDefaults.set(newValue, forKey: Self.newestCommitDateKey)
        }

        get {
            var storedDate: Date

            let userDefaults = UserDefaults.standard
            if let date = userDefaults.object(forKey: Self.newestCommitDateKey) as? Date {
                storedDate = date
            }
            else {
                storedDate = Date(timeIntervalSince1970: 0)
            }

            return storedDate
        }
    }

}
