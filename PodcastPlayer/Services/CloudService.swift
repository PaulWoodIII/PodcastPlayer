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
    return self.publisher(for: \.podcasts).eraseToAnyPublisher()
  }

  func fetchStoredPodcasts() -> AnyPublisher<PodcastList, Error>  {

    return Future<PodcastList, Error>() { promise in
      DispatchQueue.global(qos: .background).async {
        // Background Thread
        let data = DataAssets.Podcasts.value
        do {
          let rootObj = try JSONDecoder()
            .decode(PodcastList.self, from: data)
          
          DispatchQueue.main.async {
            // Run UI Updates
            self.podcasts = rootObj
            promise(.success(rootObj))
          }
        } catch {
          // TODO Log and handle Errors
          print(error)
          DispatchQueue.main.async {
            promise(.failure(NSError()))
          }
        }
      }
    }.eraseToAnyPublisher()
  }
  
  func tryToFetchStoredPodcasts() -> AnyPublisher<Void, Error>  {
    
    return Future<Void, Error>() { promise in
      DispatchQueue.global(qos: .background).async {
        // Background Thread
        let data = DataAssets.Podcasts.value
        do {
          let rootObj = try JSONDecoder()
            .decode(PodcastList.self, from: data)
          
          DispatchQueue.main.async {
            // Run UI Updates
            self.podcasts = rootObj
            promise(.success(()))
          }
        } catch {
          // TODO Log and handle Errors
          print(error)
          DispatchQueue.main.async {
            promise(.failure(NSError()))
          }
        }
      }
    }.eraseToAnyPublisher()
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
