//
//  DataAssets.swift
//  StartupCommander
//
//  Created by Paul Wood on 6/26/19.
//  Copyright © 2019 Paul Wood. All rights reserved.
//

import Foundation
import UIKit

enum DataAssets: String {
  case Podcasts = "Podcasts"
}

extension DataAssets {
  var value: Data {
    switch self {
    case .Podcasts:
      let asset = NSDataAsset(name: "Podcasts", bundle: Bundle.main)
      return asset!.data
    }
  }
}
