//
//  PlayerView.swift
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

struct PlayerView : View {
  
  typealias ContextState = PlayerViewModel.State
  typealias Event = PlayerViewModel.Event
  
  private let context: Context<ContextState, Event>
  
  init(context: Context<ContextState, Event>) {
    self.context = context
  }
  
  var body: some View {
    VStack {
      HideChevron()
      PodcastImageView()
      PlayPauseHorizontalStack(context: self.context)
      TextHorizontalStack(timeSaved: context.displaySkippedTime)
      BottomActions()
      Spacer()
    }
  }
}

struct HideChevron: View {
  var body: some View {
    HStack{
      Button(action: {}) {
        Image(systemSymbol: .chevronDown)
      }
      .padding()
      Spacer()
    }
  }
}

struct PodcastImageView: View {
  var body: some View {
    RoundedRectangle(cornerRadius: 20)
      .aspectRatio(contentMode: ContentMode.fill)
      .padding(.horizontal, 40)
      .padding(.top, 10)
      .padding(.bottom, 40)
  }
}

struct PlayPauseHorizontalStack: View {
  
  typealias ContextState = PlayerViewModel.State
  typealias Event = PlayerViewModel.Event
  
  private let context: Context<ContextState, Event>
  
  init(context: Context<ContextState, Event>) {
    self.context = context
  }
  
  @State var currentTime: Double = 0.0
  
  var body: some View {
    VStack {
      HStack {
        Button(action: {
        }) {
          Image(systemSymbol: .zzz)
            .font(.title)
        }.padding(.horizontal)
        Spacer()
        Button(action: {
          self.context.send(event: .skip(.goBackward15))
        }) {
          Image(systemSymbol: .gobackward15)
            .font(.title)
        }
        Spacer()
        Button(action: {
          self.context.send(event: .togglePlayPause)
        }) {
          if self.context.playback != .playing {
            Image(systemSymbol: .playCircle)
              .font(.title)
              .scaleEffect(3)
              .scaledToFill()
          } else {
            Image(systemSymbol: .pauseCircle)
              .font(.title)
              .scaleEffect(3)
              .scaledToFill()
          }
        }
        Spacer()
        Button(action: {
          self.context.send(event: .skip(.goForward15))
        }) {
          Image(systemSymbol: .goforward15)
            .font(.title)
          
        }
        Spacer()
        Button(action:{
          self.context.send(event: .toggleSmartSpeed)
        }) {
          Image(systemSymbol: self.context.smartSpeed == .on ? .gaugeBadgePlus : .gaugeBadgeMinus)
            .font(.title)
        }.padding(.horizontal)
      }
      //    context.binding(for: \.currentTime,
      //      event: Event.changePlaybackPosition)
      
      Slider(value: .constant(context.currentTime ?? 0.0),
             from: 0, through: context.duration ?? 0.0)
        .padding([.top, .horizontal], 40)
      
      //      Slider(value: currentTime,
      //             from: 0.0,
      //             through: context.duration ?? 0.0) { didSelect in
      //              self.context.send(event: .changePlaybackPosition(self.currentTime))
      //      }.padding([.top, .horizontal], 40)
      
      HStack {
        Text(context.displayCurrentTime)
          .font(.caption)
          .padding(.horizontal)
        Spacer()
        Text(context.displayDuration)
          .font(.caption)
          .padding(.horizontal)
      }.padding(.horizontal, 10)
    }
  }
}

struct TextHorizontalStack: View {
  
  var timeSaved: String
  
  var body: some View {
    VStack {
      Text("Episode content Goes here")
        .font(.headline)
        .padding(.bottom, 4)
      Text("Podcast Title Goes here")
        .font(.subheadline)
        .padding(.bottom, 4)
      Text("Publication Date")
        .font(.caption)
      HStack {
        Spacer()
        Button(action: {}) {
          HStack(alignment: .lastTextBaseline) {
            Image(systemSymbol: .heart)
            Text("1")
          }
        }.padding()
        Button(action: {}) {
          Image(systemSymbol: .bubbleRight)
        }.padding()
        Button(action: {}) {
          Image(systemSymbol: .paperplane)
        }.padding()
        Spacer()
      }
      Text("Time Saved: " + timeSaved)
        .font(.caption)
      
    }.padding(.bottom)
  }
}

struct BottomActions: View {
  var body: some View {
    return HStack(alignment: .top) {
      Button(action: {
        
      }) {
        Image(systemSymbol: .listDash).font(.headline)
      }
      Spacer()
      Button(action: {
        
      }) {
        Text("Head Phones / Airplay Device")
          .font(.caption)
      }
      Spacer()
      Button(action: {
        
      }) {
        Image(systemSymbol: .squareAndArrowUp).font(.headline)
      }
    }.padding(.horizontal, 30)
  }
}

#if DEBUG
struct PlayerView_Previews : PreviewProvider {
  static var previews: some View {
    Widget(
      viewModel: PlayerViewModel(
        initial: PlayerViewModel.State(
          player: nil,
          playback: .stopped,
          smartSpeed: .off,
          skippedSeconds: 0.0,
          smartSpeedCancelable: nil,
          heartbeatCancelable: nil,
          podcastToPlay: Bundle.main.url(forResource: "atp334",
                                         withExtension: "mp3")!,
          duration: 1000,
          currentTime: 500
        ) // UI Prototyping here
      ),
      render: PlayerView.init
    )
  }
}
#endif
