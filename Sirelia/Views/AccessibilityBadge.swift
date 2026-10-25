//
//  AccessibilityBadge.swift
//  Sirelia
//
//  Created by Tufan Cakir on 25.10.26.
//

import SwiftUI

// MARK: - WCAG Text Type

enum WCAGContentType: String, CaseIterable {
    case normalText
    case largeText
    case uiComponent

    var title: String {
        switch self {
        case .normalText:
            "Normaler Text"
        case .largeText:
            "Großer Text"
        case .uiComponent:
            "UI-Komponente"
        }
    }
}

// MARK: - WCAG Level

enum WCAGLevel {
    case aaa
    case aa
    case largeAA
    case fail

    var title: String {
        switch self {
        case .aaa:
            "AAA"
        case .aa:
            "AA"
        case .largeAA:
            "AA Groß"
        case .fail:
            "Nicht bestanden"
        }
    }

    var symbol: String {
        switch self {
        case .aaa:
            "checkmark.seal.fill"
        case .aa:
            "checkmark.circle.fill"
        case .largeAA:
            "checkmark.circle"
        case .fail:
            "xmark.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .aaa, .aa:
            .green
        case .largeAA:
            .orange
        case .fail:
            .red
        }
    }
}

// MARK: - Accessibility Badge

struct AccessibilityBadge: View {

    let contrastRatio: Double
    var contentType: WCAGContentType = .normalText

    private var level: WCAGLevel {
        guard contrastRatio.isFinite,
            contrastRatio >= 1
        else {
            return .fail
        }

        switch contentType {
        case .normalText:
            if contrastRatio >= 7 {
                return .aaa
            } else if contrastRatio >= 4.5 {
                return .aa
            } else if contrastRatio >= 3 {
                return .largeAA
            } else {
                return .fail
            }

        case .largeText:
            if contrastRatio >= 4.5 {
                return .aaa
            } else if contrastRatio >= 3 {
                return .aa
            } else {
                return .fail
            }

        case .uiComponent:
            return contrastRatio >= 3 ? .aa : .fail
        }
    }

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: level.symbol)
                .font(.system(size: 11, weight: .semibold))

            Text(level.title)
                .font(.caption2.weight(.semibold))
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 6)
        .foregroundStyle(level.color)
        .background(
            level.color.opacity(0.12),
            in: Capsule()
        )
        .overlay {
            Capsule()
                .strokeBorder(
                    level.color.opacity(0.25),
                    lineWidth: 1
                )
        }
        .fixedSize(horizontal: true, vertical: false)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityDescription)
    }

    private var accessibilityDescription: String {
        let ratio = String(
            format: "%.2f",
            contrastRatio
        )

        return "\(contentType.title): Kontrast \(ratio) zu 1, \(level.title)"
    }
}

// MARK: - Preview

#Preview {
    VStack(alignment: .leading, spacing: 16) {
        AccessibilityBadge(contrastRatio: 9.5)
        AccessibilityBadge(contrastRatio: 5.2)
        AccessibilityBadge(contrastRatio: 3.5)
        AccessibilityBadge(contrastRatio: 2.1)

        Divider()

        AccessibilityBadge(
            contrastRatio: 3.5,
            contentType: .largeText
        )

        AccessibilityBadge(
            contrastRatio: 3.5,
            contentType: .uiComponent
        )
    }
    .padding()
}
