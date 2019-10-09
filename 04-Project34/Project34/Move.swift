//
//  Move.swift
//  Project34
//
//  Created by clarknt on 2019-10-09.
//  Copyright © 2019 clarknt. All rights reserved.
//

import GameplayKit
import UIKit

class Move: NSObject, GKGameModelUpdate {
    var value: Int = 0 // GKGameModelUpdate
    var column: Int

    init(column: Int) {
        self.column = column
    }
}
