//
//  Flow.swift
//  PodcastPlayer
//
//  Created by Paul Wood on 7/14/19.
//  Copyright © 2019 Paul Wood. All rights reserved.
//

import Combine
import CombineFeedback
import CombineFeedbackUI
import SwiftUI

enum Destinations: Hashable {
  case subscribedPodcastList
  case podcastEpisodesList(_: Podcast)
}

class Flow {
  
  static let shared: Flow = Flow()
  
  static func subscribedPodcastView() -> AnyView {
    Widget(
      viewModel: SubscribedPodcastsListViewModel(
        initial: SubscribedPodcastsListViewModel.State()
      ),
      render: SubscribedPodcastsListView.init
    ).typeErased
  }
  
  static func playerView() -> AnyView {
    Widget(
      viewModel: PlayerViewModel(
        initial: PlayerViewModel.State()
      ),
      render: PlayerView.init
    ).typeErased
  }
  
  // Helper function to consistantly build a PodcastEpisodesListView
  static func podcastEpisodes(forPodcast podcast: Podcast) -> AnyView {
    let w = Widget(
      viewModel: PodcastEpisodesListViewModel(
        initial: PodcastEpisodesListViewModel.State(podcast: podcast)
      ),
      render: PodcastEpisodesListView.init
    )
    return w.typeErased
  }
  
  // returns a DynamicNavigationDestinationLink to a PodcastEpisodesListView
  var podcastEpisodeNavigationLink: DynamicNavigationDestinationLink<Podcast, Podcast, AnyView> {
    return DynamicNavigationDestinationLink<Podcast, Podcast, AnyView>(id: \Podcast.self) { podcast in
      return Flow.podcastEpisodes(forPodcast: podcast)
    }
  }
}
