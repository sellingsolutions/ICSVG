//
//  ICSVGViewController.swift
//  ICSVG
//
//  Created by Alexander Selling on 2018-12-24.
//  Copyright © 2018 Alexander Selling. All rights reserved.
//

import Foundation
import SVGKit

class ICSVGViewController: UIViewController {
    
    private var selectedLayer: CAShapeLayer?
    
    private var viewFrame = CGRect.zero
    
    var document: ICSVGDocument!
    var scrollView: ICSVGScrollView!
    weak var delegate: ICSVGViewControllerDelegate?
    var config: ICSVGViewControllerConfig!

    convenience init() {
        let bounds = UIScreen.main.bounds
        let frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)

        self.init(frame: frame, filePath: nil, config: ICSVGViewControllerConfig.default)
    }
    
    init(frame: CGRect, filePath: String?, config: ICSVGViewControllerConfig = .default) {
        self.viewFrame = frame
        self.config = config
        
        self.document = ICSVGDocument(with: filePath)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.frame = viewFrame
        self.view.backgroundColor = UIColor.white
        self.scrollView = ICSVGScrollView(frame: viewFrame, document: document)
        self.scrollView.svgDelegate = self
        
        view.addSubview(scrollView)
    }
}
extension ICSVGViewController: ICSVGScrollViewDelegate {
    func didTap(on layer: CALayer?, at scrollViewPoint: CGPoint) {
        // Not all svg elements _have to_ have an ID
        // The backend should however only produce svg files where all elements have id's
        let svgElementID = layer?.value(forKey: kSVGElementIdentifier) as? String
        
        delegate?.didTap(on: layer, at: scrollViewPoint, with: svgElementID)
        
        guard let hitLayer = layer as? CAShapeLayer,
            let selectionStyle = config.selectionStyle else {
            return
        }
        
        addSelectionStyle(selectionStyle, to: hitLayer)
    }
    
    func addSelectionStyle(_ selectionStyle: ICSVGLayerSelectionStyle, to layer: CAShapeLayer) {

        
        selectedLayer?.lineDashPattern = nil
        selectedLayer?.removeAllAnimations()
        
        if layer == selectedLayer {
            selectedLayer = nil
        }
        else {
            selectedLayer = layer
            
            switch selectionStyle {
            case .marchingAnts:
                ICSVGMarchingAntsAnimation.marchOn(shapeLayer: layer)
            default:
                break
            }
        }
    }
}
