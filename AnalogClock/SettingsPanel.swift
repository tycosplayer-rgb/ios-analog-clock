import SwiftUI

/// 设置面板：表盘主题 + 秒针模式 + 去广告
struct SettingsPanel: View {
    @Binding var themeRaw: String
    @Binding var secondModeRaw: String
    @EnvironmentObject private var removeAdsStore: RemoveAdsStore
    @Environment(\.dismiss) private var dismiss

    private var theme: Binding<FaceTheme> {
        Binding(
            get: { FaceTheme(rawValue: themeRaw) ?? .classic },
            set: { themeRaw = $0.rawValue }
        )
    }

    private var secondMode: Binding<SecondHandMode> {
        Binding(
            get: { SecondHandMode(rawValue: secondModeRaw) ?? .smooth },
            set: { secondModeRaw = $0.rawValue }
        )
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(FaceTheme.allCases) { face in
                        Button {
                            theme.wrappedValue = face
                        } label: {
                            HStack(spacing: 14) {
                                FacePreviewChip(theme: face)
                                    .frame(width: 44, height: 44)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(face.title)
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                    Text(face.subtitle)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                if theme.wrappedValue == face {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.tint)
                                        .imageScale(.large)
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                } header: {
                    Text("表盘样式")
                }

                Section {
                    ForEach(SecondHandMode.allCases) { mode in
                        Button {
                            secondMode.wrappedValue = mode
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(mode.title)
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                    Text(mode.subtitle)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if secondMode.wrappedValue == mode {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.tint)
                                        .imageScale(.large)
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                } header: {
                    Text("秒针模式")
                } footer: {
                    Text("「秒跳1」每秒一跳，跳完后像老钟一样短暂颤一下就停；「秒跳2」每秒跳 4 格。")
                }

                Section {
                    if removeAdsStore.adsRemoved {
                        Label("已永久去除广告", systemImage: "checkmark.seal.fill")
                            .foregroundStyle(.green)
                    } else {
                        Button {
                            Task { await removeAdsStore.purchase() }
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("去广告（永久）")
                                        .font(.headline)
                                    Text(priceSubtitle)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if removeAdsStore.isLoading {
                                    ProgressView()
                                } else {
                                    Image(systemName: "cart.fill")
                                }
                            }
                        }
                        .disabled(removeAdsStore.isLoading)

                        Button {
                            Task { await removeAdsStore.restore() }
                        } label: {
                            HStack {
                                Text("恢复购买")
                                Spacer()
                                Image(systemName: "arrow.clockwise")
                            }
                        }
                        .disabled(removeAdsStore.isLoading)
                    }

                    if let message = removeAdsStore.errorMessage, !message.isEmpty {
                        Text(message)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                } header: {
                    Text("广告")
                } footer: {
                    Text("一次性买断，去掉顶部与底部横幅广告。本地可用 Products.storekit 测试；上架前请在 App Store Connect 创建同名商品 \(RemoveAdsStore.productID)。")
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { dismiss() }
                }
            }
            .task {
                if removeAdsStore.product == nil {
                    await removeAdsStore.loadProduct()
                }
            }
        }
    }

    private var priceSubtitle: String {
        if let product = removeAdsStore.product {
            return "永久移除横幅 · \(product.displayPrice)"
        }
        return "永久移除顶部和底部广告"
    }
}

/// 小预览圆点，展示主题配色
struct FacePreviewChip: View {
    let theme: FaceTheme

    var body: some View {
        ZStack {
            Circle()
                .fill(theme.dialFill)
            Circle()
                .stroke(theme.dialStroke, lineWidth: 2)
            Capsule()
                .fill(theme.hourHand)
                .frame(width: 3, height: 12)
                .offset(y: -4)
            Capsule()
                .fill(theme.secondHand)
                .frame(width: 1.5, height: 16)
                .offset(y: -2)
            Circle()
                .fill(theme.centerCap)
                .frame(width: 4, height: 4)
        }
        .background(theme.background.opacity(0.01))
    }
}
