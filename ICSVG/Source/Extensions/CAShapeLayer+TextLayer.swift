//
//  CAShapeLayer+TextLayer.swift
//  ICSVG
//
//  Created by Alexander Selling on 2019-01-05.
//  Copyright © 2019 Alexander Selling. All rights reserved.
//

import Foundation

extension CAShapeLayer {
    
    func addTextLayer(with text: String?) {
        // A line that cuts across the middle of the bounding rect of the layer
        let middleLine = (CGPoint(x: frame.minX, y: frame.midY),
                          CGPoint(x: frame.maxX, y: frame.midY))
        
        guard let ( width, p1, p2 ) = layerWidth(at: middleLine) else {
            return
        }
        
        // The left most intersection is where the text will have its origin
        let leftPoint = [p1, p2].min { (p1, p2) -> Bool in p1.x < p2.x }
        // Add 10% of the layer width as padding on the left side of the text layer
        let textOriginX = (leftPoint?.x ?? 0) + (width * 0.1)
        // Subtract 20% of the layer width to make room for the left and right padding
        let textLayerWidth = width * 0.80
        
        let textLayer = ICSVGTextLayer()
        
        textLayer.string = text
        textLayer.fontSize = 14
        
        textLayer.frame = CGRect(x: textOriginX,
                            y: p1.y,
                            width: textLayerWidth,
                            height: 44)
        
        textLayer.alignmentMode = .center
        textLayer.truncationMode = .end
        textLayer.foregroundColor = UIColor.black.cgColor
        
        addSublayer(textLayer)
    }
}
