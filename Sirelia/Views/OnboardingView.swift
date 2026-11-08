//
//  OnboardingView.swift
//  Sirelia
//
//  Created by Tufan Cakir on 25.10.26.
//

import SwiftUI

private enum OnboardingStep: Int {
    case colors
    case gradients
    case symbols

    var title: LocalizedStringResource {
        switch self {
        case .colors: "Deine Ideen. Deine Farben."
        case .gradients: "Bring Farbe in Bewegung."
        case .symbols: "Das passende Symbol."
        }
    }

    var message: LocalizedStringResource {
        switch self {
        case .colors:
            "Willkommen bei Sirelia. Entdecke Farben, passe ihre Werte präzise an und stelle deine eigene Palette zusammen."
        case .gradients:
            "Gestalte lineare, radiale, elliptische und winkelförmige Verläufe für deine nächste Idee."
        case .symbols:
            "Durchsuche SF Symbols und entdecke die passenden Symbole für dein Design. Alles beginnt mit einer Idee."
        }
    }

    var symbol: String {
        switch self {
        case .colors: "paintpalette.fill"
        case .gradients: "circle.lefthalf.filled"
        case .symbols: "sparkles"
        }
    }

    var colors: [Color] {
        switch self {
        case .colors: [.pink, .purple, .indigo]
        case .gradients: [.orange, .pink, .purple]
        case .symbols: [.cyan, .blue, .indigo]
        }
    }

    var next: Self {
        switch self {
        case .colors: .gradients
        case .gradients, .symbols: .symbols
        }
    }

    var previous: Self {
        switch self {
        case .colors, .gradients: .colors
        case .symbols: .gradients
        }
    }
}

struct OnboardingView: View {
    @State private var step: OnboardingStep = .colors

    let onComplete: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Sirelia")
                    .font(.headline)
                Spacer()
                Button("Überspringen", action: onComplete)
                    .font(.subheadline)
                    .frame(minHeight: 44)
            }
            .padding(.horizontal, 24)

            ScrollView {
                VStack(spacing: 32) {
                    OnboardingArtwork(symbol: step.symbol, colors: step.colors)
                    VStack(spacing: 16) {
                        Text(step.title)
                            .font(.largeTitle.bold())
                            .accessibilityAddTraits(.isHeader)
                        Text(step.message)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: 480)
                .frame(maxWidth: .infinity)
                .padding(24)
            }
            .defaultScrollAnchor(.center)
            .id(step)

            OnboardingControls(step: $step, onComplete: onComplete)
        }
        .background(.background)
    }
}

private struct OnboardingArtwork: View {
    let symbol: String
    let colors: [Color]

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 48)
                .fill(
                    LinearGradient(
                        colors: colors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Circle()
                .stroke(.white.opacity(0.2), lineWidth: 28)
                .padding(24)
            Circle()
                .fill(.white.opacity(0.12))
                .padding(58)
            Image(systemName: symbol)
                .font(.system(size: 76, weight: .medium))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.15), radius: 12, y: 6)
        }
        .frame(width: 240, height: 240)
        .rotationEffect(.degrees(-6))
        .padding(16)
        .accessibilityHidden(true)
    }
}

private struct OnboardingControls: View {
    @Binding var step: OnboardingStep
    let onComplete: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text("Schritt \(step.rawValue + 1) von 3")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button(action: {
                if step == .symbols {
                    onComplete()
                } else {
                    step = step.next
                }
            }) {
                Text(step == .symbols ? "Los geht’s" : "Weiter")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 32)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Button("Zurück") {
                step = step.previous
            }
            .frame(minHeight: 44)
            .disabled(step == .colors)
        }
        .frame(maxWidth: 480)
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    OnboardingView(onComplete: {})
}
