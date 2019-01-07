//
//  CAShapeLayer+PathWidth.swift
//  ICSVG
//
//  Created by Alexander Selling on 2019-01-04.
//  Copyright © 2019 Alexander Selling. All rights reserved.
//

import Foundation

extension CAShapeLayer {
    
    func layerWidth(at line: (a: CGPoint, b: CGPoint)) -> (CGFloat, CGPoint, CGPoint)? {

        guard let intersections = self.intersections(with: line), intersections.count >= 2 else {
            return nil
        }
        
        // The two first intersections will most probably make up the drawable area for the text
        let p1 = intersections[0]
        let p2 = intersections[1]
        // The horizontal distance between the two first intersections will be the text width
        // We might want to consider the case where we have more than 2 intersections..
        // If there's 3 or more intersections then there might be a better place to put the text
        let width = abs(p1.x - p2.x)
        
        return ( width, p1, p2 )
    }
    
    func intersections(with line: (a: CGPoint, b: CGPoint)) -> [CGPoint]? {
        guard let path = path else {
            return nil
        }
        
        let points = path.getPathElementsPoints()
        
        var prevPoint: CGPoint? = nil
        var intersections = [CGPoint]()
        
        for point in points {
            if let previousPoint = prevPoint {
                let layerLine = (previousPoint, point)
                // Any intersections between the middle line and the layer path will be stored
                if let intersectsAtPoint = intersectionBetweenLines(line1: layerLine, line2: line) {
                    intersections.append(intersectsAtPoint)
                }
            }
            prevPoint = point
        }
        
        return intersections
    }
    
    func intersectionBetweenLines(line1: (a: CGPoint, b: CGPoint),
                                  line2: (a: CGPoint, b: CGPoint)) -> CGPoint? {
        
        let distance = (line1.b.x - line1.a.x) *
            (line2.b.y - line2.a.y) -
            (line1.b.y - line1.a.y) *
            (line2.b.x - line2.a.x)
        if distance == 0 {
            print("no intersection, parallel lines")
            return nil
        }
        
        let u = ((line2.a.x - line1.a.x) *
            (line2.b.y - line2.a.y) -
            (line2.a.y - line1.a.y) *
            (line2.b.x - line2.a.x)) / distance
        
        let v = ((line2.a.x - line1.a.x) *
            (line1.b.y - line1.a.y) -
            (line2.a.y - line1.a.y) *
            (line1.b.x - line1.a.x)) / distance
        
        if (u < 0.0 || u > 1.0) {
            print("intersection not inside line1")
            return nil
        }
        if (v < 0.0 || v > 1.0) {
            print("intersection not inside line2")
            return nil
        }
        
        return CGPoint(x: line1.a.x + u * (line1.b.x - line1.a.x),
                       y: line1.a.y + u * (line1.b.y - line1.a.y))
    }
}
