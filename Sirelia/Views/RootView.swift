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
}

struct RootView: View {

    @SceneStorage("sirelia.selectedTab")
    private var selectedTab: SireliaTab = .colors

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
        }
    }
}

#Preview {
    RootView()
}
