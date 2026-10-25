//
//  RadialGradientView.swift
//  Sirelia
//
//  Created by Tufan Cakir on 25.10.26.
//

import SwiftUI
import UIKit

// MARK: - Radial Color Stop

private struct RadialColorStop: Identifiable {
    let id = UUID()
    var color: Color
    var location: Double
}

// MARK: - Radial Gradient View

struct RadialGradientView: View {

    @State private var stops: [RadialColorStop] = [
        .init(color: .black, location: 0),
        .init(color: .blue, location: 1),
    ]

    @State private var centerX: Double = 0.5
    @State private var centerY: Double = 0.5

    @State private var startRadius: Double = 0
    @State private var endRadius: Double = 200

    @State private var opacity: Double = 1
    @State private var copied = false

    // MARK: - Computed Properties

    private var sortedStops: [RadialColorStop] {
        stops.sorted { $0.location < $1.location }
    }

    private var centerPoint: UnitPoint {
        UnitPoint(x: centerX, y: centerY)
    }

    private var gradient: RadialGradient {
        RadialGradient(
            stops: sortedStops.map {
                Gradient.Stop(
                    color: $0.color.opacity(opacity),
                    location: $0.location
                )
            },
            center: centerPoint,
            startRadius: startRadius,
            endRadius: endRadius
        )
    }

    // MARK: - Body

    var body: some View {
        Form {
            previewSection
            colorStopsSection
            centerSection
            radiusSection
            opacitySection
            presetsSection
            exportSection
        }
        .navigationTitle("Radial Gradient")
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
            GeometryReader { geometry in
                ZStack {
                    CheckerboardView(cellSize: 12)

                    gradient

                    Circle()
                        .strokeBorder(
                            .white.opacity(0.9),
                            lineWidth: 2
                        )
                        .background {
                            Circle()
                                .fill(.black.opacity(0.3))
                        }
                        .frame(width: 18, height: 18)
                        .position(
                            x: geometry.size.width * centerX,
                            y: geometry.size.height * centerY
                        )
                        .allowsHitTesting(false)
                }
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
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            guard geometry.size.width > 0,
                                geometry.size.height > 0
                            else { return }

                            centerX = min(
                                max(
                                    value.location.x / geometry.size.width,
                                    0
                                ),
                                1
                            )

                            centerY = min(
                                max(
                                    value.location.y / geometry.size.height,
                                    0
                                ),
                                1
                            )

                            copied = false
                        }
                )
                .accessibilityLabel("Radialer Farbverlauf")
                .accessibilityHint(
                    "Mittelpunkt über die Regler verändern"
                )
            }
            .frame(height: 220)

            HStack {
                Label(
                    "Radial",
                    systemImage: "circle.dotted"
                )

                Spacer()

                Text(
                    "X \(Int(centerX * 100))% · Y \(Int(centerY * 100))%"
                )
                .monospacedDigit()
                .foregroundStyle(.secondary)
            }
            .font(.subheadline)
        }
    }

    // MARK: - Color Stops

    private var colorStopsSection: some View {
        Section {
            ForEach(stops) { stop in
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
                "Jeder Farbpunkt besitzt eine eigene Farbe und Position."
            )
        }
    }

    private func stopRow(
        for stop: RadialColorStop
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

    // MARK: - Center

    private var centerSection: some View {
        Section("Mittelpunkt") {
            VStack(spacing: 12) {
                HStack {
                    Text("Horizontal (X)")

                    Spacer()

                    Text("\(Int((centerX * 100).rounded()))%")
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }

                Slider(
                    value: $centerX,
                    in: 0...1,
                    step: 0.01
                )

                HStack {
                    Text("Vertikal (Y)")

                    Spacer()

                    Text("\(Int((centerY * 100).rounded()))%")
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }

                Slider(
                    value: $centerY,
                    in: 0...1,
                    step: 0.01
                )

                Button {
                    centerX = 0.5
                    centerY = 0.5
                } label: {
                    Label(
                        "Mittelpunkt zentrieren",
                        systemImage: "scope"
                    )
                }
                .buttonStyle(.borderless)
            }
            .padding(.vertical, 4)
        }
    }

    // MARK: - Radius

    private var radiusSection: some View {
        Section("Radius") {
            VStack(spacing: 12) {
                HStack {
                    Text("Startradius")

                    Spacer()

                    Text("\(Int(startRadius)) pt")
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }

                Slider(
                    value: $startRadius,
                    in: 0...max(0, endRadius - 1),
                    step: 1
                )

                HStack {
                    Text("Endradius")

                    Spacer()

                    Text("\(Int(endRadius)) pt")
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }

                Slider(
                    value: $endRadius,
                    in: max(1, startRadius + 1)...600,
                    step: 1
                )
            }
            .padding(.vertical, 4)
        }
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
                    colors: [.yellow, .orange, .red],
                    title: "Sonne"
                )

                presetButton(
                    colors: [.cyan, .blue, .purple],
                    title: "Neon"
                )

                presetButton(
                    colors: [.white, .gray, .black],
                    title: "Mono"
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
            let lastIndex = colors.count - 1

            stops = colors.enumerated().map { index, color in
                RadialColorStop(
                    color: color,
                    location: Double(index) / Double(lastIndex)
                )
            }

            centerX = 0.5
            centerY = 0.5
            startRadius = 0
            endRadius = 200
            opacity = 1
            copied = false

        } label: {
            VStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        RadialGradient(
                            colors: colors,
                            center: .center,
                            startRadius: 0,
                            endRadius: 55
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

            ShareLink(item: swiftUICode) {
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
            set: { newLocation in
                guard
                    let index = stops.firstIndex(
                        where: { $0.id == id }
                    )
                else { return }

                stops[index].location = newLocation
                copied = false
            }
        )
    }

    // MARK: - Actions

    private func addStop() {
        guard stops.count < 10 else { return }

        let ordered = sortedStops

        guard
            let gap = zip(
                ordered,
                ordered.dropFirst()
            ).max(
                by: {
                    ($0.1.location - $0.0.location)
                        < ($1.1.location - $1.0.location)
                }
            )
        else { return }

        let midpoint = (gap.0.location + gap.1.location) / 2

        stops.append(
            RadialColorStop(
                color: gap.0.color,
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

        centerX = 0.5
        centerY = 0.5
        startRadius = 0
        endRadius = 200
        opacity = 1
        copied = false
    }

    // MARK: - SwiftUI Code Export

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
            RadialGradient(
                stops: [
            \(stopCode)
                ],
                center: UnitPoint(
                    x: \(centerX),
                    y: \(centerY)
                ),
                startRadius: \(startRadius),
                endRadius: \(endRadius)
            )
            """
    }
}

#Preview {
    NavigationStack {
        RadialGradientView()
    }
}
