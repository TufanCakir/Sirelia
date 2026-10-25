//
//  ColorLibraryView.swift
//  Sirelia
//
//  Created by Tufan Cakir on 25.10.26.
//

import SwiftUI

struct ColorLibraryView: View {

    @StateObject private var paletteManager = PaletteManager()

    private let columns = [
        GridItem(.adaptive(minimum: 160), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {

                NavigationLink {
                    ColorEditorView(
                        paletteManager: paletteManager
                    )
                } label: {
                    Label(
                        "Farbeditor",
                        systemImage: "paintpalette"
                    )
                    .frame(maxWidth: .infinity, minHeight: 100)
                }

                NavigationLink {
                    ColorSliderView(
                        paletteManager: paletteManager
                    )
                } label: {
                    Label(
                        "RGBA-Editor",
                        systemImage: "slider.horizontal.3"
                    )
                    .frame(maxWidth: .infinity, minHeight: 100)
                }
            }
            .buttonStyle(.bordered)
            .padding()
        }
        .navigationTitle("Farben")
    }
}

#Preview {
    NavigationStack {
        ColorLibraryView()
    }
}
