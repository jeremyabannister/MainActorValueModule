//
//  ObservableMainActorValue.swift
//  
//
//  Created by Jeremy Bannister on 2/5/23.
//

///
@_exported import Combine
@_exported import MainActorValueModule_main_actor_value_source


///
public final class ObservableMainActorValue <Value>: ObservableObject,
                                                     Interface_ReadableMainActorValue {
    
    ///
    public let objectWillChange: AnyPublisher<Void, Never>
    
    ///
    private let value: any Interface_ReadableMainActorValue<Value>
    
    ///
    @MainActor
    public var currentValue: Value {
        value.currentValue
    }
    
    ///
    public init (_ value: some Interface_ReadableMainActorValue<Value>) {
        
        ///
        self.value = value
        
        ///
        self.objectWillChange =
            MainActorValuePublisher(
                readOnlyValue: value
            )
                .map { _ in () }
                .eraseToAnyPublisher()
    }
    
    ///
    public init (_ value: some Interface_SubscribableMainActorValue<Value>) {
        
        ///
        self.value = value
        
        ///
        self.objectWillChange =
            MainActorValuePublisher(
                subscribableValue: value
            )
                .map { _ in () }
                .eraseToAnyPublisher()
    }
}

///
extension Interface_ReadableMainActorValue {
    
    ///
    public func asObservableMainActorValue () -> ObservableMainActorValue<Value> {
        .init(self)
    }
}

///
extension Interface_SubscribableMainActorValue {
    
    ///
    public func asObservableMainActorValue () -> ObservableMainActorValue<Value> {
        .init(self)
    }
}

///
fileprivate struct MainActorValuePublisher <Value>: Publisher {
    
    ///
    typealias Output = Value
    typealias Failure = Never
    
    ///
    private let mainActorValue: MainActorValueType
    
    ///
    private enum MainActorValueType {
        case readOnly (any Interface_ReadableMainActorValue<Value>)
        case subscribable (any Interface_SubscribableMainActorValue<Value>)
    }
    
    ///
    init (readOnlyValue: some Interface_ReadableMainActorValue<Value>) {
        self.mainActorValue = .readOnly(readOnlyValue)
    }
    
    ///
    init (subscribableValue: some Interface_SubscribableMainActorValue<Value>) {
        self.mainActorValue = .subscribable(subscribableValue)
    }
    
    ///
    func receive
        <S: Subscriber>
        (subscriber: S)
    where S.Input == Output,
          S.Failure == Failure {
        
        ///
        let subscription: Subscription<S>
              
        ///
        switch mainActorValue {
        case .readOnly (let readOnlyValue):
            subscription = Subscription(readOnlyValue: readOnlyValue, subscriber: subscriber)
            
        case .subscribable (let subscribableValue):
            subscription = Subscription(subscribableValue: subscribableValue, subscriber: subscriber)
        }
        
        ///
        subscriber.receive(subscription: subscription)
    }
}

///
private extension MainActorValuePublisher {
    
    ///
    final class Subscription <S: Subscriber>: Combine.Subscription
        where S.Input == Value,
              S.Failure == Never {
        
        ///
        private let subscriber: S
        private var subscribableValueRetainer: Any? = nil
        private var reactionRetainer: ReactionRetainer? = nil
        
        /// When remaining demand equals nil it means that the subscription has been cancelled
        @MainActor
        private var remainingDemand: Subscribers.Demand? = Subscribers.Demand.none
        
        ///
        init
            (readOnlyValue: some Interface_ReadableMainActorValue<Value>,
             subscriber: S) {
            
            ///
            self.subscriber = subscriber
            
            ///
            Task { @MainActor in
                setupReaction(
                    using: readOnlyValue.madeSubscribable()
                )
            }
        }
        
        ///
        init
            (subscribableValue: some Interface_SubscribableMainActorValue<Value>,
             subscriber: S) {
            
            ///
            self.subscriber = subscriber
            
            ///
            Task { @MainActor in
                setupReaction(using: subscribableValue)
            }
        }
        
        ///
        @MainActor
        private func setupReaction
            (using subscribableValue: some Interface_SubscribableMainActorValue<Value>) {
            
            ///
            self.subscribableValueRetainer = subscribableValue
            
            ///
            reactionRetainer =
                subscribableValue
                    .didSet
                    .registerReaction { [subscriber] newValue in
                        guard let remainingDemand = self.remainingDemand else { return }
                        guard remainingDemand != Subscribers.Demand.none else { return }
                        self.remainingDemand = subscriber.receive(newValue)
                    }
        }
        
        ///
        func request (_ demand: Subscribers.Demand) {
            
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
        func cancel () {
            
            ///
            Task { @MainActor in
                remainingDemand = nil
                subscribableValueRetainer = nil
                reactionRetainer = nil
            }
        }
    }
}
