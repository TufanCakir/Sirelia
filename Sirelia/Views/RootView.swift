//
//  RootView.swift
//  Sirelia
//
//  Created by Tufan Cakir on 24.10.26.
//

import SwiftUI

private enum SireliaTab: String, Hashable {
    case colors
    case gradients
    case symbols
    case settings
}

struct RootView: View {
    @SceneStorage("sirelia.selectedTab")
    private var selectedTab: SireliaTab = .colors

    @AppStorage("sirelia.appearance")
    private var appearance: AppAppearance = .system

    @AppStorage("sirelia.language")
    private var language: AppLanguage = .system

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(
                "Farben",
                systemImage: "paintpalette",
                value: .colors
            ) {
                NavigationStack {
                    ColorLibraryView()
                }
            }

            Tab(
                "Verläufe",
                systemImage: "circle.lefthalf.filled",
                value: .gradients
            ) {
                NavigationStack {
                    GradientLibraryView()
                }
            }

            Tab(
                "Symbole",
                systemImage: "square.grid.2x2",
                value: .symbols
            ) {
                NavigationStack {
                    SFSymbolPickerView()
                }
            }

            Tab(
                "Einstellungen",
                systemImage: "gear",
                value: .settings
            ) {
                NavigationStack {
                    SettingsView()
                }
            }
        }
        .preferredColorScheme(appearance.colorScheme)
        .environment(\.locale, language.locale)
    }
}

#Preview {
    RootView()
}
