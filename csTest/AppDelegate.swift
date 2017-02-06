//
//  AppDelegate.swift
//  csTest
//
//  Created by Denis Kudinov on 27/01/2017.
//  Copyright © 2017 Denis Kudinov. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    setupRealm()
    window = UIWindow(frame: UIScreen.main.bounds)
    guard let window = window else {
      print("Window is nil.")
      return false
    }
    let mainVC = ViewController(frame: window.frame)
    let nc = UINavigationController(rootViewController: mainVC)
    nc.isNavigationBarHidden = true
    let rootController = nc
    window.rootViewController = rootController
    window.makeKeyAndVisible()
    return true
  }
    
    func setupRealm() {
        Realm.configureSharedStorageAsDefault()
    }
  
}

