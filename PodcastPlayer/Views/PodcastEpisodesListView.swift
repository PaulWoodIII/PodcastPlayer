//
//  PodcastEpisodesListView.swift
//  PodcastPlayer
//
//  Created by Paul Wood on 7/13/19.
//  Copyright © 2019 Paul Wood. All rights reserved.
//

import Combine
import CombineFeedback
import CombineFeedbackUI
import SwiftUI
import SFSafeSymbols

struct PodcastEpisodesListView : View {
  
  typealias ContextState = PodcastEpisodesListViewModel.State
  typealias Event = PodcastEpisodesListViewModel.Event
  
  private let context: Context<ContextState, Event>
    
  var body: some View {
    VStack {
      Text(context.podcast?.title ?? "No Title")
      Button(action: context.onDismiss) {
        Text("Button")
      }
    }
    
  }
  
  init(context: Context<ContextState, Event>) {
    self.context = context
  }
  
}

#if DEBUG
struct ListEpisodesView_Previews : PreviewProvider {
  static var previews: some View {
    Widget(
      viewModel: PodcastEpisodesListViewModel(
        initial: PodcastEpisodesListViewModel.State()
      ),
      render: PodcastEpisodesListView.init
    )
  }
}
#endif
