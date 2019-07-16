//
//  PodcastEpisodesListViewModel.swift
//  PodcastPlayer
//
//  Created by Paul Wood on 7/14/19.
//  Copyright © 2019 Paul Wood. All rights reserved.
//

import Foundation
import CombineFeedback
import CombineFeedbackUI
import SwiftUI

class PodcastEpisodesListViewModel: ViewModel<PodcastEpisodesListViewModel.State,
PodcastEpisodesListViewModel.Event>  {
  
  struct State: Builder {
    var podcast: Podcast?
    var episodes: [Episode] = []
    var loading: Loading = .initial
    var onDismiss: () -> Void = {  }
  }
  
  enum Loading {
    case initial
    case loading
    case loaded
    case loadFailed
  }
  
  enum Event {
    case update(_ : [Episode])
    case loading(_: Loading)
  }
  
  init(initial: State = State()) {
    super.init(
      initial: initial,
      feedbacks: [
        
      ],
      scheduler: RunLoop.main,
      reducer: PodcastEpisodesListViewModel.reduce
    )
  }
  
  private static func reduce(state: State, event: Event) -> State {
    switch event {
    case .loading(let newLoadingValue):
      return state.set(\.loading, newLoadingValue)
    case .update(let episodes):
      return state.set(\.episodes, episodes)
    }
  }
  
}


struct Episode {
  
}
