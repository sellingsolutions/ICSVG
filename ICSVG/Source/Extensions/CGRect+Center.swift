//
//  CGRect+Center.swift
//  ICSVG
//
//  Created by Alexander Selling on 2019-01-07.
//  Copyright © 2019 Alexander Selling. All rights reserved.
//

import Foundation
extension CGRect {
    var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
}
