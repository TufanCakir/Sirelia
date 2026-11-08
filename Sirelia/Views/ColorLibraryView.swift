//
//  ColorLibraryView.swift
//  Sirelia
//
//  Created by Tufan Cakir on 25.10.26.
//

import SwiftUI

// MARK: - Editor Type

private enum ColorEditorType: String, CaseIterable, Identifiable {
    case picker
    case rgba

    var id: String { rawValue }

    var title: LocalizedStringResource {
        switch self {
        case .picker:
            "Farbeditor"
        case .rgba:
            "RGBA-Editor"
        }
    }

    var subtitle: LocalizedStringResource {
        switch self {
        case .picker:
            "Farben auswählen und bearbeiten"
        case .rgba:
            "Farbkanäle präzise einstellen"
        }
    }

    var symbol: String {
        switch self {
        case .picker:
            "paintpalette"
        case .rgba:
            "slider.horizontal.3"
        }
    }
}

// MARK: - Color Library

struct ColorLibraryView: View {
    @StateObject private var paletteManager = PaletteManager()

    var body: some View {
        List {
            Section {
                ForEach(ColorEditorType.allCases) { type in
                    NavigationLink {
                        destination(for: type)
                    } label: {
                        editorRow(for: type)
                    }
                }
            } header: {
                Text("Farbwerkzeuge")
            } footer: {
                Text(
                    "Wähle ein Werkzeug, um Farben auszuwählen, Farbkanäle anzupassen und Farbwerte zu kopieren."
                )
            }
        }
        .navigationTitle("Farben")
    }

    // MARK: - Editor Row

    private func editorRow(
        for type: ColorEditorType
    ) -> some View {
        HStack(spacing: 14) {
            preview(for: type)
                .frame(width: 76, height: 64)
                .clipShape(
                    RoundedRectangle(cornerRadius: 12)
                )
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 5) {
                Text(type.title)
                    .font(.headline)

                Text(type.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 5)
    }

    // MARK: - Preview

    @ViewBuilder
    private func preview(
        for type: ColorEditorType
    ) -> some View {
        switch type {
        case .picker:
            ZStack {
                LinearGradient(
                    colors: [
                        .red, .orange, .yellow,
                        .green, .cyan, .blue, .purple,
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Image(systemName: type.symbol)
                    .font(.system(size: 25, weight: .medium))
                    .foregroundStyle(.white)
                    .shadow(
                        color: .black.opacity(0.35),
                        radius: 3
                    )
            }

        case .rgba:
            HStack(spacing: 4) {
                Color.red
                Color.green
                Color.blue
                Color.gray
            }
            .overlay {
                Image(systemName: type.symbol)
                    .font(.system(size: 25, weight: .medium))
                    .foregroundStyle(.white)
                    .shadow(
                        color: .black.opacity(0.5),
                        radius: 3
                    )
            }
        }
    }

    // MARK: - Navigation

    @ViewBuilder
    private func destination(
        for type: ColorEditorType
    ) -> some View {
        switch type {
        case .picker:
            ColorEditorView(
                paletteManager: paletteManager
            )

        case .rgba:
            ColorSliderView(
                paletteManager: paletteManager
            )
        }
    }
}

#Preview {
    NavigationStack {
        ColorLibraryView()
    }
}
