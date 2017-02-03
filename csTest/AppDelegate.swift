//
//  AppDelegate.swift
//  csTest
//
//  Created by Denis Kudinov on 27/01/2017.
//  Copyright © 2017 Denis Kudinov. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    window = UIWindow(frame: UIScreen.main.bounds)
    guard let window = window else {
      print("Window is nil.")
      return false
    }
    let rootController = ViewController(frame: window.frame)
    window.rootViewController = rootController
    window.makeKeyAndVisible()
    return true
  }
  
}

