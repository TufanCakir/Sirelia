//
//  SireliaApp.swift
//  Sirelia
//
//  Created by Tufan Cakir on 25.10.26.
//

import SwiftUI

@main
struct SireliaApp: App {
    @State private var store = StoreManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
                .task {
                    await store.prepare()
                    await store.observeTransactionUpdates()
                }
        }
    }
}
