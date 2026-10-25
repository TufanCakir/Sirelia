//
//  ColorSlider.swift
//  Sirelia
//
//  Created by Tufan Cakir on 24.10.26.
//

import SwiftUI

struct ColorSlider: View {

    // MARK: - Properties

    let label: String

    @Binding var value: Double

    var range: ClosedRange<Double> = 0...255
    var format: String = "%.0f"
    let color: Color

    var step: Double = 1
    var showsTextField: Bool = true
    var showsResetButton: Bool = false
    var defaultValue: Double? = nil

    // MARK: - State

    @FocusState private var isEditing: Bool
    @State private var inputText: String = ""

    // MARK: - Computed Properties

    private var safeStep: Double {
        step > 0 && step.isFinite ? step : 1
    }

    private var clampedValue: Double {
        guard value.isFinite else { return range.lowerBound }
        return min(max(value, range.lowerBound), range.upperBound)
    }

    private var formattedValue: String {
        String(
            format: format,
            locale: Locale(identifier: "en_US_POSIX"),
            clampedValue
        )
    }

    private var sliderBinding: Binding<Double> {
        Binding(
            get: { clampedValue },
            set: { newValue in
                value = min(
                    max(newValue, range.lowerBound),
                    range.upperBound
                )
            }
        )
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            HStack(spacing: 12) {
                Text(label)
                    .font(.subheadline.weight(.medium))

                Spacer(minLength: 8)

                if showsResetButton,
                    let defaultValue,
                    abs(value - defaultValue) > 0.000001
                {

                    Button {
                        value = min(
                            max(defaultValue, range.lowerBound),
                            range.upperBound
                        )
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                    }
                    .buttonStyle(.borderless)
                    .accessibilityLabel(
                        "\(label) zurücksetzen"
                    )
                }

                if showsTextField {
                    TextField(
                        label,
                        text: $inputText
                    )
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .font(
                        .system(
                            .body,
                            design: .monospaced
                        )
                    )
                    .frame(width: 74)
                    .textFieldStyle(.roundedBorder)
                    .focused($isEditing)
                    .onSubmit(commitInput)
                    .accessibilityLabel(
                        "\(label) Wert eingeben"
                    )
                } else {
                    Text(formattedValue)
                        .font(
                            .system(
                                .body,
                                design: .monospaced
                            )
                        )
                        .fontWeight(.semibold)
                        .contentTransition(.numericText())
                }
            }

            Slider(
                value: sliderBinding,
                in: range,
                step: safeStep
            ) {
                Text(label)
            } minimumValueLabel: {
                Text(
                    String(
                        format: "%.0f",
                        range.lowerBound
                    )
                )
                .font(.caption2)
                .foregroundStyle(.secondary)
            } maximumValueLabel: {
                Text(
                    String(
                        format: "%.0f",
                        range.upperBound
                    )
                )
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
            .tint(color)
            .accessibilityValue(formattedValue)
        }
        .onAppear {
            inputText = formattedValue
        }
        .onChange(of: value) { _, _ in
            if !isEditing {
                inputText = formattedValue
            }
        }
        .onChange(of: isEditing) { _, editing in
            if !editing {
                commitInput()
            }
        }
    }

    // MARK: - Input Handling

    private func commitInput() {
        let normalized =
            inputText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")

        guard let number = Double(normalized),
            number.isFinite
        else {
            inputText = formattedValue
            return
        }

        value = min(
            max(number, range.lowerBound),
            range.upperBound
        )

        inputText = formattedValue
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var red = 128.0
    @Previewable @State var green = 180.0
    @Previewable @State var blue = 255.0
    @Previewable @State var alpha = 0.75

    Form {
        Section("RGB") {
            ColorSlider(
                label: "Rot",
                value: $red,
                color: .red,
                showsResetButton: true,
                defaultValue: 255
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
        }

        Section("Alpha") {
            ColorSlider(
                label: "Deckkraft",
                value: $alpha,
                range: 0...1,
                format: "%.2f",
                color: .primary,
                step: 0.01
            )
        }
    }
}
