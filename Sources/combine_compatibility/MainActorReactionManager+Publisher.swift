//
//  MainActorReactionManager+Publisher.swift
//
//
//  Created by Jeremy Bannister on 7/9/24.
//

///
extension MainActorReactionManager: Publisher {
    
    ///
    public typealias Output = Event
    public typealias Failure = Never
    
    ///
    public nonisolated func receive<
        S: Subscriber
    >(
        subscriber: S
    )
    where S.Input == Output,
          S.Failure == Failure {
        
        ///
        let subscription: Subscription<S> =
              .init(
                reactionManager: self,
                subscriber: subscriber
              )
        
        ///
        subscriber.receive(subscription: subscription)
    }
}

///
private extension MainActorReactionManager {
    
    ///
    final class Subscription<S: Subscriber>: Combine.Subscription
        where S.Input == Event,
              S.Failure == Never {
        
        ///
        private let subscriber: S
        private let reactionManager: MainActorReactionManager<Event>
        private var reactionRetainer: ReactionRetainer? = nil
        
        /// When remaining demand equals nil it means that the subscription has been cancelled
        @MainActor
        private var remainingDemand: Subscribers.Demand? = Subscribers.Demand.none
        
        ///
        init(
            reactionManager: MainActorReactionManager<Event>,
            subscriber: S
        ) {
            
            ///
            self.subscriber = subscriber
            self.reactionManager = reactionManager
            
            ///
            Task { @MainActor in
                setupReaction(using: reactionManager)
            }
        }
        
        ///
        @MainActor
        private func setupReaction(
            using reactionManager: MainActorReactionManager<Event>
        ) {
            
            ///
            reactionRetainer =
                reactionManager
                    .registerReaction { [subscriber] newValue in
                        guard let remainingDemand = self.remainingDemand else { return }
                        guard remainingDemand != Subscribers.Demand.none else { return }
                        self.remainingDemand = (remainingDemand - 1) + subscriber.receive(newValue)
                    }
        }
        
        ///
        func request(_ demand: Subscribers.Demand) {
            
            ///
            Task { @MainActor in
                if let remainingDemand {
                    if demand == .unlimited {
                        self.remainingDemand = .unlimited
                    } else {
                        if remainingDemand != .unlimited {
                            self.remainingDemand = remainingDemand + demand
                        }
                    }
                }
            }
        }
        
        ///
        func cancel() {
            
            ///
            Task { @MainActor in
                remainingDemand = nil
                reactionRetainer = nil
            }
        }
    }
}
