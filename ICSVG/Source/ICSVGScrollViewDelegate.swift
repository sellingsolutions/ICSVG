//
//  ICSVGScrollViewDelegate.swift
//  ICSVG
//
//  Created by Alexander Selling on 2018-12-24.
//  Copyright © 2018 Alexander Selling. All rights reserved.
//

protocol ICSVGScrollViewDelegate: class {
    /// Returns the selected layer and the touch point in ICSVGScrollView coordinates
    /// - Parameters:
    ///   - layer: The tapped `CALayer`
    ///   - scrollViewPoint: The tapped `CGPoint` in ICSVGScrollView coordinates
    func didTap(on layer: CALayer?, at scrollViewPoint: CGPoint)
}
