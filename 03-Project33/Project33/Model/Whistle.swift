//
//  Whistle.swift
//  Project33
//
//  Created by clarknt on 2020-10-28.
//  Copyright © 2020 clarknt. All rights reserved.
//

import CloudKit
import UIKit

// challenge 2
class Whistle: NSObject, NSCoding {
    var recordID: CKRecord.ID!
    var genre: String!
    var comments: String!
    var audio: URL!

    // challenge 2
    override init() {
        super.init()
    }

    // challenge 2
    required init?(coder: NSCoder) {
        recordID = coder.decodeObject(forKey: "recordID") as? CKRecord.ID ?? CKRecord.ID()
        genre = coder.decodeObject(forKey: "genre") as? String ?? ""
        comments = coder.decodeObject(forKey: "comments") as? String ?? ""
        audio = coder.decodeObject(forKey: "audio") as? URL ?? URL(string: "")
    }

    // challenge 2
    func encode(with coder: NSCoder) {
        coder.encode(recordID, forKey: "recordID")
        coder.encode(genre, forKey: "genre")
        coder.encode(comments, forKey: "comments")
        coder.encode(audio, forKey: "audio")
    }

    // challenge 2
    func testCodingDecoding() {
        Self.testCodingDecoding(whistle: self)
    }

    // challenge 2
    static func testCodingDecoding(whistle: Whistle) {
        if let codedData = try? NSKeyedArchiver.archivedData(withRootObject: whistle, requiringSecureCoding: false) {
            if let decodedData = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(codedData) as? Whistle {
                assert(whistle.recordID == decodedData.recordID)
                assert(whistle.genre == decodedData.genre)
                assert(whistle.comments == decodedData.comments)
                assert(whistle.audio == decodedData.audio)
                print("testCodingDecoding: OK")
                return
            }
        }

        print("testCodingDecoding: KO")
    }

}
