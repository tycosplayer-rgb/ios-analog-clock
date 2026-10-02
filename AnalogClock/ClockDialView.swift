import SwiftUI

/// 表盘：刻度、数字、外圈、分钟轨与双层表圈
struct ClockDialView: View {
    let theme: FaceTheme
    let size: CGFloat

    var body: some View {
        ZStack {
            // 径向填充 + 暗角，营造立体表盘
            Circle()
                .fill(
                    RadialGradient(
                        colors: [theme.dialFillCenter, theme.dialFillEdge],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.52
                    )
                )
                .shadow(color: .black.opacity(theme.shadowOpacity), radius: size * 0.045, y: size * 0.018)

            // 经典：柔和内环晕影；夜黑/运动：微弱冷光
            softInnerWash

            // 中心软环（指针下方微光）
            Circle()
                .fill(
                    RadialGradient(
                        colors: [theme.hubRing, .clear],
                        center: .center,
                        startRadius: size * 0.02,
                        endRadius: size * 0.14
                    )
                )

            // 分钟轨：落在大刻度内侧、数字外侧
            Circle()
                .stroke(theme.minuteTrack, lineWidth: max(0.8, size * 0.0035))
                .padding(size * (1 - minuteTrackInset) / 2)

            // 双层表圈（外金属 + 内细环）
            bezelLayers

            // 内凹高光环
            Circle()
                .stroke(
                    LinearGradient(
                        colors: highlightGradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: max(1.5, size * 0.010)
                )
                .padding(size * 0.018)

            // 刻度（含整点强调）
            ticksCanvas

            // 数字：严格用 dialRadius = size/2
            if theme.showsNumerals {
                numeralsOverlay
            }
        }
        .frame(width: size, height: size)
    }

    // MARK: - Layers

    @ViewBuilder
    private var softInnerWash: some View {
        switch theme {
        case .classic:
            Circle()
                .stroke(
                    RadialGradient(
                        colors: [
                            Color(red: 0.75, green: 0.65, blue: 0.45).opacity(0.10),
                            .clear
                        ],
                        center: .center,
                        startRadius: size * 0.28,
                        endRadius: size * 0.48
                    ),
                    lineWidth: size * 0.08
                )
                .padding(size * 0.04)
        case .night:
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.25, green: 0.45, blue: 0.70).opacity(0.12),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.42
                    )
                )
        case .sport:
            Circle()
                .stroke(
                    Color(red: 1.0, green: 0.40, blue: 0.15).opacity(0.10),
                    lineWidth: size * 0.035
                )
                .padding(size * 0.06)
        case .minimal:
            EmptyView()
        }
    }

    private var bezelLayers: some View {
        ZStack {
            // 外圈主描边
            Circle()
                .stroke(theme.dialStroke, lineWidth: borderWidth)
                .padding(size * 0.004)

            // 内侧细环（双层表圈）
            Circle()
                .stroke(theme.bezelInner, lineWidth: max(0.8, size * 0.004))
                .padding(size * 0.012 + borderWidth * 0.35)

            // 经典：再加一圈温润金属外缘
            if theme == .classic {
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(red: 0.82, green: 0.72, blue: 0.52).opacity(0.85),
                                Color(red: 0.55, green: 0.45, blue: 0.30).opacity(0.65),
                                Color(red: 0.78, green: 0.68, blue: 0.48).opacity(0.75)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: max(1.2, size * 0.006)
                    )
                    .padding(size * 0.001)
            }
        }
    }

    private var highlightGradientColors: [Color] {
        switch theme {
        case .classic:
            return [
                .white.opacity(0.65),
                .clear,
                Color.black.opacity(0.10)
            ]
        case .night:
            return [
                Color.white.opacity(0.14),
                .clear,
                Color.black.opacity(0.40)
            ]
        case .sport:
            return [
                Color.white.opacity(0.16),
                .clear,
                Color.black.opacity(0.35)
            ]
        case .minimal:
            return [
                .white.opacity(0.45),
                .clear,
                Color.black.opacity(0.06)
            ]
        }
    }

    private var ticksCanvas: some View {
        Canvas { context, canvasSize in
            let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
            let radius = min(canvasSize.width, canvasSize.height) / 2

            for i in 0..<60 {
                let isMajor = i % 5 == 0
                let isQuarter = i % 15 == 0
                let angle = Double(i) * 6.0 - 90.0
                let rad = angle * .pi / 180.0

                let outer = radius * outerTickInset
                let inner: CGFloat
                if isQuarter {
                    inner = radius * quarterTickInner
                } else if isMajor {
                    inner = radius * majorTickInner
                } else {
                    inner = radius * minorTickInner
                }

                let tickWidth: CGFloat
                if isQuarter {
                    tickWidth = quarterTickWidth
                } else if isMajor {
                    tickWidth = majorTickWidth
                } else {
                    tickWidth = minorTickWidth
                }

                let color: Color
                if isQuarter {
                    color = theme.quarterTick
                } else if isMajor {
                    color = theme.majorTick
                } else {
                    color = theme.minorTick
                }

                var path = Path()
                path.move(to: CGPoint(
                    x: center.x + cos(rad) * inner,
                    y: center.y + sin(rad) * inner
                ))
                path.addLine(to: CGPoint(
                    x: center.x + cos(rad) * outer,
                    y: center.y + sin(rad) * outer
                ))
                context.stroke(
                    path,
                    with: .color(color),
                    style: StrokeStyle(lineWidth: tickWidth, lineCap: .round)
                )
            }
        }
    }

    // MARK: - Metrics

    private var borderWidth: CGFloat {
        switch theme.tickStyle {
        case .classic: return max(2.8, size * 0.020)
        case .luminous: return max(2.2, size * 0.015)
        case .thin: return max(1.4, size * 0.007)
        case .bold: return max(3.2, size * 0.024)
        }
    }

    /// 分钟轨相对直径的内缩（padding = size * (1 - inset) / 2 → 半径比例 = inset）
    private var minuteTrackInset: CGFloat {
        // 略小于 majorTickInner，保证环在刻度内侧
        switch theme.tickStyle {
        case .classic: return 0.805
        case .luminous: return 0.815
        case .thin: return 0.845
        case .bold: return 0.790
        }
    }

    private var outerTickInset: CGFloat {
        switch theme.tickStyle {
        case .classic, .luminous: return 0.915
        case .thin: return 0.935
        case .bold: return 0.895
        }
    }

    private var quarterTickInner: CGFloat {
        switch theme.tickStyle {
        case .classic: return 0.815
        case .luminous: return 0.825
        case .thin: return 0.860
        case .bold: return 0.795
        }
    }

    private var majorTickInner: CGFloat {
        switch theme.tickStyle {
        case .classic: return 0.835
        case .luminous: return 0.845
        case .thin: return 0.875
        case .bold: return 0.815
        }
    }

    private var minorTickInner: CGFloat {
        switch theme.tickStyle {
        case .classic: return 0.885
        case .luminous: return 0.895
        case .thin: return 0.915
        case .bold: return 0.870
        }
    }

    private var quarterTickWidth: CGFloat {
        switch theme.tickStyle {
        case .classic: return max(3.0, size * 0.017)
        case .luminous: return max(2.6, size * 0.014)
        case .thin: return max(1.8, size * 0.010)
        case .bold: return max(4.0, size * 0.022)
        }
    }

    private var majorTickWidth: CGFloat {
        switch theme.tickStyle {
        case .classic: return max(2.4, size * 0.013)
        case .luminous: return max(2.1, size * 0.011)
        case .thin: return max(1.4, size * 0.0075)
        case .bold: return max(3.2, size * 0.017)
        }
    }

    private var minorTickWidth: CGFloat {
        switch theme.tickStyle {
        case .classic: return max(1.0, size * 0.005)
        case .luminous: return max(0.9, size * 0.0045)
        case .thin: return max(0.7, size * 0.0035)
        case .bold: return max(1.3, size * 0.0065)
        }
    }

    // MARK: - Numerals

    private var numeralsOverlay: some View {
        let labels: [(Int, String)] = {
            switch theme {
            case .classic:
                return (1...12).map { ($0, "\($0)") }
            case .night:
                return (1...12).map { ($0, "\($0)") }
            case .sport:
                return [(12, "12"), (3, "3"), (6, "6"), (9, "9")]
            case .minimal:
                return []
            }
        }()

        return ZStack {
            ForEach(labels, id: \.0) { hour, text in
                let angle = Double(hour) * 30.0 - 90.0
                let rad = angle * .pi / 180.0
                // size 是直径；刻度用 size/2 为半径，数字必须同一坐标系
                let dialRadius = size / 2
                let r = dialRadius * numeralRadius
                Text(text)
                    .font(numeralFont)
                    .foregroundStyle(theme.numeral)
                    .shadow(
                        color: numeralShadowColor,
                        radius: theme == .night ? 3 : 0.5,
                        y: theme == .night ? 0 : 0.5
                    )
                    .position(
                        x: size / 2 + CGFloat(cos(rad)) * r,
                        y: size / 2 + CGFloat(sin(rad)) * r
                    )
            }
        }
        .frame(width: size, height: size)
        .allowsHitTesting(false)
    }

    private var numeralShadowColor: Color {
        switch theme {
        case .classic: return Color.black.opacity(0.08)
        case .night: return Color(red: 0.30, green: 0.70, blue: 1.0).opacity(0.45)
        case .sport: return Color.black.opacity(0.35)
        case .minimal: return .clear
        }
    }

    private var numeralRadius: CGFloat {
        // 大刻度内端约 0.82–0.85，分钟轨约 0.79–0.82；数字中心再往里，刚好不重叠
        switch theme {
        case .classic: return 0.725
        case .night: return 0.735
        case .sport: return 0.705
        case .minimal: return 0.72
        }
    }

    private var numeralFont: Font {
        switch theme {
        case .classic:
            return .system(size: size * 0.062, weight: .semibold, design: .serif)
        case .night:
            return .system(size: size * 0.058, weight: .light, design: .rounded)
        case .sport:
            return .system(size: size * 0.072, weight: .bold, design: .rounded)
        case .minimal:
            return .system(size: size * 0.052)
        }
    }
}
