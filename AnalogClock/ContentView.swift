import SwiftUI

struct ContentView: View {
    @AppStorage("faceTheme") private var themeRaw: String = FaceTheme.classic.rawValue
    @AppStorage("secondHandMode") private var secondModeRaw: String = SecondHandMode.smooth.rawValue
    @State private var showSettings = false
    @State private var controlsVisible = true

    private var theme: FaceTheme {
        FaceTheme(rawValue: themeRaw) ?? .classic
    }

    private var secondMode: SecondHandMode {
        SecondHandMode(rawValue: secondModeRaw) ?? .smooth
    }

    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            // 几乎占满安全区，略留边给控件与呼吸感
            let dialSize = side * 0.92

            ZStack {
                theme.background
                    .ignoresSafeArea()

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

                // 底部轻量控制条（不遮挡大表盘）
                VStack {
                    Spacer()
                    if controlsVisible {
                        bottomBar
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .animation(.easeInOut(duration: 0.25), value: controlsVisible)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation { controlsVisible.toggle() }
            }
        }
        .statusBarHidden(true)
        .persistentSystemOverlays(.hidden)
        .sheet(isPresented: $showSettings) {
            SettingsPanel(themeRaw: $themeRaw, secondModeRaw: $secondModeRaw)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .preferredColorScheme(theme == .night || theme == .sport ? .dark : .light)
    }

    private var bottomBar: some View {
        HStack(spacing: 12) {
            // 快速切换表盘（横向芯片）
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
            .accessibilityLabel("设置")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            .ultraThinMaterial,
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
        // 阻止点击穿透到背后的显隐手势
        .onTapGesture { }
    }
}

#Preview {
    ContentView()
}
