//
//  CAShapeLayer+StrokeAnimation.swift
//  ICSVG
//
//  Created by Alexander Selling on 2018-12-28.
//  Copyright © 2018 Alexander Selling. All rights reserved.
//

import Foundation
extension CAShapeLayer {
    func runStrokeAnimation () {
        
        let strokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeAnimation.fromValue = 0
        strokeAnimation.toValue = 1.0
        strokeAnimation.beginTime = 0
        strokeAnimation.duration = 7.5
        strokeAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        strokeAnimation.fillMode = .both
        strokeAnimation.isRemovedOnCompletion = false
        
        add(strokeAnimation, forKey: "ICSVGStrokeAnimation")
    }
}
