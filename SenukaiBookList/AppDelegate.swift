//
//  AppDelegate.swift
//  djweatherisk
//
//  Created by Darius Jankauskas on 17/05/2017.
//  Copyright © 2017 Darius Jankauskas. All rights reserved.
//

import UIKit

func isRunningTests() -> Bool {
    if let _ = NSClassFromString("XCTest") {
        return true
    }
    return false
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)
        if (!isRunningTests()) {
            window?.rootViewController = UINavigationController(rootViewController: HomeViewController())
            window?.makeKeyAndVisible()
        }
        
        return true
    }
}

