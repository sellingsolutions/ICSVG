//
//  ViewController.swift
//  ICSVG
//
//  Created by Alexander Selling on 2018-12-20.
//  Copyright © 2018 Alexander Selling. All rights reserved.
//

import UIKit
import SVGKit

class ViewController: UIViewController {
    
    private var ifcDS: [String: Any]?
    private var spaces = [[String: Any]]()
    
    @IBOutlet var scrollView: UIScrollView!
    
    private var svgDocument: SVGKImage!
    private var contentView: SVGKLayeredImageView!
    private var gestureRecognizer: UITapGestureRecognizer!
    
    private var lastTappedLayer: CALayer?
    private var lastTappedLayerOriginalBorderWidth: CGFloat = 0.0
    
    private var lastTappedLayerOriginalBorderColor: CGColor?
    private var textLayerForLastTappedLayer: CATextLayer?
    
    
    private func loadIFCJSON() {
        do {
            if let file = Bundle.main.url(forResource: "mikroskapet_sodra", withExtension: "json") {
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let object = json as? [String: Any],
                    let stories = object["Floors"] as? [[String: Any]] {
                    self.ifcDS = object
                    
                    for var story in stories {
                        if let _spaces = story["Spaces"] as? [[String: Any]] {
                            spaces.append(contentsOf: _spaces)
                            // ifcGlobalId
                            //print(_spaces.first?["AltExternalId"] as? String ?? "")
                        }
                    }

                }
            } else {
                print("no file")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        
        loadIFCJSON()
        
        let svg = SVGKSourceLocalFile.internalSourceAnywhere(in: Bundle.main, usingName: "mikroskapet_sodra.svg")
        self.svgDocument = SVGKImage(source: svg)
        self.contentView = SVGKLayeredImageView(svgkImage: svgDocument)
        self.scrollView.addSubview(contentView)
        self.scrollView.contentSize = contentView.frame.size
        
        let screenToDocumentSizeRatio = self.scrollView.frame.size.width / self.contentView.frame.size.width
        
        self.scrollView.minimumZoomScale = min( 1, screenToDocumentSizeRatio )
        self.scrollView.maximumZoomScale = max( 2, screenToDocumentSizeRatio )
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        gestureRecognizer.cancelsTouchesInView = false
        gestureRecognizer.numberOfTapsRequired = 1
        
        self.contentView.addGestureRecognizer(gestureRecognizer)
       
        // Crashes unless you specify an id inside of the root tag <svg id=".."
        //let tree = svgDocument.dictionaryOfLayers()
       
    }

    @objc func handleTap(_ gesture: UIGestureRecognizer) {
        
        let tappedAtPoint = gesture.location(in: self.contentView)
        let convertedPoint = contentView.convert(tappedAtPoint, to: scrollView)
        
        let hitTestingLayer = contentView?.layer
        let hitLayer = hitTestingLayer?.hitTest(convertedPoint)
        
        var layerID = hitLayer?.superlayer?.value(forKey: "SVGElementIdentifier") as? String
        layerID = layerID?.replacingOccurrences(of: "product-", with: "")

        if (hitLayer == lastTappedLayer) {
            deselectLayer()
        }
        else {
            deselectLayer()
        }
        
        lastTappedLayer = hitLayer
        guard let _ = lastTappedLayer else {
            return
        }
        
        lastTappedLayerOriginalBorderColor = lastTappedLayer?.borderColor
        lastTappedLayerOriginalBorderWidth = lastTappedLayer?.borderWidth ?? 1.0
        
        lastTappedLayer?.borderColor = UIColor.green.cgColor
        lastTappedLayer?.borderWidth = 3.0
        
        
        let layerTreeRoot = svgDocument.caLayerTree
        printLayers(layer: layerTreeRoot!)
        
        var matchingSpace: [String: Any]?
        for space in spaces {
            if let ifcGlobalID = space["AltExternalId"] as? String, ifcGlobalID == layerID {
                matchingSpace = space
                break
            }
        }
        
        let detailVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController
        detailVC?.preferredContentSize = CGSize(width: 320, height: 120)
        detailVC?.modalPresentationStyle = .popover

        detailVC?.space = matchingSpace

        let ppc = detailVC?.popoverPresentationController
        
        ppc?.permittedArrowDirections = .any
        //ppc?.delegate = self
        ppc?.sourceRect = CGRect(x: convertedPoint.x,
                                 y: convertedPoint.y,
                                 width: 0,
                                 height: 0)
        ppc?.sourceView = contentView

        present(detailVC!, animated: true, completion: nil)
        
    }
    
    func printLayers (layer: CALayer) {
        if let sublayers = layer.sublayers {
            for sub in sublayers {
                //print(sub.value(forKey: "SVGElementIdentifier"))
                printLayers(layer: sub)
            }
        }
    }
    
    func deselectLayer() {
        guard let _ = lastTappedLayer else {
            return
        }
        
        self.lastTappedLayer?.borderWidth = lastTappedLayerOriginalBorderWidth;
        self.lastTappedLayer?.borderColor = lastTappedLayerOriginalBorderColor;
        
        self.textLayerForLastTappedLayer?.removeFromSuperlayer()
        self.textLayerForLastTappedLayer = nil
        
        self.lastTappedLayer = nil

    }
}
extension ViewController : UIScrollViewDelegate {
 
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        let finalScale = scale * UIScreen.main.scale
        
        let newActions = [kCAOnOrderIn: NSNull(),
                          kCAOnOrderOut: NSNull(),
                          "sublayers": NSNull(),
                          "contents": NSNull(),
                          "bounds": NSNull()]
        
        guard let layerImageView = self.view as? SVGKLayeredImageView,
            let layer = layerImageView.image.caLayerTree else {
            return
        }
        
        
        CATransaction.begin()
        CATransaction.disableActions()
        
        setActions(newActions, newScale: finalScale, onTextSublayersOf: layer)
        
        CATransaction.commit()
    }
    
    func setActions(_ actions: [String: Any], newScale scale: CGFloat, onTextSublayersOf layer: CALayer) {
        
        if layer is CATextLayer {
            layer.actions = actions as? [String: CAAction]
            layer.contentsScale = scale
        }
        
        guard let sublayers = layer.sublayers else {
            return
        }
        
        for sublayer in sublayers {
            setActions(actions, newScale: scale, onTextSublayersOf: sublayer)
        }
    }
}

