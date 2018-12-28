//
//  ViewController.swift
//  ICSVG
//
//  Created by Alexander Selling on 2018-12-20.
//  Copyright © 2018 Alexander Selling. All rights reserved.
//

import UIKit


/*
 
 Cool stuff:
 1. marching ants effect using lineDashPhase ✅
 2. aligning the space name TextLayers with the layer path
 3. adding the project, site, building and story names as a header
 4. some how detect the rotation of the svg, the rooms will only be rectangles.. the angle between the scrollview and the layer cgpath should be 0
 5.
 */

class ViewController: ICSVGViewController {
    
    private var ifcDS: [String: Any]?
    private var spaces = [[String: Any]]()
    
    private var lastTappedLayer: CALayer?

    
    
    private func loadIFCJSON() {
        do {
            if let file = Bundle.main.url(forResource: "mikroskopet_sodra", withExtension: "json") {
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
        
        // Crashes unless you specify an id inside of the root tag <svg id=".."
        //let tree = svgDocument.dictionaryOfLayers()
        
        decorateLayer(scrollView.caLayerTree)
        
    }
    
    func decorateLayer(_ layer: CALayer) {
        guard let sublayers = layer.sublayers else {
            return
        }
        
        if let svgID = layer.value(forKey: kSVGElementIdentifier) as? String {
            let ifcGuid = svgID.replacingOccurrences(of: "product-", with: "")
            if let _space = space(with: ifcGuid), let name = _space["RoomTag"] as? String {
                let superlayerWidth = layer.frame.size.width
                
                let text = ICSVGTextLayer()
                text.string = name
                text.fontSize = 16
                text.frame = CGRect(x: 0,
                                    y: layer.frame.size.height / 2,
                                    width: superlayerWidth,
                                    height: 44)

                text.alignmentMode = CATextLayerAlignmentMode.center;
                text.foregroundColor = UIColor.black.cgColor
                

                layer.addSublayer(text)
            }
        }
        
        for sublayer in sublayers {
            decorateLayer(sublayer)
        }
    }
    
    func space(with id: String?) -> [String: Any]? {
        var matchingSpace: [String: Any]?
        for space in spaces {
            if let ifcGlobalID = space["AltExternalId"] as? String, ifcGlobalID == id {
                matchingSpace = space
                break
            }
        }
        return matchingSpace
    }
    
}
extension ViewController: ICSVGViewControllerDelegate {
    func didTap(on layer: CALayer?, at scrollViewPoint: CGPoint, with svgElementID: String?) {
        
        let parentSvgID = layer?.superlayer?.value(forKey: kSVGElementIdentifier) as? String
        let spaceID = parentSvgID?.replacingOccurrences(of: "product-", with: "")
        
        
        guard let space = space(with: spaceID) else {
            return
        }
        
        let detailVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController
        detailVC?.preferredContentSize = CGSize(width: 320, height: 120)
        detailVC?.modalPresentationStyle = .popover
        
        detailVC?.space = space
        
        let ppc = detailVC?.popoverPresentationController
        
        ppc?.permittedArrowDirections = .any
        //ppc?.delegate = self
        ppc?.sourceRect = CGRect(x: scrollViewPoint.x,
                                 y: scrollViewPoint.y,
                                 width: 0,
                                 height: 0)
        ppc?.sourceView = scrollView
        
        present(detailVC!, animated: true, completion: nil)
    }
}
