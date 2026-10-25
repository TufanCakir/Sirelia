//
//  extension.swift
//  Sirelia
//
//  Created by Tufan Cakir on 24.10.26.
//

import SwiftUI
import UIKit

// MARK: - Color Extensions

extension Color {

    // MARK: - RGBA Components

    var components:
        (
            red: CGFloat,
            green: CGFloat,
            blue: CGFloat,
            alpha: CGFloat
        )
    {
        let color = UIColor(self)

        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        // Standard conversion
        if color.getRed(
            &red,
            green: &green,
            blue: &blue,
            alpha: &alpha
        ) {
            return (
                red.clampedToUnit,
                green.clampedToUnit,
                blue.clampedToUnit,
                alpha.clampedToUnit
            )
        }

        // Fallback through sRGB
        if let converted = color.cgColor.converted(
            to: CGColorSpace(name: CGColorSpace.sRGB)!,
            intent: .defaultIntent,
            options: nil
        ) {
            let fallback = UIColor(cgColor: converted)

            if fallback.getRed(
                &red,
                green: &green,
                blue: &blue,
                alpha: &alpha
            ) {
                return (
                    red.clampedToUnit,
                    green.clampedToUnit,
                    blue.clampedToUnit,
                    alpha.clampedToUnit
                )
            }
        }

        return (0, 0, 0, 1)
    }

    // MARK: - HEX

    var toHex: String {
        let rgba = components

        return String(
            format: "#%02X%02X%02X",
            Int((rgba.red * 255).rounded()),
            Int((rgba.green * 255).rounded()),
            Int((rgba.blue * 255).rounded())
        )
    }

    // Includes alpha in RRGGBBAA order
    var toHexWithAlpha: String {
        let rgba = components

        return String(
            format: "#%02X%02X%02X%02X",
            Int((rgba.red * 255).rounded()),
            Int((rgba.green * 255).rounded()),
            Int((rgba.blue * 255).rounded()),
            Int((rgba.alpha * 255).rounded())
        )
    }

    // MARK: - RGB / RGBA

    var toRgbString: String {
        let rgba = components

        return String(
            format: "rgb(%d, %d, %d)",
            Int((rgba.red * 255).rounded()),
            Int((rgba.green * 255).rounded()),
            Int((rgba.blue * 255).rounded())
        )
    }

    var toRgbaString: String {
        let rgba = components

        return String(
            format: "rgba(%d, %d, %d, %.3f)",
            locale: Locale(identifier: "en_US_POSIX"),
            Int((rgba.red * 255).rounded()),
            Int((rgba.green * 255).rounded()),
            Int((rgba.blue * 255).rounded()),
            Double(rgba.alpha)
        )
    }

    // MARK: - HEX Initializer

    init?(hex: String) {
        var value =
            hex
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if value.hasPrefix("#") {
            value.removeFirst()
        }

        guard [3, 4, 6, 8].contains(value.count),
            value.allSatisfy(\.isHexDigit),
            let number = UInt64(value, radix: 16)
        else {
            return nil
        }

        let red: UInt64
        let green: UInt64
        let blue: UInt64
        let alpha: UInt64

        switch value.count {
        case 3:
            red = ((number >> 8) & 0xF) * 17
            green = ((number >> 4) & 0xF) * 17
            blue = (number & 0xF) * 17
            alpha = 255

        case 4:
            red = ((number >> 12) & 0xF) * 17
            green = ((number >> 8) & 0xF) * 17
            blue = ((number >> 4) & 0xF) * 17
            alpha = (number & 0xF) * 17

        case 6:
            red = (number >> 16) & 0xFF
            green = (number >> 8) & 0xFF
            blue = number & 0xFF
            alpha = 255

        default:
            red = (number >> 24) & 0xFF
            green = (number >> 16) & 0xFF
            blue = (number >> 8) & 0xFF
            alpha = number & 0xFF
        }

        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: Double(alpha) / 255
        )
    }

    // MARK: - WCAG Relative Luminance

    var luminance: CGFloat {
        let rgba = components

        func linearize(_ value: CGFloat) -> CGFloat {
            if value <= 0.04045 {
                return value / 12.92
            }

            return pow(
                (value + 0.055) / 1.055,
                2.4
            )
        }

        return 0.2126 * linearize(rgba.red)
            + 0.7152 * linearize(rgba.green)
            + 0.0722 * linearize(rgba.blue)
    }

    // MARK: - Contrast Ratio

    func contrastRatio(with color: Color) -> CGFloat {
        let first = luminance
        let second = color.luminance

        let lighter = max(first, second)
        let darker = min(first, second)

        return (lighter + 0.05) / (darker + 0.05)
    }

    // MARK: - Color Mixing

    func mixed(
        with other: Color,
        amount: CGFloat
    ) -> Color {
        let first = components
        let second = other.components
        let fraction = amount.clampedToUnit

        return Color(
            .sRGB,
            red: Double(
                first.red + (second.red - first.red) * fraction
            ),
            green: Double(
                first.green + (second.green - first.green) * fraction
            ),
            blue: Double(
                first.blue + (second.blue - first.blue) * fraction
            ),
            opacity: Double(
                first.alpha + (second.alpha - first.alpha) * fraction
            )
        )
    }

    // MARK: - SwiftUI Export

    var swiftUICode: String {
        let rgba = components
        let locale = Locale(identifier: "en_US_POSIX")

        return String(
            format: """
                Color(
                    .sRGB,
                    red: %.4f,
                    green: %.4f,
                    blue: %.4f,
                    opacity: %.4f
                )
                """,
            locale: locale,
            Double(rgba.red),
            Double(rgba.green),
            Double(rgba.blue),
            Double(rgba.alpha)
        )
    }
}

// MARK: - CGFloat Helpers

extension CGFloat {
    fileprivate var clampedToUnit: CGFloat {
        guard isFinite else { return 0 }

        return Swift.min(
            Swift.max(self, 0),
            1
        )
    }
}
