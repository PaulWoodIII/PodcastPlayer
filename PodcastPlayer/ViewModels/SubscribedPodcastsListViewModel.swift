//
//  SubscribedPodcastsListViewModel.swift
//  PodcastPlayer
//
//  Created by Paul Wood on 7/13/19.
//  Copyright © 2019 Paul Wood. All rights reserved.
//

import Combine
import CombineFeedback
import CombineFeedbackUI
import SwiftUI

final class SubscribedPodcastsListViewModel :
ViewModel<SubscribedPodcastsListViewModel.State, SubscribedPodcastsListViewModel.Event> {
  
  struct State: Builder {
    var flow: Flow = Flow.shared
    var podcasts: [Podcast] = []
    var loading: Loading = .initial
    var presentedPodcast: Podcast?
  }
  
  enum Loading {
    case initial
    case loading
    case loaded
    case loadFailed
  }
  
  enum Event {
    case change(_ : [Podcast])
    case loading(_: Loading)
    case shouldPresentDetail(_: Podcast, _: Binding<Podcast?>?)
    case shouldDismissDetail
  }
  
  private static func monitor(cloudService: CloudServiceType) -> Feedback<State, Event> {
    return Feedback(effects: { _ in
      cloudService.podcastsPublisher()
        .dropFirst()
        .removeDuplicates()
        .map({ (pmo: PodcastList) -> [Podcast] in
          return pmo.podcasts.compactMap { obj -> Podcast? in
            return obj.asPodcast
          }
        }).map({ podcast in
          Event.change(podcast)
        })
    })
  }
  
  private static func whenLoading(cloudService: CloudServiceType) -> Feedback<State, Event> {
    return Feedback(effects: { state -> AnyPublisher<Event, Never> in
      
      switch state.loading {
      case .initial:
        return cloudService
          .tryToFetchStoredPodcasts()
          .map{ podcasts in
            return Event.loading(.loaded)
          }.replaceError(with: Event.loading(.loadFailed))
          .eraseToAnyPublisher()
        
      case .loading, .loaded, .loadFailed:
        return Publishers.Empty().eraseToAnyPublisher()
      }
    })
  }
  
  init(initial: State = State()) {
    super.init(
      initial: initial,
      feedbacks: [
        SubscribedPodcastsListViewModel.monitor(cloudService: CloudService.shared),
        SubscribedPodcastsListViewModel.whenLoading(cloudService: CloudService.shared),
      ],
      scheduler: RunLoop.main,
      reducer: SubscribedPodcastsListViewModel.reduce
    )
  }
  
  private static func reduce(state: State, event: Event) -> State {
    switch event {
    case .loading(let newLoadingValue):
      return state.set(\.loading, newLoadingValue)
    case .change(let podcast):
      return state.set(\.podcasts, podcast)
    case .shouldPresentDetail(let podcast, let binding):
      binding?.value = podcast
      return state.set(\.presentedPodcast, podcast)
    case .shouldDismissDetail:
      return state.set(\.presentedPodcast, nil)
    }
  }
  
}

/// Pure Data representation of a Podcast without Episode information included
struct Podcast: Identifiable, Hashable {
  var id: String {
    return overcastId
  }
  var type: String?
  var overcastId: String
  var text: String?
  var title: String?
  var xmlUrl: String?
  var htmlUrl: String?
}

extension PodcastManagedObject: Identifiable {
  var asPodcast: Podcast? {
    guard let overcastId = self.overcastId else { return nil }
    return Podcast(
      type: self.type,
      // Shouldn't happen but hey lets kill Core Data optionality somewhere
      overcastId: overcastId,
      text: self.text,
      title: self.title,
      xmlUrl: self.xmlUrl,
      htmlUrl: self.htmlUrl
    )
  }
}
