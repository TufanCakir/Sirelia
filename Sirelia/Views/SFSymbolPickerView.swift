//
//  SFSymbolPickerView.swift
//  Sirelia
//
//  Created by Tufan Cakir on 24.10.26.
//

import SwiftUI

struct SFSymbolPickerView: View {

    @State private var searchText = ""
    @State private var selectedCategory = "Alle"

    @State private var selectedColor: Color = .blue
    @State private var secondaryColor: Color = .red

    @State private var symbolSize: Double = 30
    @State private var displayMode: SymbolDisplayMode = .monochrome

    @State private var selectedSymbol: SelectedSFSymbol?
    @State private var favorites: Set<String> = []
    @State private var copyFeedbackTrigger = 0

    @AppStorage("sirelia.favoriteSymbols")
    private var favoritesData = Data()

    private struct SelectedSFSymbol: Identifiable {
        let name: String
        var id: String { name }
    }

    private enum SymbolDisplayMode: String, CaseIterable, Identifiable {
        case monochrome
        case hierarchical
        case palette
        case multicolor

        var id: Self { self }

        var title: LocalizedStringResource {
            switch self {
            case .monochrome: "Monochrom"
            case .hierarchical: "Hierarchisch"
            case .palette: "Palette"
            case .multicolor: "Mehrfarbig"
            }
        }
    }

    private let categories = [
        "Alle",
        "Neue Funktionen",
        "Zeichnen",
        "Variabel",
        "bunt",
        "Kommunikation",
        "Wetter",
        "Karten",
        "Objekte & Werkzeuge",
        "Geräte",
        "Kamera & Fotos",
        "Spiele",
        "Verbindungen",
        "Transport",
        "Automobil",
        "Bedienungshilfen",
        "Datenschutz & Sicherheit",
        "Menschen",
        "Zuhause",
        "Fitness",
        "Natur",
        "Bearbeitung",
        "Textformatierung",
        "Medien",
        "Tastatur",
        "Handel",
        "Ziel",
        "Gesundheit",
        "Formen",
        "Pfeile",
        "Indizes",
        "Mathematik",
    ]

    private let symbolsByCategory: [String: [String]] = [
        "Neue Funktionen": [
            "folder.and.person",
            "calendar.day",
            "star.calendar",
            "app.grid.2x2.topleft.filled",
            "app.grid.2x2.topleading.filled",
            "app.grid.2x2.topleft.dashed",
            "app.grid.2x2.topleading.dashed",
            "app.grid.2x2.bottom.dashed",
            "app.grid.2x2",
            "app.grid.2x2.fill",
            "app.grid.2x2.and.person.fill",
            "widget.grid.2x1.rectangle",
            "person.badge.creditcard",
            "person.wave.2.inward",
            "person.number.sign.rectangle",
            "figure.2.ascending",
            "figure.2.descending",
            "figure.stand.and.figure.teen", "globe.and.person",
            "square.dashed.micro",
            "inset.left.half.square.dashed.micro",
            "inset.left.half.filled.square.dashed.micro",
            "inset.square.dashed.micro",
            "inset.filled.square.dashed.micro",
            "square.grid.month",
            "squareshape.on.pattern.diagonalline",
            "inset.filled.lefthalf.arrowtriangle.left.rectangle",
            "inset.filled.righthalf.arrowtriangle.right.rectangle",
            "inset.filled.leadinghalf.arrowtriangle.backward.rectangle",
            "inset.filled.trailinghalf.arrowtriangle.forward.rectangle",
            "arrowtriangle.left.inset.filled.leftthird.rectangle",
            "arrowtriangle.right.inset.filled.rightthird.rectangle",
            "arrowtriangle.backward.leadingside.rectangle",
            "arrowtriangle.forward.trailingside.rectangle",
            "arrowtriangle.left.leftside.rectangle",
            "arrowtriangle.right.rightside.rectangle",
            "capsule.on.rectangle.liquid.glass",
            "circle.on.app.liquid.glass",
            "inset.filled.bubble",
            "bubble.left.and.heart.bubble.right",
            "siri.gen1",
            "siri.gen2",
            "eyedropper.and.sparkles",
            "person.building.classical",
            "light.tube.rays",
            "laptopcomputer.display.clean",
            "rectangle.3.portrait.pano",
            "airpods.pro.gen1",
            "airpods.pro.gen1.right",
            "airpods.pro.gen1.left",
            "airpods.pro.gen1.chargingcase.wireless",
            "airpods.pro.gen1.chargingcase.wireless.radiowaves.left.and.right",
            "airpods.pro.gen3",
            "airpods.pro.gen3.right",
            "airpods.pro.gen3.left",
            "airpods.pro.gen3.chargingcase.wireless",
            "airpods.pro.gen3.chargingcase.wireless.radiowaves.left.and.right",
            "rectangle.stack.and.person",
            "car.card",
            "fuelpump.nozzle.and.drop",
            "motor.electric.vehicle",
            "vent.airflow.diffused",
            "vent.airflow.focused",
            "vent.airflow.oscillating",
            "vent.airflow.manual",
            "figure.teen",
            "figure.teen.and.lock",
            "figure.teen.and.lock.open", "shoe.running.and.shadow.fill",
            "viewfinder.and.person",
            "ring.light",
            "interface.window.dashed",
            "interface.window.on.rectangle.dashed",
            "xmark.interface.window",
            "text.page.and.line.vertical.and.text.page",
            "cube.plane.bottom.right.detached",
            "scope.continuous",
            "gauge.range.33to100.dotted.with.needle",
            "pl.button.horizontal",
            "pr.button.horizontal",
            "pizza.slice",
            "cellularbars.short.cellularbars",
            "text.menu",
        ],
        "Geräte": [],
        "Kommunikation": [],
        "Bearbeitung": [],
    ]

