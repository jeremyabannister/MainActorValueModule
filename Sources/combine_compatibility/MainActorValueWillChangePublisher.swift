//
//  MainActorValueWillChangePublisher.swift
//
//
//  Created by Jeremy Bannister on 2/22/24.
//

///
public struct MainActorValueWillChangePublisher: Publisher {
    
    ///
    public typealias Output = Void
    public typealias Failure = Never
    
    ///
    private let mainActorValue: MainActorValueType
    
    ///
    private enum MainActorValueType {
        case readOnly(any Interface_ReadableMainActorValue, LeakTracker)
        case subscribable(any Interface_SubscribableMainActorValue)
    }
    
    ///
    public init(
        readOnlyValue: some Interface_ReadableMainActorValue,
        leakTracker: LeakTracker
    ) {
        
        ///
        self.mainActorValue = .readOnly(readOnlyValue, leakTracker)
    }
    
    ///
    public init(
        subscribableValue: some Interface_SubscribableMainActorValue
    ) {
        
        ///
        self.mainActorValue = .subscribable(subscribableValue)
    }
    
    ///
    public func receive<
        S: Subscriber
    >(
        subscriber: S
    )
    where S.Input == Output,
          S.Failure == Failure {
        
        ///
        let subscription: Subscription<S>
              
        ///
        switch mainActorValue {
        case .readOnly (let readOnlyValue,
                        let leakTracker):
            subscription =
                Subscription(
                    readOnlyValue: readOnlyValue,
                    subscriber: subscriber,
                    leakTracker: leakTracker["subscription"]
                )
            
        case .subscribable (let subscribableValue):
            subscription =
                Subscription(
                    subscribableValue: subscribableValue,
                    subscriber: subscriber
                )
        }
        
        ///
        subscriber.receive(subscription: subscription)
    }
}

///
private extension MainActorValueWillChangePublisher {
    
    ///
    final class Subscription<S: Subscriber>: Combine.Subscription
        where S.Input == Void,
              S.Failure == Never {
        
        ///
        private let subscriber: S
        private var subscribableValueRetainer: Any? = nil
        private var reactionRetainer: ReactionRetainer? = nil
        
        /// When remaining demand equals nil it means that the subscription has been cancelled
        @MainActor
        private var remainingDemand: Subscribers.Demand? = Subscribers.Demand.none
        
        ///
        init(
            readOnlyValue: some Interface_ReadableMainActorValue,
            subscriber: S,
            leakTracker: LeakTracker
        ) {
            
            ///
            self.subscriber = subscriber
            
            ///
            Task { @MainActor in
                
                ///
                setupReaction(
                    using: readOnlyValue.madeSubscribable(
                        leakTracker: leakTracker["madeSubscribable"]
                    )
                )
                
                ///
                leakTracker.track(self)
            }
        }
        
        ///
        init(
            subscribableValue: some Interface_SubscribableMainActorValue,
            subscriber: S
        ) {
            
            ///
            self.subscriber = subscriber
            
            ///
            Task { @MainActor in
                setupReaction(using: subscribableValue)
            }
        }
        
        ///
        @MainActor
        private func setupReaction(
            using subscribableValue: some Interface_SubscribableMainActorValue
        ) {
            
            ///
            self.subscribableValueRetainer = subscribableValue
            
            ///
            reactionRetainer =
                subscribableValue
                    .willSet
                    .registerReaction { [subscriber] _ in
                        guard let remainingDemand = self.remainingDemand else { return }
                        guard remainingDemand != Subscribers.Demand.none else { return }
                        self.remainingDemand = (remainingDemand - 1) + subscriber.receive(())
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
                subscribableValueRetainer = nil
                reactionRetainer = nil
            }
        }
    }
}
