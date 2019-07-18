//
//  CloudService.swift
//  PodcastPlayer
//
//  Created by Paul Wood on 7/13/19.
//  Copyright © 2019 Paul Wood. All rights reserved.
//

import Foundation
import Combine
import XMLParsing
import SwiftyXMLParser

protocol CloudServiceType: NSObjectProtocol {
  func podcastsPublisher() -> AnyPublisher<PodcastList, Never>
  func fetchStoredPodcasts() -> AnyPublisher<PodcastList, Error>
  func tryToFetchStoredPodcasts() -> AnyPublisher<Void, Error>
}

final class CloudService: NSObject, CloudServiceType {
  
  static let shared = CloudService()
  
  @objc dynamic var podcasts: PodcastList = PodcastList(podcasts: [])
  
  func podcastsPublisher() -> AnyPublisher<PodcastList, Never> {
    return self.publisher(for: \.podcasts)
      .eraseToAnyPublisher()
  }
  
  func fetchStoredPodcasts() -> AnyPublisher<PodcastList, Error>  {
    
    return Deferred { () -> AnyPublisher<PodcastList, Error> in
      
      if self.podcasts.podcasts.count > 0 {
        return Just(self.podcasts)
          .setFailureType(to: Error.self)
          .subscribe(on: DispatchQueue.main)
          .eraseToAnyPublisher()
      }
      
      let decoder =  Future<PodcastList, Error>() { promise in
        let data = DataAssets.Podcasts.value
        do {
          let rootObj = try JSONDecoder()
            .decode(PodcastList.self, from: data)
          self.podcasts = rootObj
          promise(.success(rootObj))
        } catch {
          promise(.failure(NSError()))
        }
      }
      
      return Just(())
        .setFailureType(to: Error.self)
        .flatMap{ _ in decoder }
        .eraseToAnyPublisher()
    }.eraseToAnyPublisher()
  }
  
  func tryToFetchStoredPodcasts() -> AnyPublisher<Void, Error>  {
    self.fetchStoredPodcasts()
      .map({ _ in })//.mapToVoid
      .subscribe(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }
  
}


/// Wrapper  for the JSON object that contains the list of Podcasts
/// I'm using this to potentially have other bits of data in that one file
final class PodcastList: NSObject, Codable {
  @objc dynamic var podcasts: [PodcastManagedObject]
  
  init(podcasts: [PodcastManagedObject]) {
    self.podcasts = podcasts
  }
}

// TODO Make this into a Code Data Object but this will do for now
final class PodcastManagedObject: NSObject, Codable {
  @objc dynamic var type: String?
  @objc dynamic var overcastId: String?
  @objc dynamic var text: String?
  @objc dynamic var title: String?
  @objc dynamic var xmlUrl: String?
  @objc dynamic var htmlUrl: String?
}
