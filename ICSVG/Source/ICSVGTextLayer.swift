//
//  TextLayer.swift
//  ICSVG
//
//  Created by Alexander Selling on 2018-12-23.
//  Copyright © 2018 Alexander Selling. All rights reserved.
//

import Foundation
class ICSVGTextLayer: CATextLayer {
    
    override func hitTest(_ p: CGPoint) -> CALayer? {
        return nil
    }
    
    class func textLayer(with rect: CGRect) -> ICSVGTextLayer {
        let textLayer = ICSVGTextLayer()
        
        textLayer.fontSize = 12
        textLayer.frame = rect
        textLayer.alignmentMode = .center
        textLayer.truncationMode = .end
        textLayer.foregroundColor = UIColor.black.cgColor
        
        return textLayer
    }
    
    override func draw(in ctx: CGContext) {
        super.draw(in: ctx)
    }
}
