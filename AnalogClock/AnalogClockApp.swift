import GoogleMobileAds
import SwiftUI

@main
struct AnalogClockApp: App {
    @StateObject private var removeAdsStore = RemoveAdsStore()

    init() {
        // Required before loading any ads. Uses GADApplicationIdentifier from Info.plist.
        MobileAds.shared.start(completionHandler: nil)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(removeAdsStore)
                .task {
                    await removeAdsStore.loadProduct()
                }
                .onAppear {
                    UIApplication.shared.isIdleTimerDisabled = true
                }
                .onDisappear {
                    UIApplication.shared.isIdleTimerDisabled = false
                }
        }
    }
}
