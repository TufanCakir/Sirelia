//
//  StoreManager.swift
//  Sirelia
//
//  Created by Tufan Cakir on 24.10.26.
//

import Observation
import StoreKit

@MainActor
@Observable
final class StoreManager {
    static let proProductID = "com.sirelia.pro"

    private(set) var product: Product?
    private(set) var isPro = false
    private(set) var isLoading = false
    private(set) var errorMessage: LocalizedStringResource?

    func prepare() async {
        await refreshEntitlements()

        guard product == nil else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            product = try await Product.products(for: [Self.proProductID]).first
            if product == nil {
                errorMessage = "Sirelia Pro ist derzeit nicht verfügbar."
            }
        } catch {
            errorMessage = "Sirelia Pro konnte nicht geladen werden."
        }
    }

    func purchase() async {
        guard let product else {
            await prepare()
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            switch try await product.purchase() {
            case .success(let result):
                guard case .verified(let transaction) = result else {
                    errorMessage = "Der Kauf konnte nicht überprüft werden."
                    return
                }
                await transaction.finish()
                await refreshEntitlements()
            case .pending:
                errorMessage = "Der Kauf wartet noch auf Bestätigung."
            case .userCancelled:
                break
            @unknown default:
                errorMessage = "Der Kauf konnte nicht abgeschlossen werden."
            }
        } catch {
            errorMessage = "Der Kauf konnte nicht abgeschlossen werden."
        }
    }

    func restorePurchases() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await AppStore.sync()
            await refreshEntitlements()
            if !isPro {
                errorMessage =
                    "Es wurde kein früherer Kauf von Sirelia Pro gefunden."
            }
        } catch {
            errorMessage = "Käufe konnten nicht wiederhergestellt werden."
        }
    }

    func observeTransactionUpdates() async {
        for await result in Transaction.updates {
            if case .verified(let transaction) = result {
                await transaction.finish()
            }
            await refreshEntitlements()
        }
    }

    private func refreshEntitlements() async {
        var hasProEntitlement = false

        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result,
                transaction.productID == Self.proProductID,
                transaction.revocationDate == nil
            else {
                continue
            }
            hasProEntitlement = true
        }

        isPro = hasProEntitlement
    }
}
