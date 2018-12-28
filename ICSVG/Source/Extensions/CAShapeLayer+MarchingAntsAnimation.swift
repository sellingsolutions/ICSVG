//
//  CAShapeLayer+MarchingAntsAnimation.swift
//  ICSVG
//
//  Created by Alexander Selling on 2018-12-28.
//  Copyright © 2018 Alexander Selling. All rights reserved.
//

import Foundation


private let kLineDashPhase           = "lineDashPhase"
private let kDashPattern: [NSNumber] = [8, 6]

extension CAShapeLayer {
    
    /// Adds a Marching Ants animation to a given shape layer
    func runMarchingAntsAnimation () {
        
        lineDashPattern = kDashPattern
        
        let animation = CABasicAnimation(keyPath: kLineDashPhase)
        animation.fromValue = 0
        // Subtracts each number in the dash pattern array from the next value, e.g. 0 - 8 - 6 = -14
        animation.toValue = lineDashPattern?.reduce(0, { (result, nextValue) -> Int in
            result - nextValue.intValue
        })
        
        animation.duration = 1
        animation.repeatCount = .infinity
        
        add(animation, forKey: "ICSVGMarchingAnts")
    }
}
