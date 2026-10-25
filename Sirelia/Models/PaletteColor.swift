//
//  PaletteColor.swift
//  Sirelia
//
//  Created by Tufan Cakir on 24.10.26.
//

import SwiftUI

struct PaletteColor: Identifiable, Equatable, Codable {

    let id: UUID
    var color: Color

    var hex: String {
        color.toHexWithAlpha
    }

    init(
        id: UUID = UUID(),
        color: Color
    ) {
        self.id = id
        self.color = color
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case id
        case hex
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(
            keyedBy: CodingKeys.self
        )

        id = try container.decode(
            UUID.self,
            forKey: .id
        )

        let hex = try container.decode(
            String.self,
            forKey: .hex
        )

        guard let decodedColor = Color(hex: hex) else {
            throw DecodingError.dataCorruptedError(
                forKey: .hex,
                in: container,
                debugDescription: "Ungültiger HEX-Farbwert"
            )
        }

        color = decodedColor
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(
            keyedBy: CodingKeys.self
        )

        try container.encode(
            id,
            forKey: .id
        )

        try container.encode(
            hex,
            forKey: .hex
        )
    }

    static func == (
        lhs: PaletteColor,
        rhs: PaletteColor
    ) -> Bool {
        lhs.id == rhs.id && lhs.hex == rhs.hex
    }
}
