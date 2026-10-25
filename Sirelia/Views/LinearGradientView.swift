//
//  LinearGradientView.swift
//  Sirelia
//
//  Created by Tufan Cakir on 25.10.26.
//

import SwiftUI
import UIKit

// MARK: - Gradient Stop

private struct SireliaGradientStop: Identifiable {
    let id = UUID()
    var color: Color
    var location: Double
}

// MARK: - Linear Gradient Editor

struct LinearGradientView: View {

    @State private var stops: [SireliaGradientStop] = [
        .init(color: .black, location: 0),
        .init(color: .blue, location: 1),
    ]

    @State private var angle: Double = 135
    @State private var opacity: Double = 1
    @State private var copied = false

    private var sortedStops: [SireliaGradientStop] {
        stops.sorted { $0.location < $1.location }
    }

    private var gradient: LinearGradient {
        LinearGradient(
            stops: sortedStops.map {
                Gradient.Stop(
                    color: $0.color.opacity(opacity),
                    location: $0.location
                )
            },
            startPoint: startPoint,
            endPoint: endPoint
        )
    }

    // 0° = links nach rechts
    // 90° = unten nach oben

    private var startPoint: UnitPoint {
        let radians = angle * .pi / 180

        return UnitPoint(
            x: 0.5 - cos(radians) * 0.5,
            y: 0.5 + sin(radians) * 0.5
        )
    }

    private var endPoint: UnitPoint {
        let radians = angle * .pi / 180

        return UnitPoint(
            x: 0.5 + cos(radians) * 0.5,
            y: 0.5 - sin(radians) * 0.5
        )
    }

