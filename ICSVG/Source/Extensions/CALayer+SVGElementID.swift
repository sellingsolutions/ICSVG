//
//  CALayer+SVGElementID.swift
//  ICSVG
//
//  Created by Alexander Selling on 2018-12-29.
//  Copyright © 2018 Alexander Selling. All rights reserved.
//

import Foundation

extension CALayer {
    var svgElementID: String? {
        return value(forKey: kSVGElementIdentifier) as? String
    }
}
