//
//  PaletteSection.swift
//  Sirelia
//
//  Created by Tufan Cakir on 24.10.26.
//

import SwiftUI
import UIKit

struct PaletteSection: View {

    @Binding var selectedColor: Color
    @Binding var savedColors: [PaletteColor]

    @State private var showClearConfirmation = false

    private var currentColorIsSaved: Bool {
        savedColors.contains {
            $0.color.toHexWithAlpha == selectedColor.toHexWithAlpha
        }
    }

    var body: some View {
        Section {
            addColorRow

            if savedColors.isEmpty {
                emptyState
            } else {
                paletteScrollView
                paletteInfoRow
            }
        } header: {
            HStack {
                Text("Gespeicherte Palette")

                Spacer()

                if !savedColors.isEmpty {
                    Text("\(savedColors.count)")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }
        } footer: {
            Text(
                "Tippe auf eine Farbe, um sie auszuwählen. "
                    + "Halte sie gedrückt, um weitere Aktionen zu öffnen."
            )
        }
        .confirmationDialog(
            "Gesamte Palette löschen?",
            isPresented: $showClearConfirmation,
            titleVisibility: .visible
        ) {
            Button(
                "Alle Farben löschen",
                role: .destructive
            ) {
                savedColors.removeAll()
            }

            Button("Abbrechen", role: .cancel) {}
        } message: {
            Text(
                "Alle gespeicherten Farben werden entfernt."
            )
        }
    }

    // MARK: - Add Color

    private var addColorRow: some View {
        HStack(spacing: 12) {
            Image(systemName: "paintpalette")
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 3) {
                Text("Aktuelle Farbe speichern")
                    .font(.subheadline.weight(.medium))

                Text(selectedColor.toHexWithAlpha)
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button(action: addCurrentColorToPalette) {
                Image(
                    systemName: currentColorIsSaved
                        ? "checkmark.circle.fill"
                        : "plus.circle.fill"
                )
                .font(.title2)
            }
            .buttonStyle(.borderless)
            .disabled(currentColorIsSaved)
            .accessibilityLabel(
                currentColorIsSaved
                    ? "Farbe bereits gespeichert"
                    : "Aktuelle Farbe zur Palette hinzufügen"
            )
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        HStack(spacing: 10) {
            Image(systemName: "square.stack")
                .foregroundStyle(.secondary)

            Text("Noch keine Farben gespeichert")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }

    // MARK: - Palette

    private var paletteScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                ForEach(savedColors) { paletteColor in
                    paletteButton(paletteColor)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 2)
        }
    }

    // MARK: - Color Button

    private func paletteButton(
        _ paletteColor: PaletteColor
    ) -> some View {
        let isSelected =
            selectedColor.toHexWithAlpha == paletteColor.color.toHexWithAlpha

        return Button {
            selectedColor = paletteColor.color

            UISelectionFeedbackGenerator()
                .selectionChanged()
        } label: {
            ZStack {
                checkerboardCircle

                Circle()
                    .fill(paletteColor.color)

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(
                            .system(
                                size: 16,
                                weight: .bold
                            )
                        )
                        .foregroundStyle(
                            checkmarkColor(
                                for: paletteColor.color
                            )
                        )
                }
            }
            .frame(width: 46, height: 46)
            .overlay {
                Circle()
                    .strokeBorder(
                        isSelected
                            ? Color.accentColor
                            : Color.primary.opacity(0.2),
                        lineWidth: isSelected ? 3 : 1
                    )
            }
            .padding(3)
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                selectedColor = paletteColor.color
            } label: {
                Label(
                    "Farbe auswählen",
                    systemImage: "checkmark.circle"
                )
            }

            Button {
                UIPasteboard.general.string =
                    paletteColor.color.toHexWithAlpha
            } label: {
                Label(
                    "HEX kopieren",
                    systemImage: "number"
                )
            }

            Button {
                UIPasteboard.general.string =
                    paletteColor.color.toRgbaString
            } label: {
                Label(
                    "RGBA kopieren",
                    systemImage: "doc.on.doc"
                )
            }

            Divider()

            Button(role: .destructive) {
                deletePaletteColor(paletteColor)
            } label: {
                Label(
                    "Farbe löschen",
                    systemImage: "trash"
                )
            }
        }
        .accessibilityLabel(
            "Gespeicherte Farbe \(paletteColor.color.toHexWithAlpha)"
        )
        .accessibilityAddTraits(
            isSelected ? [.isSelected] : []
        )
        .accessibilityHint(
            "Doppeltippen zum Auswählen"
        )
    }

    // MARK: - Transparency Background

    private var checkerboardCircle: some View {
        CheckerboardView(cellSize: 7)
            .clipShape(Circle())
    }

    // MARK: - Palette Information

    private var paletteInfoRow: some View {
        HStack {
            Label(
                "\(savedColors.count) Farben",
                systemImage: "square.stack.3d.up"
            )
            .font(.caption)
            .foregroundStyle(.secondary)

            Spacer()

            Button(role: .destructive) {
                showClearConfirmation = true
            } label: {
                Label(
                    "Alle löschen",
                    systemImage: "trash"
                )
                .font(.caption)
            }
            .buttonStyle(.borderless)
        }
    }

    // MARK: - Checkmark Contrast

    private func checkmarkColor(
        for color: Color
    ) -> Color {
        let rgba = color.components

        // Approximate appearance on white checkerboard
        let red = rgba.red * rgba.alpha + (1 - rgba.alpha)
        let green = rgba.green * rgba.alpha + (1 - rgba.alpha)
        let blue = rgba.blue * rgba.alpha + (1 - rgba.alpha)

        let visibleColor = Color(
            .sRGB,
            red: Double(red),
            green: Double(green),
            blue: Double(blue),
            opacity: 1
        )

        return visibleColor.luminance > 0.45
            ? .black
            : .white
    }

    // MARK: - Add

    private func addCurrentColorToPalette() {
        guard !currentColorIsSaved else {
            return
        }

        savedColors.append(
            PaletteColor(color: selectedColor)
        )

        UIImpactFeedbackGenerator(style: .light)
            .impactOccurred()
    }

    // MARK: - Delete

    private func deletePaletteColor(
        _ color: PaletteColor
    ) {
        savedColors.removeAll {
            $0.id == color.id
        }
    }
}

#Preview {
    struct PreviewContainer: View {
        @State private var selectedColor: Color = .blue

        @State private var savedColors: [PaletteColor] = [
            PaletteColor(color: .red),
            PaletteColor(color: .blue),
            PaletteColor(color: .green),
            PaletteColor(color: .purple.opacity(0.5)),
        ]

        var body: some View {
            Form {
                PaletteSection(
                    selectedColor: $selectedColor,
                    savedColors: $savedColors
                )
            }
        }
    }

    return PreviewContainer()
}
