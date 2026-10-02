import GoogleMobileAds
import SwiftUI
import UIKit

/// SwiftUI wrapper around Google Mobile Ads `BannerView` (UIKit).
struct BannerAdView: UIViewRepresentable {
    var adUnitID: String = AdMobConfig.bannerAdUnitID
    var width: CGFloat

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> BannerView {
        let size = currentOrientationAnchoredAdaptiveBanner(width: width)
        let banner = BannerView(adSize: size)
        banner.adUnitID = adUnitID
        banner.rootViewController = Self.keyRootViewController()
        banner.delegate = context.coordinator
        banner.load(Request())
        return banner
    }

    func updateUIView(_ uiView: BannerView, context: Context) {
        let size = currentOrientationAnchoredAdaptiveBanner(width: width)
        if uiView.adSize.size.width != size.size.width {
            uiView.adSize = size
            uiView.load(Request())
        }
        if uiView.rootViewController == nil {
            uiView.rootViewController = Self.keyRootViewController()
        }
    }

    /// Preferred height for layout reservation (adaptive min is 50pt).
    static func preferredHeight(forWidth width: CGFloat) -> CGFloat {
        currentOrientationAnchoredAdaptiveBanner(width: width).size.height
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
