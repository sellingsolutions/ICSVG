//
//  ICSVGDocument.swift
//  ICSVG
//
//  Created by Alexander Selling on 2018-12-24.
//  Copyright © 2018 Alexander Selling. All rights reserved.
//

import Foundation
import SVGKit

class ICSVGDocument {
    
    var svg: SVGKImage!
    var caLayerTree: CALayer {
        return svg.caLayerTree
    }
    
    init?(with filePath: String?) {
        guard let filePath = filePath else {
            return nil
        }
        
        let naturalFilePath = filePath.replacingOccurrences(of: "file://", with: "")
        
        let svgFileStream = InputStream(fileAtPath: naturalFilePath)
        let svgSourceObject = SVGKSource(inputSteam: svgFileStream)
        
        svg = SVGKImage(source: svgSourceObject)
    }
}
