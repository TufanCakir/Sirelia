//
//  PaletteManager.swift
//  Sirelia
//
//  Created by Tufan Cakir on 25.10.26.
//

import Combine
import SwiftUI

@MainActor
final class PaletteManager: ObservableObject {

    // MARK: - Storage

    private enum Storage {
        static let key = "SavedPaletteColors"
    }

    // MARK: - Published Properties

    @Published var savedColors: [PaletteColor] {
        didSet {
            saveColors()
        }
    }

    // MARK: - Computed Properties

    var isEmpty: Bool {
        savedColors.isEmpty
    }

    var count: Int {
        savedColors.count
    }

    // MARK: - Initialization

    init() {
        if let data = UserDefaults.standard.data(
            forKey: Storage.key
        ) {
            do {
                savedColors = try JSONDecoder().decode(
                    [PaletteColor].self,
                    from: data
                )
            } catch {
                // Vorhandene Daten bei einem Fehler
                // nicht automatisch überschreiben.
                savedColors = []
                print("Palette konnte nicht geladen werden: \(error)")
            }
        } else {
            savedColors = [
                PaletteColor(color: .red),
                PaletteColor(color: .green),
                PaletteColor(color: .blue),
            ]
        }
    }

    // MARK: - Add Color

    @discardableResult
    func addColor(_ color: Color) -> Bool {
        guard !contains(color) else {
            return false
        }

        savedColors.append(
            PaletteColor(color: color)
        )

        return true
    }

    // MARK: - Check Color

    func contains(_ color: Color) -> Bool {
        let hex = color.toHexWithAlpha

        return savedColors.contains {
            $0.color.toHexWithAlpha == hex
        }
    }

    // MARK: - Remove Color

    func removeColor(_ paletteColor: PaletteColor) {
        savedColors.removeAll {
            $0.id == paletteColor.id
        }
    }

    // MARK: - Remove by Color

    func removeColor(_ color: Color) {
        let hex = color.toHexWithAlpha

        savedColors.removeAll {
            $0.color.toHexWithAlpha == hex
        }
    }

    // MARK: - Clear Palette

    func removeAllColors() {
        guard !savedColors.isEmpty else {
            return
        }

        savedColors.removeAll()
    }

    // MARK: - Reset Palette

    func resetToDefaults() {
        savedColors = [
            PaletteColor(color: .red),
            PaletteColor(color: .green),
            PaletteColor(color: .blue),
        ]
    }

    // MARK: - Save

    private func saveColors() {
        do {
            let encoded = try JSONEncoder().encode(
                savedColors
            )

            UserDefaults.standard.set(
                encoded,
                forKey: Storage.key
            )
        } catch {
            print("Palette konnte nicht gespeichert werden: \(error)")
        }
    }
}
