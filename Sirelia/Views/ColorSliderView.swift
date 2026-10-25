//
//  ColorSliderView.swift
//  Sirelia
//
//  Created by Tufan Cakir on 24.10.26.
//

import SwiftUI
import UIKit

struct ColorSliderView: View {

    // MARK: - State

    @State private var selectedColor: Color = .blue
    @State private var hexInput = "#0000FF"
    @State private var copiedValue: String?

    @FocusState private var hexIsFocused: Bool

    @ObservedObject var paletteManager: PaletteManager

    // MARK: - Color Components

    private var components:
        (
            red: Double,
            green: Double,
            blue: Double,
            alpha: Double
        )
    {
        let value = selectedColor.components

        return (
            Double(value.red),
            Double(value.green),
            Double(value.blue),
            Double(value.alpha)
        )
    }

    // MARK: - Color Values

    private var hexValue: String {
        let c = components

        return String(
            format: "#%02X%02X%02X",
            Int((c.red * 255).rounded()),
            Int((c.green * 255).rounded()),
            Int((c.blue * 255).rounded())
        )
    }

    private var hexAlphaValue: String {
        String(
            format: "%@%02X",
            hexValue,
            Int((components.alpha * 255).rounded())
        )
    }

    private var rgbValue: String {
        let c = components

        return String(
            format: "%d, %d, %d",
            Int((c.red * 255).rounded()),
            Int((c.green * 255).rounded()),
            Int((c.blue * 255).rounded())
        )
    }

    private var rgbaValue: String {
        let c = components

        return String(
            format: "rgba(%d, %d, %d, %.2f)",
            Int((c.red * 255).rounded()),
            Int((c.green * 255).rounded()),
            Int((c.blue * 255).rounded()),
            c.alpha
        )
    }

    private var swiftUIColorValue: String {
        let c = components

        return String(
            format:
                "Color(.sRGB, red: %.4f, green: %.4f, blue: %.4f, opacity: %.4f)",
            c.red,
            c.green,
            c.blue,
            c.alpha
        )
    }

    // MARK: - Body

    var body: some View {
        Form {

            ColorPreviewSection(
                color: selectedColor
            )

            PaletteSection(
                selectedColor: $selectedColor,
                savedColors: $paletteManager.savedColors
            )

            ColorChannelSection(
                selectedColor: $selectedColor,
                showsAlpha: true
            )

            ColorContrastSection(
                color: selectedColor
            )

            colorValuesSection
        }
        .navigationTitle("Farbslider")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(
                    "Zurücksetzen",
                    systemImage: "arrow.counterclockwise"
                ) {
                    resetColor()
                }
                .disabled(hexValue == "#0000FF" && components.alpha == 1)
            }
        }
        .onAppear {
            syncHex()
        }
        .onChange(of: selectedColor) { _, _ in
            syncHex()
            copiedValue = nil
        }
        .onChange(of: hexIsFocused) { _, focused in
            if !focused {
                applyHex()
            }
        }
    }

    // MARK: - Color Values Section

    private var colorValuesSection: some View {
        Section("Farbwerte") {

            HStack(spacing: 12) {
                Text("HEX")
                    .fontWeight(.medium)

                TextField("#000000", text: $hexInput)
                    .font(
                        .system(
                            .body,
                            design: .monospaced
                        )
                    )
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .focused($hexIsFocused)
                    .submitLabel(.done)
                    .onSubmit {
                        applyHex()
                        hexIsFocused = false
                    }

                copyButton(
                    value: hexValue,
                    identifier: "hex"
                )
            }

            valueRow(
                title: "HEX Alpha",
                value: hexAlphaValue,
                identifier: "hexAlpha"
            )

            valueRow(
                title: "RGB",
                value: rgbValue,
                identifier: "rgb"
            )

            valueRow(
                title: "RGBA",
                value: rgbaValue,
                identifier: "rgba"
            )

            valueRow(
                title: "SwiftUI",
                value: swiftUIColorValue,
                identifier: "swiftui"
            )
        }
    }

    // MARK: - Value Row

    private func valueRow(
        title: String,
        value: String,
        identifier: String
    ) -> some View {
        HStack(spacing: 8) {
            Text(title)
                .fontWeight(.medium)

            Spacer(minLength: 4)

            Text(value)
                .font(
                    .system(
                        .caption,
                        design: .monospaced
                    )
                )
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.middle)

            copyButton(
                value: value,
                identifier: identifier
            )
        }
    }

    // MARK: - Copy Button

    private func copyButton(
        value: String,
        identifier: String
    ) -> some View {
        Button {
            UIPasteboard.general.string = value
            copiedValue = identifier
        } label: {
            Image(
                systemName: copiedValue == identifier
                    ? "checkmark"
                    : "doc.on.doc"
            )
            .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(.borderless)
        .accessibilityLabel(
            copiedValue == identifier
                ? "Kopiert"
                : "Farbwert kopieren"
        )
    }

    // MARK: - HEX Synchronization

    private func syncHex() {
        guard !hexIsFocused else { return }
        hexInput = hexValue
    }

    // MARK: - Apply HEX

    private func applyHex() {
        let raw =
            hexInput
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")

        guard
            raw.count == 6 || raw.count == 8,
            raw.allSatisfy({ $0.isHexDigit }),
            let value = UInt64(raw, radix: 16)
        else {
            hexInput = hexValue
            return
        }

        let red: Double
        let green: Double
        let blue: Double
        let alpha: Double

        if raw.count == 8 {
            red = Double((value >> 24) & 0xFF) / 255
            green = Double((value >> 16) & 0xFF) / 255
            blue = Double((value >> 8) & 0xFF) / 255
            alpha = Double(value & 0xFF) / 255
        } else {
            red = Double((value >> 16) & 0xFF) / 255
            green = Double((value >> 8) & 0xFF) / 255
            blue = Double(value & 0xFF) / 255

            // Keep current opacity for 6-digit HEX.
            alpha = components.alpha
        }

        selectedColor = Color(
            .sRGB,
            red: red,
            green: green,
            blue: blue,
            opacity: alpha
        )

        hexInput = hexValue
    }

    // MARK: - Reset

    private func resetColor() {
        selectedColor = .blue
        copiedValue = nil

        if !hexIsFocused {
            hexInput = hexValue
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ColorSliderView(
            paletteManager: PaletteManager()
        )
    }
}
