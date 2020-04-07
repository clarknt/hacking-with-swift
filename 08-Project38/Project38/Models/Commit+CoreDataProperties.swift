//
//  Commit+CoreDataProperties.swift
//  Project38
//
//  Created by clarknt on 2020-04-07.
//  Copyright © 2020 clarknt. All rights reserved.
//
//

import Foundation
import CoreData


extension Commit {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Commit> {
        return NSFetchRequest<Commit>(entityName: "Commit")
    }

    @NSManaged public var date: Date
    @NSManaged public var message: String
    @NSManaged public var sha: String
    @NSManaged public var url: String
    @NSManaged public var creationDate: Double
    @NSManaged public var author: Author

}
