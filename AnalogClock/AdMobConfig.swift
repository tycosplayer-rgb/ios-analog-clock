import Foundation

/// AdMob identifiers. Currently Google's **official test** IDs so the app
/// loads ads without an AdMob account. Replace before shipping:
/// 1. Create an app + banner units in https://admob.google.com
/// 2. Put your App ID in `Info.plist` (`GADApplicationIdentifier`)
/// 3. Put your banner unit ID in `bannerAdUnitID` below
enum AdMobConfig {
    /// Test App ID — also set in Info.plist as GADApplicationIdentifier
    static let testApplicationID = "ca-app-pub-3940256099942544~1458002511"

    /// Official Google test banner unit (320×50 / standard banner).
    static let bannerAdUnitID = "ca-app-pub-3940256099942544/2934735716"
}
