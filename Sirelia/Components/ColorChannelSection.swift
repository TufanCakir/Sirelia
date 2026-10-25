//
//  ColorChannelSection.swift
//  Sirelia
//
//  Created by Tufan Cakir on 25.10.26.
//

import SwiftUI

struct ColorChannelSection: View {

    // MARK: - Properties

    @Binding var selectedColor: Color

    var showsAlpha: Bool = true
    var showsResetButtons: Bool = false

    // MARK: - Channels

    private enum Channel {
        case red
        case green
        case blue
        case alpha
    }

    private func channelBinding(
        _ channel: Channel
    ) -> Binding<Double> {
        Binding(
            get: {
                let components = selectedColor.components

                switch channel {
                case .red:
                    return Double(components.red) * 255
                case .green:
                    return Double(components.green) * 255
                case .blue:
                    return Double(components.blue) * 255
                case .alpha:
                    return Double(components.alpha) * 100
                }
            },
            set: { newValue in
                let components = selectedColor.components

                var red = Double(components.red)
                var green = Double(components.green)
                var blue = Double(components.blue)
                var alpha = Double(components.alpha)

                switch channel {
                case .red:
                    red = newValue / 255
                case .green:
                    green = newValue / 255
                case .blue:
                    blue = newValue / 255
                case .alpha:
                    alpha = newValue / 100
                }

                selectedColor = Color(
                    .sRGB,
                    red: min(max(red, 0), 1),
                    green: min(max(green, 0), 1),
                    blue: min(max(blue, 0), 1),
                    opacity: min(max(alpha, 0), 1)
                )
            }
        )
    }

    // MARK: - Body

    var body: some View {
        Section("RGBA Kanäle") {

            ColorSlider(
                label: "Rot",
                value: channelBinding(.red),
                color: .red,
                showsResetButton: showsResetButtons,
                defaultValue: 0
            )

            ColorSlider(
                label: "Grün",
                value: channelBinding(.green),
                color: .green,
                showsResetButton: showsResetButtons,
                defaultValue: 0
            )

            ColorSlider(
                label: "Blau",
                value: channelBinding(.blue),
                color: .blue,
                showsResetButton: showsResetButtons,
                defaultValue: 255
            )

            if showsAlpha {
                ColorSlider(
                    label: "Deckkraft",
                    value: channelBinding(.alpha),
                    range: 0...100,
                    format: "%.0f",
                    color: .gray,
                    showsResetButton: showsResetButtons,
                    defaultValue: 100
                )
            }
        }
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var color: Color = .blue

    Form {
        ColorChannelSection(
            selectedColor: $color,
            showsAlpha: true,
            showsResetButtons: true
        )
    }
}
