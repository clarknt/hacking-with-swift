//
//  Author+CoreDataProperties.swift
//  Project38
//
//  Created by clarknt on 2020-04-06.
//  Copyright © 2020 clarknt. All rights reserved.
//
//

import Foundation
import CoreData


extension Author {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Author> {
        return NSFetchRequest<Author>(entityName: "Author")
    }

    @NSManaged public var email: String
    @NSManaged public var name: String
    @NSManaged public var commits: NSOrderedSet

}

// MARK: Generated accessors for commits
extension Author {

    @objc(insertObject:inCommitsAtIndex:)
    @NSManaged public func insertIntoCommits(_ value: Commit, at idx: Int)

    @objc(removeObjectFromCommitsAtIndex:)
    @NSManaged public func removeFromCommits(at idx: Int)

    @objc(insertCommits:atIndexes:)
    @NSManaged public func insertIntoCommits(_ values: [Commit], at indexes: NSIndexSet)

    @objc(removeCommitsAtIndexes:)
    @NSManaged public func removeFromCommits(at indexes: NSIndexSet)

    @objc(replaceObjectInCommitsAtIndex:withObject:)
    @NSManaged public func replaceCommits(at idx: Int, with value: Commit)

    @objc(replaceCommitsAtIndexes:withCommits:)
    @NSManaged public func replaceCommits(at indexes: NSIndexSet, with values: [Commit])

    @objc(addCommitsObject:)
    @NSManaged public func addToCommits(_ value: Commit)

    @objc(removeCommitsObject:)
    @NSManaged public func removeFromCommits(_ value: Commit)

    @objc(addCommits:)
    @NSManaged public func addToCommits(_ values: NSOrderedSet)

    @objc(removeCommits:)
    @NSManaged public func removeFromCommits(_ values: NSOrderedSet)

}
