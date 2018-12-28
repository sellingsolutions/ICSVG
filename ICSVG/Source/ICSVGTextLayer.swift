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
}
