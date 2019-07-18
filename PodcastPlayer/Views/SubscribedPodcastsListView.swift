//
//  ListUserPodcastsView.swift
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

struct SubscribedPodcastsListView : View {
  
  typealias ContextState = SubscribedPodcastsListViewModel.State
  typealias Event = SubscribedPodcastsListViewModel.Event
  typealias ThisContext = Context<ContextState, Event>
  
  private let context: Context<ContextState, Event>
  
  let link: DynamicNavigationDestinationLink<Podcast, Podcast, AnyView>
  
  
  init(context: Context<ContextState, Event>) {
    self.context = context
    self.link = context.flow.podcastEpisodeNavigationLink
  }
  
  var body: some View {
    VStack {
      if context.loading != .loaded {
        Text( String(describing: context.loading))
      }
      List {
        ForEach(context.podcasts) { podcast in
          Button(action: {
            self.context.send(event:
              .shouldPresentDetail(podcast,
                                   self.link.presentedData)
            )
          }) {
            Text(podcast.title ?? "")
          }
        }
      }
    }.navigationBarTitle("Podcasts")
    .navigationBarItems(trailing: SubscribedPodcastsListBarButtonsView())
  }
}

#if DEBUG
struct SubscribedPodcastsListViewModel_Previews : PreviewProvider {
  static var previews: some View {
    NavigationView {
      Widget(
        viewModel: SubscribedPodcastsListViewModel(
          initial: SubscribedPodcastsListViewModel.State()
        ),
        render: SubscribedPodcastsListView.init
      )
    }
  }
}
#endif
