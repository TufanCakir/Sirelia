//
//  GradientLibraryView.swift
//  Sirelia
//
//  Created by Tufan Cakir on 25.10.26.
//

import SwiftUI

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

struct GradientLibraryView: View {

    @Environment(StoreManager.self) private var store
    @State private var isShowingPro = false

    var body: some View {
        List {
            Section {
                ForEach(GradientType.allCases) { type in
                    if store.isPro {
                        NavigationLink {
                            destination(for: type)
                        } label: {
                            GradientLibraryRow(type: type, isLocked: false)
                        }
                    } else {
                        Button {
                            isShowingPro = true
                        } label: {
                            GradientLibraryRow(type: type, isLocked: true)
                        }
                        .buttonStyle(.plain)
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
        .sheet(isPresented: $isShowingPro) {
            ProUpgradeView()
        }
    }
}

private struct GradientLibraryRow: View {
    let type: GradientType
    let isLocked: Bool

    var body: some View {
        HStack(spacing: 14) {
            gradientPreview
                .frame(width: 76, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 5) {
                Text(type.title)
                    .font(.headline)

                Text(type.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if isLocked {
                Image(systemName: "lock.fill")
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("Nur mit Sirelia Pro")
            }
        }
        .padding(.vertical, 5)
    }

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

extension GradientLibraryView {
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

#Preview {
    NavigationStack {
        GradientLibraryView()
    }
    .environment(StoreManager())
}
