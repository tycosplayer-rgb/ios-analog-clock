import Foundation
import StoreKit

/// StoreKit 2 helper for the non-consumable "Remove Ads" product.
@MainActor
final class RemoveAdsStore: ObservableObject {
    static let productID = "com.tycosplayer.analogclock.removeads"

    @Published private(set) var product: Product?
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    /// Bound to AppStorage / UserDefaults from the UI.
    @Published var adsRemoved: Bool {
        didSet {
            UserDefaults.standard.set(adsRemoved, forKey: Self.adsRemovedKey)
        }
    }

    private static let adsRemovedKey = "adsRemoved"
    private var updatesTask: Task<Void, Never>?

    init() {
        adsRemoved = UserDefaults.standard.bool(forKey: Self.adsRemovedKey)
        updatesTask = Task { await listenForTransactions() }
    }

    deinit {
        updatesTask?.cancel()
    }

    func loadProduct() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let products = try await Product.products(for: [Self.productID])
            product = products.first
            await refreshEntitlements()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func purchase() async {
        guard let product else {
            errorMessage = "商品尚未加载，请稍后重试。"
            await loadProduct()
            return
        }
        isLoading = true
        defer { isLoading = false }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                adsRemoved = true
                await transaction.finish()
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Restores prior non-consumable purchases (also re-checks current entitlements).
    func restore() async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await AppStore.sync()
            await refreshEntitlements()
            if !adsRemoved {
                errorMessage = "未找到可恢复的购买。"
            } else {
                errorMessage = nil
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refreshEntitlements() async {
        var owned = false
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result),
               transaction.productID == Self.productID {
                owned = true
                break
            }
        }
        adsRemoved = owned
    }

    private func listenForTransactions() async {
        for await result in Transaction.updates {
            if let transaction = try? checkVerified(result),
               transaction.productID == Self.productID {
                adsRemoved = true
                await transaction.finish()
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let value):
            return value
        }
    }
}
