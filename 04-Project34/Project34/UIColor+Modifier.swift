//
//  UIColor+Modifier.swift
//  Project34
//
//  Created by clarknt on 2019-10-09.
//  Copyright © 2019 clarknt. All rights reserved.
//

import UIKit

// challenge 3
extension UIColor {

    func darkerColor() -> UIColor {
        return modifyBightness(multiplier: 0.85)
    }

    func lighterColor() -> UIColor {
        return modifyBightness(multiplier: 1.15)
    }

    private func modifyBightness(multiplier: CGFloat) -> UIColor {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        guard getHue(&h, saturation: &s, brightness: &b, alpha: &a) else { return self }

        return UIColor(hue: h, saturation: s, brightness: b * multiplier, alpha: a)
    }
}
