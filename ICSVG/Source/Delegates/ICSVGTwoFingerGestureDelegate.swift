//
//  ICSVGTwoFingerGestureDelegate.swift
//  ICSVG
//
//  Created by Alexander Selling on 2019-01-05.
//  Copyright © 2019 Alexander Selling. All rights reserved.
//

import Foundation
protocol ICSVGTwoFingerGestureDelegate: class {
    func translationDetected(translatedBy translation: CGPoint,
                             previousPosition: CGPoint,
                             currentPosition: CGPoint)
}
