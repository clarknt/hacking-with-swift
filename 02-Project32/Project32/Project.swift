//
//  Project.swift
//  Project32
//
//  Created by clarknt on 2019-10-02.
//  Copyright © 2019 clarknt. All rights reserved.
//

import Foundation

// challenge 1
class Project: NSObject, Codable {
    var title: String
    var subtitle: String

    init(title: String, subtitle: String) {
        self.title = title
        self.subtitle = subtitle
    }
}
