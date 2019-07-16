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
      Publishers.Once(replace(error))
    }.eraseToAnyPublisher()
  }
  
  public func ignoreError() -> AnyPublisher<Output, Never> {
    return `catch` { _ in
      Publishers.Empty()
    }.eraseToAnyPublisher()
  }
}


extension Publisher where Failure == Never {
  func promoteError<E: Error>(to: E.Type) -> Publishers.MapError<Self, E> {
    return self.mapError { _ -> E in }
  }
}
