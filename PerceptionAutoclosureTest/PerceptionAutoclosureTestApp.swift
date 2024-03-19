//
//  PerceptionAutoclosureTestApp.swift
//  PerceptionAutoclosureTest
//
//  Created by Jacob Martin on 3/18/24.
//

import SwiftUI
import ComposableArchitecture
import Pow

@main
struct PerceptionAutoclosureTestApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(
                store: .init(
                    initialState: .init(),
                    reducer: AppReducer.init
                )
            )
        }
    }
}

@Reducer
struct AppReducer {

    @ObservableState
    struct State {
        var value: Int = 0
    }

    enum Action {
        case task
        case increment
    }

    @Dependency(\.continuousClock) var clock

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .task:
                return .run { send in
                    for await _ in clock.timer(interval: .seconds(2)) {
                        await send(.increment)
                    }
                }

            case .increment:
                state.value += 1

                return .none
            }
        }
    }
}

struct ContentView: View {

    @Perception.Bindable var store: StoreOf<AppReducer>

    var body: some View {
        WithPerceptionTracking {
            VStack {
                Text("\(store.value)")
                    .padding()
                    .background {
                        Circle()
                            .fill(Color.red)
                    }
                    .changeEffect(
                        .pulse(shape: Circle(), count: 3),
                        value: store.value,
                        isEnabled: store.value % 2 == 0
                    )
            }
            .padding()
            .task {
                await store.send(.task).finish()
            }
        }
    }
}

#Preview {
    ContentView(
        store: .init(
            initialState: .init(),
            reducer: AppReducer.init
        )
    )
}
