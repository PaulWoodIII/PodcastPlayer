//
//  SubscribedPodcastsListBarButtonsView.swift
//  PodcastPlayer
//
//  Created by Paul Wood on 7/15/19.
//  Copyright © 2019 Paul Wood. All rights reserved.
//

import SwiftUI
import SFSafeSymbols
struct SubscribedPodcastsListBarButtonsView : View {
    var body: some View {
      PresentationLink2(destination: Flow.playerView()) {
        Image(systemSymbol: .playCircleFill)
      }
    }
}

#if DEBUG
struct SubscribedPodcastsListBarButtonsView_Previews : PreviewProvider {
    static var previews: some View {
        SubscribedPodcastsListBarButtonsView()
    }
}
#endif
