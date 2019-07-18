//
//  ImageService.swift
//  PodcastPlayer
//
//  Created by Paul Wood on 7/13/19.
//  Copyright © 2019 Paul Wood. All rights reserved.
//

import SwiftUI
import Combine
import CombineFeedback

/// https://github.com/sergdort/CombineFeedback/blob/master/Example/Views/AsyncImage.swift
/// Renamed this from ImageHandler to ImageService because I like the word Service more than Handler
class ImageService {
  private let cache = NSCache<NSURL, UIImage>()
  
  func image(for url: URL) -> AnyPublisher<UIImage, Never> {
    return Deferred { () -> AnyPublisher<UIImage, Never> in
      if let image = self.cache.object(forKey: url as NSURL) {
        return Just(image)
          .receive(on: DispatchQueue.main)
          .eraseToAnyPublisher()
      }
      
      return URLSession.shared
        .dataTaskPublisher(for: url)
        .map { $0.data }
        .compactMap(UIImage.init(data:))
        .receive(on: DispatchQueue.main)
        .handleEvents(receiveOutput: { image in
          self.cache.setObject(image, forKey: url as NSURL)
        })
        .ignoreError()
    }
    .eraseToAnyPublisher()
  }
}

struct ImageServiceKey: EnvironmentKey {
  typealias Value = ImageService
  
  static let defaultValue: ImageService = ImageService()
}

extension EnvironmentValues {
  var imageService: ImageService {
    get {
      return self[ImageServiceKey.self]
    }
    set {
      self[ImageServiceKey.self] = newValue
    }
  }
}
