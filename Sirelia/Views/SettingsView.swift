//
//  SettingsView.swift
//  Sirelia
//
//  Created by Tufan Cakir on 24.10.26.
//

import SwiftUI

enum AppAppearance: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: Self { self }

    var title: LocalizedStringResource {
        switch self {
        case .system: "System"
        case .light: "Hell"
        case .dark: "Dunkel"
        }
    }

    var systemImage: String {
        switch self {
        case .system: "circle.lefthalf.filled"
        case .light: "sun.max"
        case .dark: "moon"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

enum AppLanguage: String, CaseIterable, Identifiable {
    case system
    case german
    case english

    var id: Self { self }

    var title: LocalizedStringResource {
        switch self {
        case .system: "Systemsprache"
        case .german: "Deutsch"
        case .english: "Englisch"
        }
    }

    var locale: Locale {
        switch self {
        case .system: .autoupdatingCurrent
        case .german: Locale(identifier: "de")
        case .english: Locale(identifier: "en-GB")
        }
    }
}

struct SettingsView: View {
    @AppStorage("sirelia.appearance")
    private var appearance: AppAppearance = .system

    @AppStorage("sirelia.language")
    private var language: AppLanguage = .system

    var body: some View {
        Form {
            AppearanceSettingsSection(
                appearance: $appearance
            )

            LanguageSettingsSection(
                language: $language
            )
        }
        .navigationTitle("Einstellungen")
    }
}

private struct AppearanceSettingsSection: View {
    @Binding var appearance: AppAppearance

    var body: some View {
        Section {
            Picker("Erscheinungsbild", selection: $appearance) {
                ForEach(AppAppearance.allCases) { option in
                    Label(option.title, systemImage: option.systemImage)
                        .tag(option)
                }
            }
            .pickerStyle(.navigationLink)
        } header: {
            Text("Darstellung")
        } footer: {
            Text(
                "Mit „System“ folgt Sirelia automatisch dem Erscheinungsbild des iPhone."
            )
        }
    }
}

private struct LanguageSettingsSection: View {
    @Binding var language: AppLanguage

    var body: some View {
        Section {
            Picker("App-Sprache", selection: $language) {
                ForEach(AppLanguage.allCases) { option in
                    Text(option.title)
                        .tag(option)
                }
            }
            .pickerStyle(.navigationLink)
        } header: {
            Text("Sprache")
        } footer: {
            Text(
                "Mit „Systemsprache“ verwendet Sirelia automatisch die bevorzugte Sprache des iPhone."
            )
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
