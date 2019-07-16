//
//  PlayerViewModel.swift
//  PodcastPlayer
//
//  Created by Paul Wood on 7/15/19.
//  Copyright © 2019 Paul Wood. All rights reserved.
//

import Foundation
import Combine
import CombineFeedback
import CombineFeedbackUI
import SwiftUI
import AVFoundation


final class PlayerViewModel: ViewModel<PlayerViewModel.State, PlayerViewModel.Event> {
  
  struct State: Builder {
    var player: AVAudioPlayer?
    var playerDelegate: AVAudioPlayerDelegate?
    var playback: PlaybackState = .stopped
    var smartSpeed: SmartSpeed = .off
    var skippedSeconds: TimeSaved = 0.0
    var smartSpeedCancelable: Cancellable?
    var heartbeatCancelable: Cancellable?
    var podcastToPlay: URL? = Bundle.main.url(forResource: "SwiftCommunityPodcast-Episode1", withExtension: "mp3")!
    
    private static let formatter: DateComponentsFormatter = {
      let formatter = DateComponentsFormatter()
      formatter.allowedUnits = [.hour, .minute, .second]
      formatter.unitsStyle = .abbreviated
      return formatter
    }()
    
    /// Time in seconds that the current selected audio file will use to play
    var duration: Double? = 0.0
    var displayDuration: String {
      return State.formatter.string(from: duration ?? 0) ?? "0m 0s"
    }
    
    var currentTime: TimeInterval? = 0.0
    var displayCurrentTime: String {
      return State.formatter.string(from: (currentTime ?? 0)) ?? "0m 0s"
    }
    
    var displaySkippedTime: String {
      return State.formatter.string(from: (skippedSeconds.value)) ?? "0m 0s"
    }
  }
  
  /// Enternal to this Class so we keep it related and Namespaced
  /// I need an NSObject and a reference type
  class AVAudioPlayerDelegateFacade: NSObject, AVAudioPlayerDelegate {
    
