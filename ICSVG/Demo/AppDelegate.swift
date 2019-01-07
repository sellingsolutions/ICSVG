//
//  AppDelegate.swift
//  ICSVG
//
//  Created by Alexander Selling on 2018-12-20.
//  Copyright © 2018 Alexander Selling. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let screenBounds = UIScreen.main.bounds
        let filePath = Bundle.main.url(forResource: "mikroskopet_sodra",
                                       withExtension: "svg",
                                       subdirectory: nil)!.absoluteString
        let config = ICSVGViewControllerConfig(selectionStyle: .marchingAnts)
        
        let demoVC = ViewController(frame: screenBounds, filePath: filePath, config: config)
        let demoNC = UINavigationController(rootViewController: demoVC)
        
        window = UIWindow(frame: screenBounds)
        window?.rootViewController = demoNC
        window?.makeKeyAndVisible()
        
        return true
    }
}

