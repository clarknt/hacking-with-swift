//
//  ChipView.swift
//  Project34
//
//  Created by clarknt on 2019-10-09.
//  Copyright © 2019 clarknt. All rights reserved.
//

import UIKit

// challenge 3
class ChipView: UIImageView {
    var color: UIColor

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(color: UIColor) {
        self.color = color

        super.init(frame: CGRect())

        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))

        let image = renderer.image { ctx in
            drawChipOuterDisc(color: color, ctx: ctx)
            drawChipInnerDisc(color: color, ctx: ctx)
            drawChipInnerCircles(color: color, ctx: ctx)
            drawChipOuterDecorations(color: color, ctx: ctx)
        }

        self.image = image
    }

    func drawChipOuterDisc(color: UIColor, ctx: UIGraphicsImageRendererContext) {
        let rectangle = CGRect(x: 0, y: 0, width: 512, height: 512).insetBy(dx: 5, dy: 5)
        ctx.cgContext.setFillColor(color.darkerColor().cgColor)
        ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
        ctx.cgContext.setLineWidth(10)
        ctx.cgContext.addEllipse(in: rectangle)
        ctx.cgContext.drawPath(using: .fillStroke)
    }

    func drawChipInnerDisc(color: UIColor, ctx: UIGraphicsImageRendererContext) {
        let rectangle = CGRect(x: 64, y: 64, width: 384, height: 384).insetBy(dx: 5, dy: 5)
        ctx.cgContext.setFillColor(color.cgColor)
        ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
        ctx.cgContext.setLineWidth(10)
        ctx.cgContext.addEllipse(in: rectangle)
        ctx.cgContext.drawPath(using: .fillStroke)
    }

    func drawChipInnerCircles(color: UIColor, ctx: UIGraphicsImageRendererContext) {
        ctx.cgContext.setStrokeColor(color.darkerColor().cgColor)
        ctx.cgContext.setLineWidth(10)

        let innerStroke1 = CGRect(x: 96, y: 96, width: 320, height: 320).insetBy(dx: 5, dy: 5)
        ctx.cgContext.addEllipse(in: innerStroke1)
        ctx.cgContext.drawPath(using: .stroke)

        let innerStroke2 = CGRect(x: 128, y: 128, width: 256, height: 256).insetBy(dx: 5, dy: 5)
        ctx.cgContext.addEllipse(in: innerStroke2)
        ctx.cgContext.drawPath(using: .stroke)
    }

    func drawChipOuterDecorations(color: UIColor, ctx: UIGraphicsImageRendererContext) {
        let radius: CGFloat = 200
        let points = 20
        let centerX = radius * cos(.pi * 2 / CGFloat(points))
        let centerY = radius * sin(.pi * 2 / CGFloat(points))

        ctx.cgContext.setFillColor(color.cgColor)
        ctx.cgContext.translateBy(x: 256, y: 256)

        for _ in 1...points {
            let rectangle = CGRect(x: centerX, y: centerY, width: 30, height: 30)

            ctx.cgContext.addEllipse(in: rectangle)
            ctx.cgContext.drawPath(using: .fill)
            ctx.cgContext.rotate(by: -(.pi * 2 / CGFloat(points)))
        }
    }

}
