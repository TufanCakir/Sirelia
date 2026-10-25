//
//  ColorSliderView.swift
//  Sirelia
//
//  Created by Tufan Cakir on 24.10.26.
//

import SwiftUI
import UIKit

struct ColorSliderView: View {
    @State private var red: Double = 0
    @State private var green: Double = 0
    @State private var blue: Double = 255
    @State private var alpha: Double = 100

    @State private var hexInput = "#0000FF"
    @FocusState private var hexIsFocused: Bool

    @ObservedObject var paletteManager: PaletteManager

    private var selectedColor: Color {
        Color(
            .sRGB,
            red: red / 255,
            green: green / 255,
            blue: blue / 255,
            opacity: alpha / 100
        )
    }

    private var rgbColor: Color {
        Color(
            .sRGB,
            red: red / 255,
            green: green / 255,
            blue: blue / 255,
            opacity: 1
        )
    }

    private var colorBinding: Binding<Color> {
        Binding(
            get: { selectedColor },
            set: { updateChannels(from: $0) }
        )
    }

    private var hexValue: String {
        String(
            format: "#%02X%02X%02X",
            Int(red.rounded()),
            Int(green.rounded()),
            Int(blue.rounded())
        )
    }

    private var rgbaValue: String {
        String(
            format: "rgba(%d, %d, %d, %.2f)",
            Int(red.rounded()),
            Int(green.rounded()),
            Int(blue.rounded()),
            alpha / 100
        )
    }

    var body: some View {
        Form {
            Section {
                colorPreview
            }

            PaletteSection(
                selectedColor: colorBinding,
                savedColors: $paletteManager.savedColors
            )

            Section("RGBA Kanäle") {
                ColorSlider(
                    label: "Rot",
                    value: $red,
                    color: .red
                )

                ColorSlider(
                    label: "Grün",
                    value: $green,
                    color: .green
                )

                ColorSlider(
                    label: "Blau",
                    value: $blue,
                    color: .blue
                )

                ColorSlider(
                    label: "Deckkraft",
                    value: $alpha,
                    range: 0...100,
                    format: "%.0f%%",
                    color: .gray
                )
            }

            contrastSection
            colorValuesSection
        }
        .navigationTitle("Farbeditor")
        .onChange(of: red) { _, _ in syncHex() }
        .onChange(of: green) { _, _ in syncHex() }
        .onChange(of: blue) { _, _ in syncHex() }
        .onChange(of: hexIsFocused) { _, focused in
            if !focused {
                applyHex()
                hexInput = hexValue
            }
        }
        .onAppear {
            hexInput = hexValue
        }
    }

    // MARK: - Farbvorschau

    private var colorPreview: some View {
        VStack(spacing: 12) {
            ZStack {
                CheckerboardView()
                selectedColor
            }
            .frame(height: 140)
            .clipShape(
                RoundedRectangle(cornerRadius: 14)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(
                        .primary.opacity(0.1),
                        lineWidth: 1
                    )
            }

            HStack {
                Label(hexValue, systemImage: "number")
                    .font(.system(.subheadline, design: .monospaced))

                Spacer()

                Text("\(Int(alpha.rounded()))% Alpha")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - WCAG

    private var contrastSection: some View {
        // WCAG-Kontrast wird mit der tatsächlich
        // sichtbaren Farbe berechnet.
        let onWhite = compositedColor(on: .white)
        let onBlack = compositedColor(on: .black)

        let whiteRatio = onWhite.contrastRatio(with: .white)
        let blackRatio = onBlack.contrastRatio(with: .black)

        return Section("WCAG Kontrast-Check") {
            contrastRow(
                title: "Auf Weiß",
                ratio: whiteRatio
            )

            contrastRow(
                title: "Auf Schwarz",
                ratio: blackRatio
            )

            VStack(spacing: 8) {
                contrastPreview(
                    background: .white,
                    foreground: onWhite,
                    ratio: whiteRatio
                )

                contrastPreview(
                    background: .black,
                    foreground: onBlack,
                    ratio: blackRatio
                )
            }
        }
    }

    private func contrastRow(
        title: String,
        ratio: Double
    ) -> some View {
        HStack {
            Text(title)

            Spacer(minLength: 8)

            Text(String(format: "%.2f:1", ratio))
                .font(.system(.subheadline, design: .monospaced))
                .monospacedDigit()

            AccessibilityBadge(contrastRatio: ratio)
        }
    }

    private func contrastPreview(
        background: Color,
        foreground: Color,
        ratio: Double
    ) -> some View {
        Text("Beispieltext Aa")
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .foregroundStyle(foreground)
            .background(background)
            .clipShape(
                RoundedRectangle(cornerRadius: 10)
            )
            .accessibilityLabel(
                "Beispieltext, Kontrast \(String(format: "%.2f", ratio)) zu 1"
            )
    }

    // MARK: - Farbwerte

    private var colorValuesSection: some View {
        Section("Farbwerte") {
            HStack(spacing: 12) {
                Text("HEX")
                    .fontWeight(.medium)

                TextField("#000000", text: $hexInput)
                    .font(.system(.body, design: .monospaced))
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .focused($hexIsFocused)
                    .submitLabel(.done)
                    .onSubmit {
                        applyHex()
                        hexIsFocused = false
                    }

                copyButton(hexValue)
            }

            HStack(spacing: 12) {
                Text("RGBA")
                    .fontWeight(.medium)

                Spacer(minLength: 4)

                Text(rgbaValue)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                copyButton(rgbaValue)
            }

            HStack {
                Text("RGB")
                    .fontWeight(.medium)

                Spacer()

                Text(
                    "\(Int(red.rounded())), " + "\(Int(green.rounded())), "
                        + "\(Int(blue.rounded()))"
                )
                .font(.system(.subheadline, design: .monospaced))
                .foregroundStyle(.secondary)

                copyButton(
                    "\(Int(red.rounded())), " + "\(Int(green.rounded())), "
                        + "\(Int(blue.rounded()))"
                )
            }
        }
    }

    private func copyButton(_ value: String) -> some View {
        ShareLink(item: value) {
            Image(systemName: "square.and.arrow.up")
        }
        .labelStyle(.iconOnly)
        .accessibilityLabel("Farbwert teilen")
    }

    // MARK: - Farbverwaltung

    private func syncHex() {
        guard !hexIsFocused else { return }
        hexInput = hexValue
    }

    private func applyHex() {
        guard let color = Color(hex: hexInput) else {
            hexInput = hexValue
            return
        }

        let components = color.components

        red = Double(components.red) * 255
        green = Double(components.green) * 255
        blue = Double(components.blue) * 255
        alpha = Double(components.alpha) * 100

        hexInput = hexValue
    }

    private func updateChannels(from color: Color) {
        let components = color.components

        red = Double(components.red) * 255
        green = Double(components.green) * 255
        blue = Double(components.blue) * 255
        alpha = Double(components.alpha) * 100

        syncHex()
    }

    private func compositedColor(on background: Color) -> Color {
        let bg = background.components
        let opacity = alpha / 100

        return Color(
            .sRGB,
            red: (red / 255) * opacity + Double(bg.red) * (1 - opacity),
            green: (green / 255) * opacity + Double(bg.green) * (1 - opacity),
            blue: (blue / 255) * opacity + Double(bg.blue) * (1 - opacity),
            opacity: 1
        )
    }
}

#Preview {
    NavigationStack {
        ColorSliderView(
            paletteManager: PaletteManager()
        )
    }
}