    // MARK: - Main View
    var body: some View {
        VStack(spacing: 0) {
            controlsSection

            categorySection

            Divider()

            TabView(selection: $selectedCategory) {
                ForEach(categories, id: \.self) { category in
                    symbolPage(for: category)
                        .tag(category)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .navigationTitle("SF Symbols")
        .searchable(
            text: $searchText,
            prompt: "Symbolnamen suchen"
        )
        .sheet(item: $selectedSymbol) { selection in
            symbolDetail(selection.name)
        }
        .task {
            favorites = decodeFavorites()
        }
        .sensoryFeedback(.success, trigger: copyFeedbackTrigger)
    }

    private func symbolPage(for category: String) -> some View {
        let symbols = filteredSymbols(for: category)

        return ScrollView {
            LazyVGrid(
                columns: columns,
                spacing: 12
            ) {
                ForEach(symbols, id: \.self) { symbol in
                    symbolCard(symbol)
                }
            }
            .padding()
        }
        .overlay {
            if symbols.isEmpty {
                ContentUnavailableView(
                    "Keine Symbole gefunden",
                    systemImage: "magnifyingglass",
                    description: Text(
                        "Für diese Kategorie sind noch keine Symbole hinterlegt."
                    )
                )
            }
        }
    }

    // MARK: - Controls

    private var controlsSection: some View {
        VStack {
            HStack {
                ColorPicker(
                    "Farbe",
                    selection: $selectedColor,
                    supportsOpacity: true
                )

                ColorPicker(
                    "Zweitfarbe",
                    selection: $secondaryColor,
                    supportsOpacity: true
                )
            }

            Picker(
                "Darstellung",
                selection: $displayMode
            ) {
                ForEach(SymbolDisplayMode.allCases) { mode in
                    Text(mode.title)
                        .tag(mode)
                }
            }
            .pickerStyle(.menu)

            HStack {
                Image(systemName: "textformat.size.smaller")

                Slider(
                    value: $symbolSize,
                    in: 18...50,
                    step: 1
                )

                Image(systemName: "textformat.size.larger")
            }
            .accessibilityLabel("Symbolgröße")
        }
        .padding()
    }

    // MARK: - Categories

    private var categorySection: some View {
        ScrollViewReader { proxy in
            ScrollView(
                .horizontal,
                showsIndicators: false
            ) {
                HStack {
                    ForEach(categories, id: \.self) { category in
                        Button {
                            selectedCategory = category
                        } label: {
                            Text(category)
                                .font(.subheadline)
                                .fontWeight(
                                    selectedCategory == category
                                        ? .semibold
                                        : .regular
                                )
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(
                                    selectedCategory == category
                                        ? Color.accentColor.opacity(0.15)
                                        : Color.secondary.opacity(0.08),
                                    in: Capsule()
                                )
                        }
                        .buttonStyle(.plain)
                        .accessibilityAddTraits(
                            selectedCategory == category ? .isSelected : []
                        )
                        .id(category)
                    }
                }
                .padding(.horizontal)
            }
            .onChange(of: selectedCategory) { _, category in
                withAnimation(.easeInOut(duration: 0.2)) {
                    proxy.scrollTo(
                        category,
                        anchor: .center
                    )
                }
            }
        }
    }

    // MARK: - Symbol Card

    private func symbolCard(
        _ symbol: String
    ) -> some View {
        Button {
            selectedSymbol = SelectedSFSymbol(name: symbol)
        } label: {
            VStack(spacing: 10) {
                renderedSymbol(symbol)
                    .font(.system(size: symbolSize))
                    .frame(height: 48)

                Text(symbol)
                    .font(.caption2)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(
                Color.secondary.opacity(0.06),
                in: RoundedRectangle(cornerRadius: 14)
            )
            .overlay(alignment: .topTrailing) {
                if favorites.contains(symbol) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundStyle(.yellow)
                        .padding(6)
                        .accessibilityHidden(true)
                }
            }
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                copy(symbol)
            } label: {
                Label("Symbolname kopieren", systemImage: "doc.on.doc")
            }

            Button {
                toggleFavorite(symbol)
            } label: {
                Label(
                    favorites.contains(symbol)
                        ? "Aus Favoriten entfernen"
                        : "Zu Favoriten hinzufügen",
                    systemImage: favorites.contains(symbol)
                        ? "star.slash"
                        : "star"
                )
            }
        }
        .accessibilityLabel("Symbol \(symbol)")
        .accessibilityHint("Öffnet Details und Exportoptionen")
    }

    // MARK: - Symbol Rendering

    @ViewBuilder
    private func renderedSymbol(
        _ symbol: String
    ) -> some View {
        switch displayMode {
        case .monochrome:
            Image(systemName: symbol)
                .symbolRenderingMode(.monochrome)
                .foregroundStyle(selectedColor)

        case .hierarchical:
            Image(systemName: symbol)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(selectedColor)

        case .palette:
            Image(systemName: symbol)
                .symbolRenderingMode(.palette)
                .foregroundStyle(
                    selectedColor,
                    secondaryColor
                )

        case .multicolor:
            Image(systemName: symbol)
                .symbolRenderingMode(.multicolor)
        }
    }

    // MARK: - Detail View

    private func symbolDetail(
        _ symbol: String
    ) -> some View {
        NavigationStack {
            Form {
                Section("Vorschau") {
                    HStack {
                        Spacer()

                        renderedSymbol(symbol)
                            .font(.system(size: 100))
                            .frame(height: 160)

                        Spacer()
                    }
                }

                Section("Symbolname") {
                    Text(symbol)
                        .font(.system(.body, design: .monospaced))
                        .textSelection(.enabled)

                    Button {
                        copy(symbol)
                    } label: {
                        Label(
                            "Symbolname kopieren",
                            systemImage: "doc.on.doc"
                        )
                    }
                }

                Section("SwiftUI") {
                    Text(swiftUICode(for: symbol))
                        .font(.system(.caption, design: .monospaced))
                        .textSelection(.enabled)

                    Button {
                        copy(swiftUICode(for: symbol))
                    } label: {
                        Label(
                            "SwiftUI-Code kopieren",
                            systemImage: "curlybraces"
                        )
                    }

                    ShareLink(
                        item: swiftUICode(for: symbol)
                    ) {
                        Label(
                            "Code teilen",
                            systemImage: "square.and.arrow.up"
                        )
                    }
                }

                Section {
                    Button {
                        toggleFavorite(symbol)
                    } label: {
                        Label(
                            favorites.contains(symbol)
                                ? "Aus Favoriten entfernen"
                                : "Zu Favoriten hinzufügen",
                            systemImage: favorites.contains(symbol)
                                ? "star.slash"
                                : "star"
                        )
                    }
                }
            }
            .navigationTitle("Symbol")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fertig") {
                        selectedSymbol = nil
                    }
                }
            }
        }
    }

    // MARK: - Favorites

    private func toggleFavorite(
        _ symbol: String
    ) {
        var updated = favorites

        if updated.contains(symbol) {
            updated.remove(symbol)
        } else {
            updated.insert(symbol)
        }

        favorites = updated
        favoritesData = (try? JSONEncoder().encode(updated)) ?? Data()
    }

    // MARK: - Clipboard

    private func copy(
        _ text: String
    ) {
        UIPasteboard.general.string = text
        copyFeedbackTrigger += 1
    }

    // MARK: - SwiftUI Export

    private func swiftUICode(
        for symbol: String
    ) -> String {
        let mode: String

        switch displayMode {
        case .monochrome:
            mode = ".monochrome"
        case .hierarchical:
            mode = ".hierarchical"
        case .palette:
            mode = ".palette"
        case .multicolor:
            mode = ".multicolor"
        }

        return """
            Image(systemName: "\(symbol)")
                .symbolRenderingMode(\(mode))
                .font(.system(size: \(Int(symbolSize))))
            """
    }

    private let columns = [
        GridItem(.adaptive(minimum: 90), spacing: 12)
    ]

    private func decodeFavorites() -> Set<String> {
        (try? JSONDecoder().decode(
            Set<String>.self,
            from: favoritesData
        )) ?? []
    }

    private var allSymbols: [String] {
        Array(Set(symbolsByCategory.values.flatMap { $0 })).sorted()
    }

    private func filteredSymbols(for category: String) -> [String] {
        let symbols: [String]

        if category == "Alle" {
            symbols = allSymbols
        } else {
            symbols = symbolsByCategory[category] ?? []
        }

        return searchText.isEmpty
            ? symbols
            : symbols.filter {
                $0.localizedCaseInsensitiveContains(searchText)
            }
    }
}

#Preview {
    NavigationStack {
        SFSymbolPickerView()
    }
}
