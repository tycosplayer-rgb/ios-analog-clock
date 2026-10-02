import SwiftUI

/// 表盘：刻度、数字、外圈
struct ClockDialView: View {
    let theme: FaceTheme
    let size: CGFloat

    var body: some View {
        ZStack {
            // 外圈阴影盘
            Circle()
                .fill(theme.dialFill)
                .shadow(color: .black.opacity(theme.shadowOpacity), radius: size * 0.04, y: size * 0.015)

            // 细微内凹高光环
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            .white.opacity(theme == .night || theme == .sport ? 0.12 : 0.55),
                            .clear,
                            .black.opacity(theme == .night || theme == .sport ? 0.35 : 0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: max(2, size * 0.012)
                )
                .padding(size * 0.01)

            // 边框
            Circle()
                .stroke(theme.dialStroke, lineWidth: borderWidth)
                .padding(size * 0.005)

            // 刻度
            Canvas { context, canvasSize in
                let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
                let radius = min(canvasSize.width, canvasSize.height) / 2

                for i in 0..<60 {
                    let isMajor = i % 5 == 0
                    let angle = Double(i) * 6.0 - 90.0
                    let rad = angle * .pi / 180.0

                    let outer = radius * outerTickInset
                    let inner: CGFloat
                    if isMajor {
                        inner = radius * majorTickInner
                    } else {
                        inner = radius * minorTickInner
                    }

                    let tickWidth: CGFloat = isMajor ? majorTickWidth : minorTickWidth
                    let color = isMajor ? theme.majorTick : theme.minorTick

                    var path = Path()
                    path.move(to: CGPoint(
                        x: center.x + cos(rad) * inner,
                        y: center.y + sin(rad) * inner
                    ))
                    path.addLine(to: CGPoint(
                        x: center.x + cos(rad) * outer,
                        y: center.y + sin(rad) * outer
                    ))
                    context.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: tickWidth, lineCap: .round))
                }
            }

            // 数字
            if theme.showsNumerals {
                numeralsOverlay
            }
        }
        .frame(width: size, height: size)
    }

    private var borderWidth: CGFloat {
        switch theme.tickStyle {
        case .classic: return max(2.5, size * 0.018)
        case .luminous: return max(2, size * 0.014)
        case .thin: return max(1.5, size * 0.008)
        case .bold: return max(3, size * 0.022)
        }
    }

    private var outerTickInset: CGFloat {
        switch theme.tickStyle {
        case .classic, .luminous: return 0.92
        case .thin: return 0.94
        case .bold: return 0.90
        }
    }

    private var majorTickInner: CGFloat {
        switch theme.tickStyle {
        case .classic: return 0.84
        case .luminous: return 0.85
        case .thin: return 0.88
        case .bold: return 0.82
        }
    }

    private var minorTickInner: CGFloat {
        switch theme.tickStyle {
        case .classic: return 0.89
        case .luminous: return 0.90
        case .thin: return 0.92
        case .bold: return 0.88
        }
    }

    private var majorTickWidth: CGFloat {
        switch theme.tickStyle {
        case .classic: return max(2.5, size * 0.014)
        case .luminous: return max(2.2, size * 0.012)
        case .thin: return max(1.5, size * 0.008)
        case .bold: return max(3.5, size * 0.018)
        }
    }

    private var minorTickWidth: CGFloat {
        switch theme.tickStyle {
        case .classic: return max(1.2, size * 0.006)
        case .luminous: return max(1.0, size * 0.005)
        case .thin: return max(0.8, size * 0.004)
        case .bold: return max(1.5, size * 0.007)
        }
    }

    private var numeralsOverlay: some View {
        let labels: [(Int, String)] = {
            switch theme {
            case .classic:
                // 罗马数字风格用阿拉伯也可；这里用清晰阿拉伯数字
                return (1...12).map { ($0, "\($0)") }
            case .night:
                return (1...12).map { ($0, "\($0)") }
            case .sport:
                // 运动风：仅 12/3/6/9
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
                    .position(
                        x: size / 2 + CGFloat(cos(rad)) * r,
                        y: size / 2 + CGFloat(sin(rad)) * r
                    )
            }
        }
        .frame(width: size, height: size)
        .allowsHitTesting(false)
    }

    private var numeralRadius: CGFloat {
        // 相对表盘半径：大刻度内端约 0.84，数字中心略往里，刚好不重叠
        switch theme {
        case .classic: return 0.72
        case .night: return 0.73
        case .sport: return 0.70
        case .minimal: return 0.72
        }
    }

    private var numeralFont: Font {
        switch theme {
        case .classic:
            return .system(size: size * 0.065, weight: .medium, design: .serif)
        case .night:
            return .system(size: size * 0.06, weight: .light, design: .rounded)
        case .sport:
            return .system(size: size * 0.075, weight: .bold, design: .rounded)
        case .minimal:
            return .system(size: size * 0.055)
        }
    }
}
