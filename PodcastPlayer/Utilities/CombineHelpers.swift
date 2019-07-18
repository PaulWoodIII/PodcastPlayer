//
//  CombineHelpers.swift
//  PodcastPlayer
//
//  Created by Paul Wood on 7/13/19.
//  Copyright © 2019 Paul Wood. All rights reserved.
//

import Combine

extension Publisher {
  public func replaceError(
    replace: @escaping (Failure) -> Self.Output
    ) -> AnyPublisher<Self.Output, Never> {
    return `catch` { error in
      Just(replace(error))
    }.eraseToAnyPublisher()
  }
  
  public func ignoreError() -> AnyPublisher<Output, Never> {
    return `catch` { _ in
      Empty()
    }.eraseToAnyPublisher()
  }
}


extension Publisher where Failure == Never {
  func promoteError<E: Error>(to: E.Type) -> Publishers.MapError<Self, E> {
    return self.mapError { _ -> E in }
  }
}
