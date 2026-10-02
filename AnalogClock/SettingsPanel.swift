import SwiftUI

/// 设置面板：表盘主题 + 秒针模式
struct SettingsPanel: View {
    @Binding var themeRaw: String
    @Binding var secondModeRaw: String
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
                    Text("「秒跳1」在每秒跳动后带有短暂秒摆（过冲回弹）；「秒跳2」每秒跳跃 4 次（每分钟 240 步）。")
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { dismiss() }
                }
            }
        }
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
            // 简易指针示意
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