    var body: some View {
        Form {
            previewSection
            colorStopsSection
            directionSection
            opacitySection
            presetsSection
            exportSection
        }
        .navigationTitle("Linear Gradient")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(
                    "Zurücksetzen",
                    systemImage: "arrow.counterclockwise"
                ) {
                    resetGradient()
                }
            }
        }
    }

    // MARK: - Preview

    private var previewSection: some View {
        Section("Vorschau") {
            ZStack {
                CheckerboardView(cellSize: 12)

                gradient
            }
            .frame(height: 200)
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
                    "Linear",
                    systemImage: "square.stack.3d.up"
                )

                Spacer()

                Text("\(Int(angle))°")
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
            .font(.subheadline)
        }
    }

    // MARK: - Color Stops

    private var colorStopsSection: some View {
        Section {
            ForEach(sortedStops) { stop in
                stopRow(for: stop)
            }

            Button {
                addStop()
            } label: {
                Label(
                    "Farbpunkt hinzufügen",
                    systemImage: "plus.circle"
                )
            }
            .disabled(stops.count >= 10)

        } header: {
            HStack {
                Text("Farbpunkte")

                Spacer()

                Text("\(stops.count)/10")
                    .foregroundStyle(.secondary)
            }
        } footer: {
            Text(
                "Bestimme die Farben und ihre Positionen im Verlauf."
            )
        }
    }

    private func stopRow(
        for stop: SireliaGradientStop
    ) -> some View {
        VStack(spacing: 10) {
            HStack {
                ColorPicker(
                    "Farbe",
                    selection: colorBinding(for: stop.id),
                    supportsOpacity: true
                )

                Spacer()

                Text(
                    "\(Int((stop.location * 100).rounded()))%"
                )
                .font(
                    .system(
                        .subheadline,
                        design: .monospaced
                    )
                )
                .foregroundStyle(.secondary)

                if stops.count > 2 {
                    Button(role: .destructive) {
                        removeStop(stop.id)
                    } label: {
                        Image(systemName: "minus.circle")
                    }
                    .buttonStyle(.borderless)
                    .accessibilityLabel("Farbpunkt entfernen")
                }
            }

            Slider(
                value: locationBinding(for: stop.id),
                in: 0...1,
                step: 0.01
            )
            .tint(stop.color)
        }
        .padding(.vertical, 4)
    }

    // MARK: - Direction

    private var directionSection: some View {
        Section("Richtung") {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Winkel")

                    Spacer()

                    Text("\(Int(angle))°")
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }

                Slider(
                    value: $angle,
                    in: 0...360,
                    step: 1
                )

                HStack {
                    directionButton(
                        title: "→",
                        value: 0
                    )

                    directionButton(
                        title: "↑",
                        value: 90
                    )

                    directionButton(
                        title: "←",
                        value: 180
                    )

                    directionButton(
                        title: "↓",
                        value: 270
                    )
                }
            }
            .padding(.vertical, 4)
        }
    }

    private func directionButton(
        title: String,
        value: Double
    ) -> some View {
        Button {
            angle = value
        } label: {
            Text(title)
                .font(.title3)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .tint(angle == value ? .accentColor : .secondary)
        .accessibilityLabel("Winkel \(Int(value)) Grad")
    }

    // MARK: - Opacity

    private var opacitySection: some View {
        Section("Deckkraft") {
            HStack {
                Text("Gesamtdeckkraft")

                Spacer()

                Text(
                    "\(Int((opacity * 100).rounded()))%"
                )
                .foregroundStyle(.secondary)
                .monospacedDigit()
            }

            Slider(
                value: $opacity,
                in: 0...1,
                step: 0.01
            )
        }
    }

    // MARK: - Presets

    private var presetsSection: some View {
        Section("Vorlagen") {
            HStack(spacing: 12) {
                presetButton(
                    colors: [.black, .blue],
                    title: "Nacht"
                )

                presetButton(
                    colors: [.orange, .pink],
                    title: "Sonnenuntergang"
                )

                presetButton(
                    colors: [.cyan, .purple],
                    title: "Neon"
                )

                presetButton(
                    colors: [.black, .gray],
                    title: "Dunkel"
                )
            }
            .padding(.vertical, 4)
        }
    }

    private func presetButton(
        colors: [Color],
        title: String
    ) -> some View {
        Button {
            stops = [
                .init(color: colors[0], location: 0),
                .init(color: colors[1], location: 1),
            ]
            opacity = 1
        } label: {
            VStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(
                            colors: colors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 50)

                Text(title)
                    .font(.caption2)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Vorlage \(title)")
    }

    // MARK: - Export

    private var exportSection: some View {
        Section("Export") {
            Button {
                UIPasteboard.general.string = swiftUICode
                copied = true
            } label: {
                Label(
                    copied
                        ? "SwiftUI-Code kopiert"
                        : "SwiftUI-Code kopieren",
                    systemImage: copied
                        ? "checkmark"
                        : "doc.on.doc"
                )
            }

            ShareLink(
                item: swiftUICode
            ) {
                Label(
                    "Code teilen",
                    systemImage: "square.and.arrow.up"
                )
            }
        }
    }

    // MARK: - Bindings

    private func colorBinding(
        for id: UUID
    ) -> Binding<Color> {
        Binding(
            get: {
                stops.first(where: { $0.id == id })?.color
                    ?? .clear
            },
            set: { newColor in
                guard
                    let index = stops.firstIndex(
                        where: { $0.id == id }
                    )
                else { return }

                stops[index].color = newColor
                copied = false
            }
        )
    }

    private func locationBinding(
        for id: UUID
    ) -> Binding<Double> {
        Binding(
            get: {
                stops.first(where: { $0.id == id })?.location
                    ?? 0
            },
            set: { newValue in
                guard
                    let index = stops.firstIndex(
                        where: { $0.id == id }
                    )
                else { return }

                stops[index].location = newValue
                copied = false
            }
        )
    }

    // MARK: - Actions

    private func addStop() {
        guard stops.count < 10 else { return }

        let ordered = sortedStops

        let gaps = zip(
            ordered,
            ordered.dropFirst()
        )

        guard
            let largestGap = gaps.max(
                by: {
                    ($0.1.location - $0.0.location)
                        < ($1.1.location - $1.0.location)
                }
            )
        else { return }

        let midpoint = (largestGap.0.location + largestGap.1.location) / 2

        stops.append(
            SireliaGradientStop(
                color: largestGap.0.color,
                location: midpoint
            )
        )

        copied = false
    }

    private func removeStop(_ id: UUID) {
        guard stops.count > 2 else { return }

        stops.removeAll { $0.id == id }
        copied = false
    }

    private func resetGradient() {
        stops = [
            .init(color: .black, location: 0),
            .init(color: .blue, location: 1),
        ]

        angle = 135
        opacity = 1
        copied = false
    }

    // MARK: - SwiftUI Code Generation

    private var swiftUICode: String {
        let stopCode = sortedStops.map { stop in
            let c = stop.color.components

            return String(
                format: """
                    .init(
                        color: Color(
                            .sRGB,
                            red: %.4f,
                            green: %.4f,
                            blue: %.4f,
                            opacity: %.4f
                        ).opacity(%.4f),
                        location: %.4f
                    )
                    """,
                Double(c.red),
                Double(c.green),
                Double(c.blue),
                Double(c.alpha),
                opacity,
                stop.location
            )
        }
        .joined(separator: ",\n")

        return """
            LinearGradient(
                stops: [
            \(stopCode)
                ],
                startPoint: UnitPoint(
                    x: \(startPoint.x),
                    y: \(startPoint.y)
                ),
                endPoint: UnitPoint(
                    x: \(endPoint.x),
                    y: \(endPoint.y)
                )
            )
            """
    }
}

#Preview {
    NavigationStack {
        LinearGradientView()
    }
}
