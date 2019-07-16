//
//  RootNavigationView.swift
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

struct RootNavigationView : View {
  
  var body: some View {
    NavigationView {
      Flow.subscribedPodcastView()
    }   
  }
}

#if DEBUG
struct RootNavigationView_Previews : PreviewProvider {
  static var previews: some View {
    RootNavigationView()
  }
}
#endif
