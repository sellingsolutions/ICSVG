//
//  ICSVGMoveGesture.swift
//  ICSVG
//
//  Created by Alexander Selling on 2019-01-05.
//  Copyright © 2019 Alexander Selling. All rights reserved.
//

import Foundation

class ICSVGTwoFingerGesture: UIGestureRecognizer, UIGestureRecognizerDelegate {
    
    private weak var twoFingerDelegate: ICSVGTwoFingerGestureDelegate!
    // The content layer which isn't the same thing as the scrollView.contentView.layer
    // The content layer is equal to the scrollView.caLayerTree
    private var layer: CALayer!
    
    private var lastLocation: CGPoint?
    
    convenience init(delegate: ICSVGTwoFingerGestureDelegate, layer: CALayer) {
        self.init()
        self.twoFingerDelegate = delegate
        self.layer = layer
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        if let touch = touches.first, touches.count == 2 {
            // The view position is the position in the scrollView.contentView
            let viewPos = touch.location(in: view)
            // The layer position is the position in the scrollView.caLayerTree
            guard let layerPos = view?.layer.convert(viewPos, to: layer) else {
                return
            }
            
            if let previousLocation = lastLocation {
                let translation = CGPoint(x: layerPos.x - previousLocation.x,
                                          y: layerPos.y - previousLocation.y)
                
                twoFingerDelegate?.translationDetected(translatedBy: translation,
                                                       previousPosition: previousLocation,
                                                       currentPosition: layerPos)
            }
            
            lastLocation = layerPos
        }
    }
    
    override func reset() {
        if self.state == .possible {
            self.state = .failed
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        if touches.count == 2 {
            self.reset()
        } else {
            self.state = .possible
        }
    }
}
