//
//  ColorInspectorSections.swift
//  Sirelia
//
//  Created by Tufan Cakir on 25.10.26.
//

import SwiftUI

struct ColorPreviewSection: View {
    let color: Color

    private var alphaPercentage: Int {
        Int((color.components.alpha * 100).rounded())
    }

    var body: some View {
        Section {
            VStack(spacing: 12) {
                ZStack {
                    CheckerboardView(cellSize: 12)
                    color
                }
                .frame(height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(.primary.opacity(0.1), lineWidth: 1)
                }
                .accessibilityElement()
                .accessibilityLabel("Farbvorschau")
                .accessibilityValue(
                    "\(color.toHex), \(alphaPercentage) Prozent Deckkraft"
                )

                HStack {
                    Label(color.toHex, systemImage: "number")
                        .font(.system(.subheadline, design: .monospaced))

                    Spacer()

                    Text("\(alphaPercentage)% Alpha")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
    }
}

struct ColorContrastSection: View {
    let color: Color

    private var colorOnWhite: Color {
        color.composited(over: .white)
    }

    private var colorOnBlack: Color {
        color.composited(over: .black)
    }

    var body: some View {
        Section("WCAG Kontrast-Check") {
            ContrastRatioRow(
                title: "Text auf Weiß",
                ratio: colorOnWhite.contrastRatio(with: .white)
            )

            ContrastRatioRow(
                title: "Text auf Schwarz",
                ratio: colorOnBlack.contrastRatio(with: .black)
            )

            VStack(spacing: 10) {
                ContrastSample(
                    foreground: colorOnWhite,
                    background: .white
                )

                ContrastSample(
                    foreground: colorOnBlack,
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
}

private struct ContrastRatioRow: View {
    let title: LocalizedStringResource
    let ratio: Double

    var body: some View {
        HStack(spacing: 8) {
            Text(title)

            Spacer(minLength: 4)

            Text(ratio, format: .number.precision(.fractionLength(2)))
                .font(.system(.subheadline, design: .monospaced))
                .monospacedDigit()
                .accessibilityLabel("Kontrastverhältnis")
                .accessibilityValue(
                    "\(ratio.formatted(.number.precision(.fractionLength(2)))) zu 1"
                )

            AccessibilityBadge(contrastRatio: ratio)
        }
    }
}

private struct ContrastSample: View {
    let foreground: Color
    let background: Color

    var body: some View {
        Text("Sirelia – Beispieltext Aa")
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .foregroundStyle(foreground)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

extension Color {
    fileprivate func composited(over background: Color) -> Color {
        let foregroundComponents = components
        let backgroundComponents = background.components
        let alpha = foregroundComponents.alpha

        return Color(
            .sRGB,
            red: foregroundComponents.red * alpha
                + backgroundComponents.red * (1 - alpha),
            green: foregroundComponents.green * alpha
                + backgroundComponents.green * (1 - alpha),
            blue: foregroundComponents.blue * alpha
                + backgroundComponents.blue * (1 - alpha),
            opacity: 1
        )
    }
}

#Preview {
    Form {
        ColorPreviewSection(
            color: .blue.opacity(0.7)
        )

        ColorContrastSection(
            color: .blue.opacity(0.7)
        )
    }
}
