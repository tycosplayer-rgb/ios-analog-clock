import GoogleMobileAds
import SwiftUI
import UIKit

/// SwiftUI wrapper around Google Mobile Ads `BannerView` (UIKit).
struct BannerAdView: UIViewRepresentable {
    var adUnitID: String = AdMobConfig.bannerAdUnitID

    /// Compact visual slot. The standard 320x50 ad is centered and clipped to 40pt.
    static let bannerHeight: CGFloat = 40

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.clipsToBounds = true

        let banner = BannerView(adSize: AdSizeBanner)
        banner.adUnitID = adUnitID
        banner.rootViewController = Self.keyRootViewController()
        banner.delegate = context.coordinator
        banner.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(banner)

        NSLayoutConstraint.activate([
            banner.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            banner.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            banner.widthAnchor.constraint(equalToConstant: AdSizeBanner.size.width),
            banner.heightAnchor.constraint(equalToConstant: AdSizeBanner.size.height)
        ])

        context.coordinator.bannerView = banner
        banner.load(Request())
        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard let banner = context.coordinator.bannerView else { return }

        if banner.adSize.size != AdSizeBanner.size {
            banner.adSize = AdSizeBanner
            banner.load(Request())
        }
        if banner.rootViewController == nil {
            banner.rootViewController = Self.keyRootViewController()
        }
    }

    /// Preferred height for layout reservation.
    static func preferredHeight() -> CGFloat {
        bannerHeight
    }

    private static func keyRootViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)?
            .rootViewController
    }

    final class Coordinator: NSObject, BannerViewDelegate {
        weak var bannerView: BannerView?

        func bannerViewDidReceiveAd(_ bannerView: BannerView) {
            // Test banners should load in Simulator / device when using Google test IDs.
        }

        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
            print("AdMob banner failed: \(error.localizedDescription)")
        }
    }
}
