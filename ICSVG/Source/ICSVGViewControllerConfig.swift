//
//  ICSVGViewControllerConfig.swift
//  ICSVG
//
//  Created by Alexander Selling on 2018-12-28.
//  Copyright © 2018 Alexander Selling. All rights reserved.
//

import Foundation
struct ICSVGViewControllerConfig {
    static let `default`: ICSVGViewControllerConfig = ICSVGViewControllerConfig(selectionStyle: .marchingAnts)
    let selectionStyle: ICSVGLayerSelectionStyle?
}
