//
//  SceneDelegate.swift
//  PodcastPlayer
//
//  Created by Paul Wood on 7/13/19.
//  Copyright © 2019 Paul Wood. All rights reserved.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?
  
  func scene(_ scene: UIScene,
             willConnectTo session: UISceneSession,
             options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = scene as? UIWindowScene else {
      return
    }
    let window = UIWindow(windowScene: windowScene)
    let navigation = UIHostingController(rootView: RootNavigationView())
    window.rootViewController = navigation
    self.window = window
    window.makeKeyAndVisible()
  }
}
