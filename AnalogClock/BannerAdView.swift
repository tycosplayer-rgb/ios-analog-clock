import GoogleMobileAds
import SwiftUI
import UIKit

/// SwiftUI wrapper around Google Mobile Ads `BannerView` (UIKit).
struct BannerAdView: UIViewRepresentable {
    var adUnitID: String = AdMobConfig.bannerAdUnitID

    /// Standard AdMob banner: 320x50pt, avoiding the taller large-banner size.
    static let bannerHeight: CGFloat = AdSizeBanner.size.height

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: AdSizeBanner)
        banner.adUnitID = adUnitID
        banner.rootViewController = Self.keyRootViewController()
        banner.delegate = context.coordinator
        banner.load(Request())
        return banner
    }

    func updateUIView(_ uiView: BannerView, context: Context) {
        if uiView.adSize.size != AdSizeBanner.size {
            uiView.adSize = AdSizeBanner
            uiView.load(Request())
        }
        if uiView.rootViewController == nil {
            uiView.rootViewController = Self.keyRootViewController()
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
        func bannerViewDidReceiveAd(_ bannerView: BannerView) {
            // Test banners should load in Simulator / device when using Google test IDs.
        }

        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
            print("AdMob banner failed: \(error.localizedDescription)")
        }
    }
}
