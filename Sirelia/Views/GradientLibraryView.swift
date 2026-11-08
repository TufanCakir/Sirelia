//
//  GradientLibraryView.swift
//  Sirelia
//
//  Created by Tufan Cakir on 25.10.26.
//

import SwiftUI

// MARK: - Gradient Type

private enum GradientType: String, CaseIterable, Identifiable {
    case linear
    case radial
    case angular
    case elliptical

    var id: String { rawValue }

    var title: LocalizedStringResource {
        switch self {
        case .linear: "Linear"
        case .radial: "Radial"
        case .angular: "Angular"
        case .elliptical: "Elliptical"
        }
    }

    var subtitle: LocalizedStringResource {
        switch self {
        case .linear:
            "Geradliniger Farbverlauf"
        case .radial:
            "Kreisförmiger Farbverlauf"
        case .angular:
            "Farbverlauf um einen Mittelpunkt"
        case .elliptical:
            "Elliptischer Farbverlauf"
        }
    }

    var symbol: String {
        switch self {
        case .linear: "arrow.down.right"
        case .radial: "circle.dotted"
        case .angular: "arrow.clockwise"
        case .elliptical: "oval"
        }
    }
}

// MARK: - Gradient Library

struct GradientLibraryView: View {
    var body: some View {
        List {
            Section {
                ForEach(GradientType.allCases) { type in
                    NavigationLink {
                        destination(for: type)
                    } label: {
                        GradientLibraryRow(type: type)
                    }
                }
            } header: {
                Text("Gradient-Editoren")
            } footer: {
                Text(
                    "Wähle einen Verlaufstyp, um Farben, Positionen und weitere Eigenschaften anzupassen."
                )
            }
        }
        .navigationTitle("Verläufe")
    }

    // MARK: - Navigation

    @ViewBuilder
    fileprivate func destination(
        for type: GradientType
    ) -> some View {
        switch type {
        case .linear:
            LinearGradientView()
        case .radial:
            RadialGradientView()
        case .angular:
            AngularGradientView()
        case .elliptical:
            EllipticalGradientView()
        }
    }
}

// MARK: - Gradient Row

private struct GradientLibraryRow: View {
    let type: GradientType

    var body: some View {
        HStack(spacing: 14) {
            gradientPreview
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

    // MARK: - Gradient Preview

    @ViewBuilder
    private var gradientPreview: some View {
        switch type {
        case .linear:
            LinearGradient(
                colors: [.indigo, .cyan],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

        case .radial:
            RadialGradient(
                colors: [.cyan, .indigo],
                center: .center,
                startRadius: 0,
                endRadius: 65
            )

        case .angular:
            AngularGradient(
                colors: [.cyan, .purple, .pink, .cyan],
                center: .center
            )

        case .elliptical:
            EllipticalGradient(
                colors: [.cyan, .indigo],
                center: .center,
                startRadiusFraction: 0,
                endRadiusFraction: 0.7
            )
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        GradientLibraryView()
    }
}
