import SwiftUI

/// 时针 / 分针 / 秒针 + 多层柔和中心帽
struct ClockHandsView: View {
    let theme: FaceTheme
    let size: CGFloat
    let hourDegrees: Double
    let minuteDegrees: Double
    let secondDegrees: Double

    var body: some View {
        ZStack {
            // 时针
            HandShape(style: .hour, theme: theme)
                .fill(theme.hourHand)
                .frame(width: size, height: size)
                .rotationEffect(.degrees(hourDegrees))
                .shadow(color: .black.opacity(theme.shadowOpacity * 0.6), radius: 2, y: 1)

            // 分针
            HandShape(style: .minute, theme: theme)
                .fill(theme.minuteHand)
                .frame(width: size, height: size)
                .rotationEffect(.degrees(minuteDegrees))
                .shadow(color: .black.opacity(theme.shadowOpacity * 0.5), radius: 1.5, y: 1)

            // 秒针（含尾部配重）
            HandShape(style: .second, theme: theme)
                .fill(theme.secondHand)
                .frame(width: size, height: size)
                .rotationEffect(.degrees(secondDegrees))

            // 多层柔和中心帽
            softCenterHub
        }
        .frame(width: size, height: size)
        .allowsHitTesting(false)
    }

    private var softCenterHub: some View {
        ZStack {
            // 外缘软晕
            Circle()
                .fill(theme.hubRing)
                .frame(width: size * 0.078, height: size * 0.078)
                .blur(radius: size * 0.006)

            // 金属感外环
            Circle()
                .stroke(theme.bezelInner.opacity(0.9), lineWidth: max(0.8, size * 0.004))
                .frame(width: size * 0.058, height: size * 0.058)

            // 主帽
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            theme.centerCap.opacity(0.92),
                            theme.centerCap
                        ],
                        center: UnitPoint(x: 0.35, y: 0.30),
                        startRadius: 0,
                        endRadius: size * 0.03
                    )
                )
                .frame(width: size * 0.048, height: size * 0.048)
                .shadow(color: .black.opacity(theme.shadowOpacity * 0.35), radius: 1.2, y: 0.6)

            // 内针脚色
            Circle()
                .fill(theme.centerCapInner)
                .frame(width: size * 0.018, height: size * 0.018)

            // 高光点
            Circle()
                .fill(Color.white.opacity(theme == .night || theme == .sport ? 0.35 : 0.55))
                .frame(width: size * 0.007, height: size * 0.007)
                .offset(x: -size * 0.006, y: -size * 0.006)
        }
    }
}

enum HandKind {
    case hour, minute, second
}

struct HandShape: Shape {
    let style: HandKind
    let theme: FaceTheme

    func path(in rect: CGRect) -> Path {
        let cx = rect.midX
        let cy = rect.midY
        let r = min(rect.width, rect.height) / 2

        switch style {
        case .hour:
            return taperedHand(
                cx: cx, cy: cy, r: r,
                length: hourLength,
                widthNearCenter: hourWidthNear,
                widthNearTip: hourWidthTip,
                tipBeyond: 0,
                counterLength: r * 0.08,
                leafTip: theme == .classic
            )
        case .minute:
            return taperedHand(
                cx: cx, cy: cy, r: r,
                length: minuteLength,
                widthNearCenter: minuteWidthNear,
                widthNearTip: minuteWidthTip,
                tipBeyond: 0,
                counterLength: r * 0.10,
                leafTip: theme == .classic
            )
        case .second:
            return secondHandPath(cx: cx, cy: cy, r: r)
        }
    }

    private var hourLength: CGFloat {
        switch theme {
        case .classic, .night: return 0.50
        case .minimal: return 0.48
        case .sport: return 0.50
        }
    }

    private var minuteLength: CGFloat {
        switch theme {
        case .classic: return 0.70
        case .night: return 0.72
        case .minimal: return 0.70
        case .sport: return 0.74
        }
    }

    private var hourWidthNear: CGFloat {
        switch theme {
        case .minimal: return 0.026
        case .classic: return 0.036
        default: return 0.034
        }
    }

    private var hourWidthTip: CGFloat {
        switch theme {
        case .minimal: return 0.012
        case .classic: return 0.014
        default: return 0.016
        }
    }

    private var minuteWidthNear: CGFloat {
        switch theme {
        case .minimal: return 0.016
        case .classic: return 0.024
        default: return 0.022
        }
    }

    private var minuteWidthTip: CGFloat {
        switch theme {
        case .minimal: return 0.007
        case .classic: return 0.008
        default: return 0.010
        }
    }

    private func taperedHand(
        cx: CGFloat, cy: CGFloat, r: CGFloat,
        length: CGFloat,
        widthNearCenter: CGFloat,
        widthNearTip: CGFloat,
        tipBeyond: CGFloat,
        counterLength: CGFloat,
        leafTip: Bool
    ) -> Path {
        let tipY = cy - r * length
        let baseY = cy + counterLength
        let halfNear = r * widthNearCenter / 2
        let halfTip = r * widthNearTip / 2

        var path = Path()
        path.move(to: CGPoint(x: cx - halfNear, y: cy))
        path.addLine(to: CGPoint(x: cx - halfTip, y: tipY + r * tipBeyond + (leafTip ? r * 0.035 : 0)))
        if leafTip {
            // 叶尖：收束到尖端再对称展开
            path.addQuadCurve(
                to: CGPoint(x: cx + halfTip, y: tipY + r * tipBeyond + r * 0.035),
                control: CGPoint(x: cx, y: tipY - r * 0.012)
            )
        } else {
            path.addLine(to: CGPoint(x: cx + halfTip, y: tipY + r * tipBeyond))
        }
        path.addLine(to: CGPoint(x: cx + halfNear, y: cy))
        path.addLine(to: CGPoint(x: cx + halfNear * 0.7, y: baseY))
        path.addLine(to: CGPoint(x: cx - halfNear * 0.7, y: baseY))
        path.closeSubpath()
        return path
    }

    private func secondHandPath(cx: CGFloat, cy: CGFloat, r: CGFloat) -> Path {
        let tipY = cy - r * 0.82
        let counterY = cy + r * 0.18
        let half = max(0.8, r * 0.005)
        let counterHalf = r * 0.018

        var path = Path()
        // 主针身
        path.addRect(CGRect(x: cx - half, y: tipY, width: half * 2, height: counterY - tipY))
        // 尖端圆头
        path.addEllipse(in: CGRect(
            x: cx - r * 0.012,
            y: tipY - r * 0.01,
            width: r * 0.024,
            height: r * 0.024
        ))
        // 尾部配重
        path.addEllipse(in: CGRect(
            x: cx - counterHalf,
            y: counterY - counterHalf,
            width: counterHalf * 2,
            height: counterHalf * 2
        ))
        // 经典：针身近中心处加一小菱形装饰
        if theme == .classic {
            let d = r * 0.022
            var diamond = Path()
            diamond.move(to: CGPoint(x: cx, y: cy - d * 1.6))
            diamond.addLine(to: CGPoint(x: cx + d * 0.7, y: cy))
            diamond.addLine(to: CGPoint(x: cx, y: cy + d * 1.2))
            diamond.addLine(to: CGPoint(x: cx - d * 0.7, y: cy))
            diamond.closeSubpath()
            path.addPath(diamond)
        }
        return path
    }
}
