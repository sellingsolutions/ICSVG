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
    private var contentView: SVGKLayeredImageView!
    var caLayerTree: CALayer {
        return contentView.image.caLayerTree
    }
    
    private var tapRecognizer: UITapGestureRecognizer!
    
    weak var svgDelegate: ICSVGScrollViewDelegate?
    
    private let kDisableAnimations: [String: CAAction] = [kCAOnOrderIn: NSNull(),
                                                          kCAOnOrderOut: NSNull(),
                                                          "sublayers": NSNull(),
                                                          "contents": NSNull(),
                                                          "bounds": NSNull()]
    // MARK: - INITIALIZATION
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(frame: CGRect, document: ICSVGDocument) {
        super.init(frame: frame)

        self.contentView = SVGKLayeredImageView(svgkImage: document.svg)
        
        setupScrollView(self, with: frame, using: contentView)
        
        self.tapRecognizer = createTapGestureRecognizer()
        
        contentView.addGestureRecognizer(tapRecognizer)
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
// MARK: - SCROLL VIEW SETUP
extension ICSVGScrollView {
    private func setupScrollView(_ scrollView: UIScrollView, with frame: CGRect, using contentView: SVGKLayeredImageView) {
        
        scrollView.addSubview(contentView)
        scrollView.contentSize = contentView.frame.size
        scrollView.delegate = self
        
        let screenToDocumentSizeRatio = frame.size.width / contentView.frame.size.width
        
        scrollView.minimumZoomScale = min( 1, screenToDocumentSizeRatio )
        scrollView.maximumZoomScale = max( 2, screenToDocumentSizeRatio )
    }
    
    private func createTapGestureRecognizer() -> UITapGestureRecognizer {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        tapGesture.cancelsTouchesInView = false
        tapGesture.numberOfTapsRequired = 1
        return tapGesture
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
