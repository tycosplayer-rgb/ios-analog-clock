import SwiftUI

/// 时针 / 分针 / 秒针 + 中心帽
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

            // 中心帽
            Circle()
                .fill(theme.centerCap)
                .frame(width: size * 0.045, height: size * 0.045)
            Circle()
                .fill(theme.centerCapInner)
                .frame(width: size * 0.02, height: size * 0.02)
        }
        .frame(width: size, height: size)
        .allowsHitTesting(false)
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
                counterLength: r * 0.08
            )
        case .minute:
            return taperedHand(
                cx: cx, cy: cy, r: r,
                length: minuteLength,
                widthNearCenter: minuteWidthNear,
                widthNearTip: minuteWidthTip,
                tipBeyond: 0,
                counterLength: r * 0.10
            )
        case .second:
            return secondHandPath(cx: cx, cy: cy, r: r)
        }
    }

    private var hourLength: CGFloat {
        switch theme {
        case .classic, .night: return 0.52
        case .minimal: return 0.48
        case .sport: return 0.50
        }
    }

    private var minuteLength: CGFloat {
        switch theme {
        case .classic, .night: return 0.72
        case .minimal: return 0.70
        case .sport: return 0.74
        }
    }

    private var hourWidthNear: CGFloat { theme == .minimal ? 0.028 : 0.034 }
    private var hourWidthTip: CGFloat { theme == .minimal ? 0.014 : 0.018 }
    private var minuteWidthNear: CGFloat { theme == .minimal ? 0.018 : 0.022 }
    private var minuteWidthTip: CGFloat { theme == .minimal ? 0.008 : 0.010 }

    private func taperedHand(
        cx: CGFloat, cy: CGFloat, r: CGFloat,
        length: CGFloat,
        widthNearCenter: CGFloat,
        widthNearTip: CGFloat,
        tipBeyond: CGFloat,
        counterLength: CGFloat
    ) -> Path {
        let tipY = cy - r * length
        let baseY = cy + counterLength
        let halfNear = r * widthNearCenter / 2
        let halfTip = r * widthNearTip / 2

        var path = Path()
        path.move(to: CGPoint(x: cx - halfNear, y: cy))
        path.addLine(to: CGPoint(x: cx - halfTip, y: tipY + r * tipBeyond))
        path.addLine(to: CGPoint(x: cx + halfTip, y: tipY + r * tipBeyond))
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
        // 尖端小三角感：略加宽针尖附近圆形配重（上方）
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
        return path
    }
}
