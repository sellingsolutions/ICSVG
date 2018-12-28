//
//  ICSVGViewControllerDelegate.swift
//  ICSVG
//
//  Created by Alexander Selling on 2018-12-24.
//  Copyright © 2018 Alexander Selling. All rights reserved.
//

import Foundation
protocol ICSVGViewControllerDelegate: class {
    /// Returns meta data for the tapped area
    /// - Parameters:
    ///   - layer: The tapped `CALayer`
    ///   - scrollViewPoint: The tapped `CGPoint` in ICSVGScrollView coordinates
    ///   - svgElementID: The id of the SVG Element that the tapped `CALayer` represents
    func didTap(on layer: CALayer?, at scrollViewPoint: CGPoint, with svgElementID: String?)
}
