//
//  ViewController.swift
//  ICSVG
//
//  Created by Alexander Selling on 2018-12-20.
//  Copyright © 2018 Alexander Selling. All rights reserved.
//

import UIKit

class ViewController: ICSVGViewController {
    
    private var ifcDS: [String: Any]?
    private var projectName = ""
    private var spaces = [[String: Any]]()
    
    var contentSize = CGSize.zero
    
    @objc
    func rotate() {
        scrollView.rotate(.pi / 4.0)
    }
    
    @objc
    func toggleMove() {
        scrollView.toggleTranslation()
        let bgColor = scrollView.translationEnabled ? UIColor.red : UIColor.clear
        navigationController?.navigationBar.backgroundColor = bgColor
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Rotate 45°",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(rotate))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Move",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(toggleMove))

        loadIFCJSON()
        
        // Crashes unless you specify an id inside of the root tag <svg id=".."
        //let tree = svgDocument.dictionaryOfLayers()
        
        let shapes = findShapes(scrollView.caLayerTree)
        for shape in shapes {
            addTextLayerTo(shape)
        }
        
        contentSize = scrollView.contentView.frame.size
        
    }
    
}
// MARK: - ICSVGViewControllerDelegate
extension ViewController: ICSVGViewControllerDelegate {
    func didTap(on layer: CALayer?, at scrollViewPoint: CGPoint, with svgElementID: String?) {
        
        guard let parentSvgID = layer?.superlayer?.svgElementID else {
            return
        }
        
        let spaceID = parentSvgID.replacingOccurrences(of: "product-", with: "")
        
        guard let space = space(with: spaceID),
            let spaceName = space["RoomTag"] as? String,
            let storyName = space["storyName"] as? String else {
            return
        }
        
        navigationItem.title = "\(storyName) - \(spaceName)"
        
        let detailVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController
        detailVC?.preferredContentSize = CGSize(width: 320, height: 120)
        detailVC?.modalPresentationStyle = .popover
        
        detailVC?.space = space
        
        let contentViewPoint = scrollView.convert(scrollViewPoint, to: scrollView.contentView)
        detailVC?.point = contentViewPoint
        detailVC?.delegate = self
        
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
extension ViewController: DetailViewControllerDelegate {
    
    func didSave(at position: CGPoint, with type: ICSVGAnnotationShapeType) {
        dismiss(animated: true, completion: nil)
        
        addAnnotation(at: position)
    }
    
    func addAnnotation(at point: CGPoint) {
        let frame = CGRect(origin: point, size: CGSize(width: 22, height: 22))
        let annotation = ICSVGCircleAnnotation(frame: frame,
                                               text: "",
                                               contentSize: contentSize)
        
        scrollView.contentView?.addSubview(annotation)
    }
}
// MARK: - LOADING IFC JSON FILE
extension ViewController {
    private func loadIFCJSON() {
        do {
            if let file = Bundle.main.url(forResource: "mikroskopet_sodra", withExtension: "json") {
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let object = json as? [String: Any],
                    let stories = object["Floors"] as? [[String: Any]] {
                    self.ifcDS = object
                    
                    let project = object["Project"] as? [String: Any]
                    projectName = project?["Name"] as? String ?? "<Project Name>"
                    
                    for var story in stories {
                        if let _spaces = story["Spaces"] as? [[String: Any]] {
                            for space in _spaces {
                                var updatedSpace = space
                                updatedSpace["storyName"] = story["Name"]
                                spaces.append(updatedSpace)
                            }
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
}
// MARK: - ADDING SPACE NAMES AS TEXT LAYERS
extension ViewController {
    func findShapes (_ layer: CALayer) -> [CAShapeLayer] {
        var newShapes = [CAShapeLayer]()
        
        if let shape = layer as? CAShapeLayer {
            newShapes.append(shape)
        }
        
        guard let sublayers = layer.sublayers else {
            return newShapes
        }
        
        for sublayer in sublayers {
            let shapes = findShapes(sublayer)
            newShapes.append(contentsOf: shapes)
        }
        
        return newShapes
    }
    
    func addTextLayerTo(_ shape: CAShapeLayer) {
        
        var spaceName = ""
        
        if let svgID = shape.superlayer?.svgElementID {
            let ifcGuid = svgID.replacingOccurrences(of: "product-", with: "")
            if let _space = space(with: ifcGuid), let name = _space["RoomTag"] as? String {
                spaceName = name
            }
        }
        
        shape.addTextLayer(with: spaceName)
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
