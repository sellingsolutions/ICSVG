//
//  ICSVGCircleAnnotation.swift
//  ICSVG
//
//  Created by Alexander Selling on 2019-01-06.
//  Copyright © 2019 Alexander Selling. All rights reserved.
//

import Foundation

class ICSVGCircleAnnotation: UIView {
    var contentSize: CGSize = CGSize.zero
    var text: String?
    var label: ICSVGTextLayer?
    var circle: ICSVGCircleShape!
    
    init(frame: CGRect, text: String?, contentSize: CGSize) {
        super.init(frame: frame)
        
        self.contentSize = contentSize
        self.text = text
        backgroundColor = UIColor.clear
        
        layer.contentsScale = UIScreen.main.scale
        layer.shouldRasterize = false
        layer.rasterizationScale = 2 * UIScreen.main.scale
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if circle != nil {
            circle.removeFromSuperlayer()
        }
        
        circle = ICSVGCircleShape()
        circle.frame = CGRect(origin: CGPoint.zero, size: frame.size)
        circle.strokeColor = UIColor.red.cgColor
        circle.fillColor = UIColor.red.cgColor
        layer.addSublayer(circle)
        circle.setNeedsDisplay()
        
        label?.removeFromSuperlayer()
        
        let textRect = circle.frame
        label = ICSVGTextLayer.textLayer(with: textRect)
        label?.string = text
        circle.addSublayer(label!)
    }
    
    func resize(zoomScale: CGFloat = 1.0) {
        
        let zoom = max(1.0, zoomScale)
        let inverseZoomScale: CGFloat = 1.0 / zoom
        
        let svgScale: CGFloat = contentSize.height / contentSize.width
        var flippedSvgScale = 1.0 - svgScale
        if flippedSvgScale < 0.2 {
            flippedSvgScale = 0.2
        }
        
        // We know that diameter * diameter * noOfCircles <= pageWidth * pageHeight
        // Therefore the optimal diameter would be diameter = sqrt((pageHeight * pageWidth) / noOfCircles))
        let defaultDiameter = sqrt((contentSize.height * contentSize.width) / 30)
        
        var sizeRef: CGFloat = flippedSvgScale * defaultDiameter * inverseZoomScale
        if sizeRef < 1 {
            sizeRef = 10
        }
        
        let aspectRatio: CGFloat = frame.height / frame.width
        
        let size = CGSize(width: sizeRef, height: sizeRef * aspectRatio)
        
        frame.size = size
        circle.frame.size = size
        label?.frame.size = size
        label?.fontSize = size.width * 0.55
        
        print("zoom \(zoom) size \(size)")
        
        circle.setNeedsDisplay()
        label?.setNeedsDisplay()
        setNeedsDisplay()

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
class ICSVGCircleShape: CAShapeLayer {
    private var bezierPath: UIBezierPath?

    override func draw(in ctx: CGContext) {
        
        UIGraphicsPushContext(ctx)
        
        bezierPath?.removeAllPoints()
        
        bezierPath = UIBezierPath(ovalIn: frame)
        path = bezierPath?.cgPath
        
        UIGraphicsPopContext()
    }
    
}
