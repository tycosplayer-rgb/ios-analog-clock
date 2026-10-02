import SwiftUI

/// 表盘主题
enum FaceTheme: String, CaseIterable, Identifiable {
    case classic = "classic"
    case night = "night"
    case minimal = "minimal"
    case sport = "sport"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .classic: return "经典"
        case .night: return "夜黑"
        case .minimal: return "极简"
        case .sport: return "运动"
        }
    }

    var subtitle: String {
        switch self {
        case .classic: return "浅色罗马风格"
        case .night: return "深色夜光"
        case .minimal: return "极简无数字"
        case .sport: return "高对比运动风"
        }
    }

    // MARK: - Colors

    var background: Color {
        switch self {
        case .classic: return Color(red: 0.96, green: 0.95, blue: 0.92)
        case .night: return Color(red: 0.06, green: 0.07, blue: 0.10)
        case .minimal: return Color(red: 0.98, green: 0.98, blue: 0.97)
        case .sport: return Color(red: 0.08, green: 0.09, blue: 0.11)
        }
    }

    var dialFill: Color {
        switch self {
        case .classic: return Color(red: 0.99, green: 0.98, blue: 0.96)
        case .night: return Color(red: 0.10, green: 0.11, blue: 0.14)
        case .minimal: return Color.white
        case .sport: return Color(red: 0.12, green: 0.13, blue: 0.16)
        }
    }

    var dialStroke: Color {
        switch self {
        case .classic: return Color(red: 0.55, green: 0.48, blue: 0.38).opacity(0.45)
        case .night: return Color(red: 0.35, green: 0.55, blue: 0.75).opacity(0.55)
        case .minimal: return Color.black.opacity(0.08)
        case .sport: return Color(red: 0.95, green: 0.35, blue: 0.15).opacity(0.7)
        }
    }

    var majorTick: Color {
        switch self {
        case .classic: return Color(red: 0.22, green: 0.20, blue: 0.18)
        case .night: return Color(red: 0.75, green: 0.88, blue: 1.0)
        case .minimal: return Color(red: 0.15, green: 0.15, blue: 0.15)
        case .sport: return Color.white
        }
    }

    var minorTick: Color {
        switch self {
        case .classic: return Color(red: 0.45, green: 0.40, blue: 0.35).opacity(0.65)
        case .night: return Color(red: 0.45, green: 0.55, blue: 0.70).opacity(0.55)
        case .minimal: return Color.black.opacity(0.18)
        case .sport: return Color.white.opacity(0.35)
        }
    }

    var numeral: Color {
        switch self {
        case .classic: return Color(red: 0.18, green: 0.16, blue: 0.14)
        case .night: return Color(red: 0.70, green: 0.85, blue: 1.0)
        case .minimal: return Color.clear // 极简不显示数字
        case .sport: return Color(red: 1.0, green: 0.45, blue: 0.20)
        }
    }

    var hourHand: Color {
        switch self {
        case .classic: return Color(red: 0.15, green: 0.13, blue: 0.11)
        case .night: return Color(red: 0.85, green: 0.92, blue: 1.0)
        case .minimal: return Color(red: 0.12, green: 0.12, blue: 0.12)
        case .sport: return Color.white
        }
    }

    var minuteHand: Color {
        switch self {
        case .classic: return Color(red: 0.20, green: 0.18, blue: 0.15)
        case .night: return Color(red: 0.70, green: 0.82, blue: 0.95)
        case .minimal: return Color(red: 0.25, green: 0.25, blue: 0.25)
        case .sport: return Color(red: 0.90, green: 0.92, blue: 0.95)
        }
    }

    var secondHand: Color {
        switch self {
        case .classic: return Color(red: 0.72, green: 0.18, blue: 0.16)
        case .night: return Color(red: 0.30, green: 0.75, blue: 1.0)
        case .minimal: return Color(red: 0.85, green: 0.25, blue: 0.20)
        case .sport: return Color(red: 1.0, green: 0.40, blue: 0.15)
        }
    }

    var centerCap: Color {
        switch self {
        case .classic: return Color(red: 0.15, green: 0.13, blue: 0.11)
        case .night: return Color(red: 0.85, green: 0.92, blue: 1.0)
        case .minimal: return Color(red: 0.12, green: 0.12, blue: 0.12)
        case .sport: return Color(red: 1.0, green: 0.40, blue: 0.15)
        }
    }

    var centerCapInner: Color {
        switch self {
        case .classic: return Color(red: 0.72, green: 0.18, blue: 0.16)
        case .night: return Color(red: 0.30, green: 0.75, blue: 1.0)
        case .minimal: return Color(red: 0.85, green: 0.25, blue: 0.20)
        case .sport: return Color.white
        }
    }

    var shadowOpacity: Double {
        switch self {
        case .classic: return 0.18
        case .night: return 0.45
        case .minimal: return 0.08
        case .sport: return 0.35
        }
    }

    /// 是否绘制阿拉伯数字
    var showsNumerals: Bool {
        self != .minimal
    }

    /// 刻度风格
    var tickStyle: TickStyle {
        switch self {
        case .classic: return .classic
        case .night: return .luminous
        case .minimal: return .thin
        case .sport: return .bold
        }
    }

    enum TickStyle {
        case classic, luminous, thin, bold
    }
}
