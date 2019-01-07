//
//  CAShapeLayer+Rotation.swift
//  ICSVG
//
//  Created by Alexander Selling on 2019-01-06.
//  Copyright © 2019 Alexander Selling. All rights reserved.
//

import Foundation

extension CAShapeLayer {
    var rotation: CGFloat {
        guard let path = path else {
            return 0
        }
        
        let points = path.getPathElementsPoints()
        var remains = points
        
        var topLeft = CGPoint.zero
        var bottomLeft = CGPoint.zero
        
        // 1. the point closest to the top, i.e. minimum Y
        // 2.
        if let _topLeft = points.min(by: { (p1, p2) -> Bool in
            return p1.y < p2.y
        }) {
            let topLeftStr = String(format: "(%.3f, %.3f)", _topLeft.x,_topLeft.y)
            
            remains.removeAll { p -> Bool in
                let bottomLeftStr = String(format: "(%.3f, %.3f)", p.x,p.y)
                let isTopLeft = bottomLeftStr.compare(topLeftStr) == .orderedSame
                return isTopLeft
            }
            
            if let _bottomLeft = remains.min(by: { (p1, p2) -> Bool in
                // minimum X, max Y
                return p1.x < p2.x
            }) {
                topLeft = _topLeft
                bottomLeft = _bottomLeft
            }
        }
        
        let radians = self.getAngle(fromPoint: topLeft, toPoint: bottomLeft)
        let degrees = radians * ( 180 / .pi )
        print("degrees \(degrees)")
        
        return radians
    }
    
    private func getAngle(fromPoint: CGPoint, toPoint: CGPoint) -> CGFloat {
        let dx: CGFloat = fromPoint.x - toPoint.x
        let dy: CGFloat = fromPoint.y - toPoint.y
        // atan2 returns [ -180 to +180 ]
        let angleRadians = atan2(dy, dx)
        // add 180 to get us back to [ 0 to 360 ]
        let radians: CGFloat = angleRadians + .pi
        return radians
    }
}
