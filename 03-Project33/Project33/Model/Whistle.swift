//
//  Whistle.swift
//  Project33
//
//  Created by clarknt on 2020-10-28.
//  Copyright © 2020 clarknt. All rights reserved.
//

import CloudKit
import UIKit

class Whistle: NSObject {
    var recordID: CKRecord.ID!
    var genre: String!
    var comments: String!
    var audio: URL!
}
