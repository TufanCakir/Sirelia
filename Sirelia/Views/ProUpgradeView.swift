//
//  ProUpgradeView.swift
//  Sirelia
//
//  Created by Tufan Cakir on 24.10.26.
//

import StoreKit
import SwiftUI

struct ProUpgradeView: View {
    @Environment(StoreManager.self) private var store
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ProHeaderSection()
                ProFeaturesSection()
                ProPurchaseSection()
            }
            .navigationTitle("Sirelia Pro")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fertig") {
                        dismiss()
                    }
                }
            }
            .onChange(of: store.isPro) {
                if store.isPro {
                    dismiss()
                }
            }
        }
    }
}

private struct ProHeaderSection: View {
    var body: some View {
        Section {
            VStack(spacing: 14) {
                Image(systemName: "sparkles")
                    .font(.system(size: 42))
                    .foregroundStyle(.tint)

                Text("Mehr Möglichkeiten für deine Farben")
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)

                Text("Einmal kaufen und Sirelia Pro dauerhaft verwenden.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical)
        }
    }
}

private struct ProFeaturesSection: View {
    var body: some View {
        Section("Enthalten") {
            Label(
                "Alle vier Gradient-Editoren",
                systemImage: "circle.lefthalf.filled"
            )
            Label("Präziser RGBA-Editor", systemImage: "slider.horizontal.3")
            Label("Dauerhafte Freischaltung", systemImage: "checkmark.seal")
        }
    }
}

private struct ProPurchaseSection: View {
    @Environment(StoreManager.self) private var store

    var body: some View {
        Section {
            if store.isPro {
                Label(
                    "Sirelia Pro ist freigeschaltet",
                    systemImage: "checkmark.circle.fill"
                )
                .foregroundStyle(.green)
            } else {
                Button {
                    Task {
                        await store.purchase()
                    }
                } label: {
                    HStack {
                        Text("Sirelia Pro kaufen")
                        Spacer()
                        if let product = store.product {
                            Text(product.displayPrice)
                        } else if store.isLoading {
                            ProgressView()
                        }
                    }
                }
                .disabled(store.product == nil || store.isLoading)

                Button("Käufe wiederherstellen") {
                    Task {
                        await store.restorePurchases()
                    }
                }
                .disabled(store.isLoading)
            }

            if let errorMessage = store.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        } footer: {
            Text(
                "Der Preis wird vom App Store angezeigt. Es handelt sich um einen einmaligen Kauf, nicht um ein Abonnement."
            )
        }
    }
}

#Preview {
    ProUpgradeView()
        .environment(StoreManager())
}
