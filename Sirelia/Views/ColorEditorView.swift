//
//  ColorEditorView.swift
//  Sirelia
//
//  Created by Tufan Cakir on 24.10.26.
//

import SwiftUI
import UIKit

struct ColorEditorView: View {

    // MARK: - State

    @State private var selectedColor: Color = .blue
    @State private var hexInput = "#0000FF"
    @State private var copiedValue: String?

    @ObservedObject var paletteManager: PaletteManager

    @FocusState private var isHexFocused: Bool

    // MARK: - Computed Properties

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
        let c = components

        return String(
            format: "%@%02X",
            hexValue,
            Int((c.alpha * 255).rounded())
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

    // MARK: - Body

    var body: some View {
        Form {
            previewSection
            colorPickerSection

            PaletteSection(
                selectedColor: $selectedColor,
                savedColors: $paletteManager.savedColors
            )

            contrastSection
            colorValuesSection
        }
        .navigationTitle("Farbeditor")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Zurücksetzen", systemImage: "arrow.counterclockwise") {
                    selectedColor = .blue
                    hexInput = hexValue
                }
            }
        }
        .onAppear {
            syncHex()
        }
        .onChange(of: selectedColor) { _, _ in
            syncHex()
        }
        .onChange(of: isHexFocused) { _, focused in
            if !focused {
                applyHexInput()
            }
        }
    }

    // MARK: - Preview

    private var previewSection: some View {
        Section {
            VStack(spacing: 12) {
                ZStack {
                    CheckerboardView(cellSize: 12)

                    selectedColor
                }
                .frame(height: 150)
                .clipShape(
                    RoundedRectangle(cornerRadius: 16)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(
                            .primary.opacity(0.1),
                            lineWidth: 1
                        )
                }

                HStack {
                    Label(
                        hexValue,
                        systemImage: "number"
                    )
                    .font(
                        .system(
                            .subheadline,
                            design: .monospaced
                        )
                    )

                    Spacer()

                    Text(
                        "\(Int((components.alpha * 100).rounded()))% Alpha"
                    )
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
                }
            }
            .padding(.vertical, 4)
        }
    }

    // MARK: - Color Picker

    private var colorPickerSection: some View {
        Section("Farbauswahl") {
            ColorPicker(
                "Farbe auswählen",
                selection: $selectedColor,
                supportsOpacity: true
            )

            HStack {
                Text("Aktuelle Farbe")

                Spacer()

                Circle()
                    .fill(selectedColor)
                    .frame(width: 28, height: 28)
                    .overlay {
                        Circle()
                            .strokeBorder(
                                .primary.opacity(0.15),
                                lineWidth: 1
                            )
                    }
            }
        }
    }

    // MARK: - WCAG Contrast

    private var contrastSection: some View {
        let whiteBackground = Color.white
        let blackBackground = Color.black

        // Bei Alpha muss die sichtbare Farbe
        // auf dem Hintergrund berechnet werden.
        let onWhite = blendedColor(over: whiteBackground)
        let onBlack = blendedColor(over: blackBackground)

        let whiteRatio = onWhite.contrastRatio(
            with: whiteBackground
        )

        let blackRatio = onBlack.contrastRatio(
            with: blackBackground
        )

        return Section("WCAG Kontrast-Check") {
            contrastRow(
                title: "Text auf Weiß",
                ratio: whiteRatio
            )

            contrastRow(
                title: "Text auf Schwarz",
                ratio: blackRatio
            )

            VStack(spacing: 10) {
                contrastPreview(
                    textColor: onWhite,
                    background: .white
                )

                contrastPreview(
                    textColor: onBlack,
                    background: .black
                )
            }
            .padding(.vertical, 4)

            Text(
                "WCAG AA benötigt mindestens 4,5:1 für normalen Text und 3:1 für großen Text."
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }

    private func contrastRow(
        title: String,
        ratio: Double
    ) -> some View {
        HStack(spacing: 8) {
            Text(title)

            Spacer(minLength: 4)

            Text(String(format: "%.2f:1", ratio))
                .font(
                    .system(
                        .subheadline,
                        design: .monospaced
                    )
                )
                .monospacedDigit()

            AccessibilityBadge(
                contrastRatio: ratio
            )
        }
    }

    private func contrastPreview(
        textColor: Color,
        background: Color
    ) -> some View {
        Text("Sirelia – Beispieltext Aa")
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .foregroundStyle(textColor)
            .background(background)
            .clipShape(
                RoundedRectangle(cornerRadius: 10)
            )
    }

    // MARK: - Color Values

    private var colorValuesSection: some View {
        Section("Farbwerte") {
            HStack(spacing: 12) {
                Text("HEX")
                    .fontWeight(.medium)

                TextField(
                    "#000000",
                    text: $hexInput
                )
                .font(
                    .system(
                        .body,
                        design: .monospaced
                    )
                )
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .focused($isHexFocused)
                .submitLabel(.done)
                .onSubmit {
                    applyHexInput()
                    isHexFocused = false
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
                title: "RGBA",
                value: rgbaValue,
                identifier: "rgba"
            )

            valueRow(
                title: "SwiftUI",
                value: swiftUIColorString,
                identifier: "swiftui"
            )
        }
    }

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

    // MARK: - SwiftUI Export

    private var swiftUIColorString: String {
        let c = components

        return String(
            format: "Color(red: %.3f, green: %.3f, blue: %.3f, opacity: %.3f)",
            c.red,
            c.green,
            c.blue,
            c.alpha
        )
    }

    // MARK: - HEX Synchronization

    private func syncHex() {
        guard !isHexFocused else { return }
        hexInput = hexValue
    }

    private func applyHexInput() {
        let raw =
            hexInput
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")

        guard raw.count == 6 || raw.count == 8,
            raw.allSatisfy({ $0.isHexDigit }),
            let rgb = UInt64(raw, radix: 16)
        else {
            hexInput = hexValue
            return
        }

        let red: Double
        let green: Double
        let blue: Double
        let alpha: Double

        if raw.count == 8 {
            red = Double((rgb >> 24) & 0xFF) / 255
            green = Double((rgb >> 16) & 0xFF) / 255
            blue = Double((rgb >> 8) & 0xFF) / 255
            alpha = Double(rgb & 0xFF) / 255
        } else {
            red = Double((rgb >> 16) & 0xFF) / 255
            green = Double((rgb >> 8) & 0xFF) / 255
            blue = Double(rgb & 0xFF) / 255

            // Bei sechs Stellen Alpha beibehalten.
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

    // MARK: - Alpha Compositing

    private func blendedColor(over background: Color) -> Color {
        let foreground = components
        let bg = background.components
        let alpha = foreground.alpha

        return Color(
            .sRGB,
            red: foreground.red * alpha + Double(bg.red) * (1 - alpha),
            green: foreground.green * alpha + Double(bg.green) * (1 - alpha),
            blue: foreground.blue * alpha + Double(bg.blue) * (1 - alpha),
            opacity: 1
        )
    }
}

#Preview {
    NavigationStack {
        ColorEditorView(
            paletteManager: PaletteManager()
        )
    }
}
