import SwiftUI

struct ContentView: View {
    @AppStorage("faceTheme") private var themeRaw: String = FaceTheme.classic.rawValue
    @AppStorage("secondHandMode") private var secondModeRaw: String = SecondHandMode.smooth.rawValue
    @EnvironmentObject private var removeAdsStore: RemoveAdsStore
    @State private var showSettings = false
    @State private var controlsVisible = true

    private var theme: FaceTheme {
        FaceTheme(rawValue: themeRaw) ?? .classic
    }

    private var secondMode: SecondHandMode {
        SecondHandMode(rawValue: secondModeRaw) ?? .smooth
    }

    private var adsRemoved: Bool { removeAdsStore.adsRemoved }

    var body: some View {
        GeometryReader { geo in
            let bannerWidth = max(geo.size.width, 320)
            // Reserve the standard 50pt banner height when ads are showing;
            // reclaim it completely after remove-ads.
            let bannerHeight = adsRemoved ? 0 : BannerAdView.preferredHeight()
            // Keep controls 8pt clear of the compact banner.
            let controlTopInset: CGFloat = adsRemoved ? 12 : bannerHeight + 8
            let controlBottomInset: CGFloat = adsRemoved ? 12 : bannerHeight + 8
            let reservedChrome: CGFloat = (adsRemoved ? 0 : bannerHeight * 2) + 24
            let usable = max(geo.size.height - reservedChrome, 120)
            let side = min(geo.size.width, usable)
            // When ads are gone, reclaim vertical space for a larger dial.
            let dialSize = side * (adsRemoved ? 0.94 : 0.88)

            ZStack {
                theme.background

                VStack(spacing: 0) {
                    Spacer(minLength: 0)

                    AnalogClockView(
                        theme: theme,
                        secondMode: secondMode,
                        size: dialSize
                    )
                    .frame(maxWidth: .infinity)

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 8)
                // Keep the dial band between the banner strips.
                .padding(.top, bannerHeight)
                .padding(.bottom, bannerHeight)

                // Mode / face controls — inset so they never sit under banners.
                VStack(spacing: 12) {
                    if controlsVisible {
                        topSecondModeBar
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    Spacer()

                    if controlsVisible {
                        bottomBar
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .padding(.top, controlTopInset)
                .padding(.bottom, controlBottomInset)
                .animation(.easeInOut(duration: 0.25), value: controlsVisible)
                .animation(.easeInOut(duration: 0.3), value: adsRemoved)

                // Top + bottom AdMob test banners pinned to edges (pass-through center).
                VStack(spacing: 0) {
                    if !adsRemoved {
                        BannerAdView()
                            .frame(width: bannerWidth, height: bannerHeight)
                            .frame(maxWidth: .infinity)
                            .background(Color.black.opacity(0.06))
                    }

                    Spacer(minLength: 0)
                        .allowsHitTesting(false)

                    if !adsRemoved {
                        BannerAdView()
                            .frame(width: bannerWidth, height: bannerHeight)
                            .frame(maxWidth: .infinity)
                            .background(Color.black.opacity(0.06))
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation { controlsVisible.toggle() }
            }
            .background(theme.background.ignoresSafeArea())
        }
        .statusBarHidden(true)
        .persistentSystemOverlays(.hidden)
        .sheet(isPresented: $showSettings) {
            SettingsPanel(themeRaw: $themeRaw, secondModeRaw: $secondModeRaw)
                .environmentObject(removeAdsStore)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .preferredColorScheme(theme == .night || theme == .sport ? .dark : .light)
        .animation(.easeInOut(duration: 0.3), value: adsRemoved)
    }

    /// 顶部：秒针模式切换
    private var topSecondModeBar: some View {
        HStack(spacing: 8) {
            ForEach(SecondHandMode.allCases) { mode in
                Button {
                    secondModeRaw = mode.rawValue
                } label: {
                    Text(mode.title)
                        .font(.subheadline.weight(secondMode == mode ? .semibold : .regular))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(secondMode == mode
                                      ? theme.secondHand.opacity(0.28)
                                      : Color.primary.opacity(0.08))
                        )
                        .overlay(
                            Capsule()
                                .stroke(secondMode == mode ? theme.secondHand.opacity(0.65) : .clear, lineWidth: 1)
                        )
                        .foregroundStyle(theme.majorTick)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            .ultraThinMaterial,
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        .padding(.horizontal, 16)
        .onTapGesture { }
    }

    private var bottomBar: some View {
        HStack(spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(FaceTheme.allCases) { face in
                        Button {
                            themeRaw = face.rawValue
                        } label: {
                            Text(face.title)
                                .font(.subheadline.weight(theme == face ? .semibold : .regular))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(theme == face
                                              ? theme.secondHand.opacity(0.25)
                                              : Color.primary.opacity(0.08))
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(theme == face ? theme.secondHand.opacity(0.6) : .clear, lineWidth: 1)
                                )
                                .foregroundStyle(theme.majorTick)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 4)
            }

            Button {
                showSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.title3)
                    .foregroundStyle(theme.majorTick)
                    .padding(10)
                    .background(Circle().fill(Color.primary.opacity(0.08)))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(String(localized: "设置"))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            .ultraThinMaterial,
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        .padding(.horizontal, 16)
        .onTapGesture { }
    }
}

#Preview {
    ContentView()
        .environmentObject(RemoveAdsStore())
}
