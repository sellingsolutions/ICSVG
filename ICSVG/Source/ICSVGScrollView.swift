//
//  ICSVGScrollView.swift
//  ICSVG
//
//  Created by Alexander Selling on 2018-12-23.
//  Copyright © 2018 Alexander Selling. All rights reserved.
//

import Foundation
import SVGKit

class ICSVGScrollView: UIScrollView {
    
    // MARK: - PROPS
    var contentView: SVGKLayeredImageView!
    var caLayerTree: CALayer {
        return contentView.image.caLayerTree
    }
    
    weak var svgDelegate: ICSVGScrollViewDelegate?
    
    private let kDisableAnimations: [String: CAAction] = [kCAOnOrderIn: NSNull(),
                                                          kCAOnOrderOut: NSNull(),
                                                          "sublayers": NSNull(),
                                                          "contents": NSNull(),
                                                          "bounds": NSNull()]
    private var features = [String: Any]()
    
    // MARK: - INITIALIZATION
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(frame: CGRect, document: ICSVGDocument) {
        super.init(frame: frame)

        self.contentView = SVGKLayeredImageView(svgkImage: document.svg)
        
        setupScrollView(self, with: frame, using: contentView)
        
        let tapGesture = createTapGestureRecognizer()
        let twoFingerGesture = createTwoFingerGestureRecognizer()
        
        contentView.addGestureRecognizer(tapGesture)
        contentView.addGestureRecognizer(twoFingerGesture)
    }
    
    // MARK: - HIT DETECTION
    @objc
    private func handleTap(_ tap: UITapGestureRecognizer) {
        let contentViewPoint = tap.location(in: contentView)
        let scrollViewPoint = contentView.convert(contentViewPoint, to: self)
        
        let contentLayer = contentView?.layer
        let tappedLayer = contentLayer?.hitTest(scrollViewPoint)
        
        svgDelegate?.didTap(on: tappedLayer, at: scrollViewPoint)
    }
}
// MARK: - SCROLL VIEW FEATURES
extension ICSVGScrollView {
    
    // Rotates the root layer 'caLayerTree' by a given amount of radians
    func rotate(_ radians: CGFloat) {
        let transform = caLayerTree.transform
        
        let rotation = CATransform3DRotate(transform, radians, 0, 0, 1)
        caLayerTree.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        caLayerTree.transform = rotation
    }
    
    // Disabling the scrollView.panGestureRecognizer by setting canCancelContentTouches = false
    var panGestureEnabled: Bool {
        get {
            return canCancelContentTouches
        }
        set {
            canCancelContentTouches = newValue
        }
    }
    
    // When translation is enabled the user will be able to move the layer 'caLayerTree' by holding down 2 fingers and dragging
    var translationEnabled: Bool {
        get {
            if let _translationEnabled = features["translationEnabled"] as? Bool {
                return _translationEnabled
            }
            return false
        }
        set {
            features["translationEnabled"] = newValue
        }
    }
    
    // Toggles translation mode on/off which in turn disables/enables the pan gesture recognizer
    func toggleTranslation () {
        translationEnabled = !translationEnabled
        panGestureEnabled = !translationEnabled
    }
}
// MARK: - SCROLL VIEW SETUP
extension ICSVGScrollView {
    private func setupScrollView(_ scrollView: UIScrollView,
                                 with frame: CGRect,
                                 using contentView: SVGKLayeredImageView) {
        
        scrollView.addSubview(contentView)
        scrollView.contentSize = contentView.frame.size
        scrollView.delegate = self
        
        let screenToDocumentSizeRatio = frame.size.width / contentView.frame.size.width
        
        scrollView.minimumZoomScale = min( 1, screenToDocumentSizeRatio )
        scrollView.maximumZoomScale = max( 8, screenToDocumentSizeRatio )
    }
    
    private func createTapGestureRecognizer() -> UITapGestureRecognizer {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        tapGesture.cancelsTouchesInView = false
        tapGesture.numberOfTapsRequired = 1
        return tapGesture
    }
    private func createTwoFingerGestureRecognizer() -> ICSVGTwoFingerGesture {
        let gesture = ICSVGTwoFingerGesture(delegate: self, layer: caLayerTree)
        return gesture
    }
}
// MARK: - ICSVGTwoFingerGestureDelegate
extension ICSVGScrollView: ICSVGTwoFingerGestureDelegate {
    func translationDetected(translatedBy translation: CGPoint,
                             previousPosition: CGPoint,
                             currentPosition: CGPoint) {
        
        guard !translation.equalTo(CGPoint.zero) && translationEnabled else {
            return
        }
        
        let transform = caLayerTree.transform
        caLayerTree.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        caLayerTree.transform = CATransform3DTranslate(transform, translation.x, translation.y, 1)
    }
}
// MARK: - SCROLL VIEW DELEGATE
extension ICSVGScrollView: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        /** Very important! The "finalScale" parameter to this method is SLIGHTLY DIFFERENT from the scale that Apple reports in the other delegate methods
         
         This is very confusing, clearly it's bit of a hack - the other methods get called
         at slightly the wrong time, and so their data is slightly wrong (out-by-one animation step).
         
         ONLY the values passed as params to this method are correct!
         */
        let newScale = scale * UIScreen.main.scale
        
        // Update the scale on all text elements in the layer tree
        guard let _contentView = view as? SVGKLayeredImageView,
            let contentLayerTreeRoot = _contentView.image.caLayerTree else {
            return
        }
        
        CATransaction.begin()
        CATransaction.disableActions()
        
        disableTextLayerAnimations(in: contentLayerTreeRoot, andUpdateToScale: newScale)
        
        CATransaction.commit()
    }
    
    func disableTextLayerAnimations(in layer: CALayer, andUpdateToScale newScale: CGFloat) {
        
        if layer is CATextLayer {
            layer.actions = kDisableAnimations
            layer.contentsScale = newScale
        }
        
        guard let sublayers = layer.sublayers else {
            return
        }
        
        for sublayer in sublayers {
            disableTextLayerAnimations(in: sublayer, andUpdateToScale: newScale)
        }
    }
}