    let subject = PassthroughSubject<Event, Never>()
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
      subject.send(PlayerViewModel.Event.audioPlayerDidFinishPlaying(player: player, successfully: flag))
    }
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
      subject.send(PlayerViewModel.Event.audioPlayerDecodeErrorDidOccur(player, error: error))
    }
  }
  
  /// Enternal to this Class so we keep it related and Namespaced
  /// I need a reference type so this can be updated outside of the reducer, but the heartbeat can be used to
  /// make sure the user sees it
  /// TODO: I can research pass by reference a Pointer to a Double.
  /// But at niave first though that breaks some Value vs Reference Schemantics
  /// that is also 100% premature optimization at this point
  class TimeSaved: ExpressibleByFloatLiteral {
    var value: TimeInterval = 0.0
    required init(floatLiteral value: TimeInterval) {
      self.value = TimeInterval(value)
    }
  }
  
  enum PlaybackState {
    case playing
    case paused
    case stopped
  }

  enum SmartSpeed {
    case on
    case off
  }
  
  enum Skip: Double {
    case goForward15 = 15
    case goBackward15 = -15
  }
  
  enum Event {
    case togglePlayPause
    case player(_: AVAudioPlayer)
    case playerDelegate(_ :AVAudioPlayerDelegate)
    case changeSmartSpeedCancelable(_: Cancellable?)
    case toggleSmartSpeed
    case savedMoreTime(_: Double)
    case skip(_:Skip)
    case changePlaybackPosition(_: TimeInterval)
    case heartBeat(currentTime: TimeInterval)
    case audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully: Bool)
    case audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?)
  }
  
  struct Config {
    static let decibelThreshold = Float(-35)
    static let defaultPlaybackRate = Float(1)
    static let sampleRate: TimeInterval = 1/20
    static let heartBeatInterval = 1.0/2.0
  }
  
  init(initial: State = State()) {
    super.init(
      initial: initial,
      feedbacks: [
        PlayerViewModel.initializePlayer(),
        PlayerViewModel.createHeartbeat(),
        PlayerViewModel.monitorPlayPause(),
      ],
      scheduler: RunLoop.main,
      reducer: PlayerViewModel.reduce
    )
  }
  
  private static func reduce(state: State, event: Event) -> State {
    switch event {
      
    case .togglePlayPause:
      return state.set(\.playback, state.playback == .playing ? .paused : .playing)
    
    case .toggleSmartSpeed:
      var newState = state.set(\.smartSpeed, state.smartSpeed == .on ? .off : .on)
      if newState.smartSpeedCancelable != nil {
        newState.smartSpeedCancelable?.cancel()
        newState = newState.set(\.smartSpeedCancelable, nil)
      } else {
        let newTimer = startSmartSpeedTimer(state: newState)
        newState = newState.set(\.smartSpeedCancelable, newTimer)
      }
      return newState
      
    case .player(let newAVPlayer):
      let current = state.set(\.duration, newAVPlayer.duration)
      return current.set(\.player, newAVPlayer)
      
    case .playerDelegate(let delegate):
      return state.set(\.playerDelegate, delegate)
      
    case .changeSmartSpeedCancelable(let newSmartSpeedCancelable):
      return state.set(\.smartSpeedCancelable, newSmartSpeedCancelable)
      
    case .changePlaybackPosition(let position):
      state.player?.currentTime = position
      return state.set(\.currentTime, position)
      
    case .skip(let skip):
      let newPos = (state.player?.currentTime ?? 0.0) + skip.rawValue
      state.player?.currentTime = newPos
      return state.set(\.currentTime, newPos)
      
    case .heartBeat(let currentTime):
      return state.set(\.currentTime, currentTime)
      
    case .savedMoreTime(let time):
      let newValue = TimeSaved(floatLiteral: state.skippedSeconds.value + time)
      return state.set(\.skippedSeconds, newValue)
      
    case .audioPlayerDidFinishPlaying(_, _):
      return state
      
    case .audioPlayerDecodeErrorDidOccur(_, _):
      return state
    }
  }
  
  private static func initializePlayer() -> Feedback<State, Event> {
    return Feedback(predicate:{ state in
      return state.player == nil
    }, effects: { state -> AnyPublisher<Event, Never> in
      let player = try! AVAudioPlayer(contentsOf: state.podcastToPlay!)
      player.isMeteringEnabled = true
      player.enableRate = true
      let delegate = AVAudioPlayerDelegateFacade()
      player.delegate = delegate
      return delegate.subject
        .prepend([.player(player),.playerDelegate(delegate)])
        .eraseToAnyPublisher()
    })
  }
  
  private static func createHeartbeat() -> Feedback<State, Event> {
    return Feedback(predicate:{ state in
      return state.player != nil
    },  effects: { state -> AnyPublisher<Event, Never> in
      
      Timer.publish(every: Config.heartBeatInterval,
                    on: .main,
                    in: .default)
        .autoconnect()
        .map { (firedate: Date) -> Event in
          return .heartBeat(currentTime: state.player?.currentTime ?? 0.0)
      }.eraseToAnyPublisher()
    })
  }
  
  private static func monitorPlayPause() -> Feedback<State, Event> {
    return Feedback(effects: { state -> AnyPublisher<Event, Never> in
      switch state.playback {
      case .playing:
        state.player?.play()
      case .paused:
        state.player?.pause()
      case .stopped:
        state.player?.stop()
      }
      return Publishers.Empty().eraseToAnyPublisher()
    })
  }
  
  static func startSmartSpeedTimer(state: State) -> Cancellable {

    let cancellable =
      Timer.publish(every: Config.sampleRate,
                    on: .main,
                    in: .default)
        .autoconnect()
        .compactMap({ fireDate in
          guard let player = state.player,
            player.isPlaying == true else {
              state.player?.rate = Config.defaultPlaybackRate
              return
          }
          player.updateMeters()
          let averagePower = player.averagePower(forChannel: 0)
          if averagePower < Config.decibelThreshold {
            player.rate = Config.defaultPlaybackRate
          } else {
            player.rate = 3
          }
        }).makeConnectable().connect()

    return cancellable
  }
}
