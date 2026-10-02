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
        case .classic: return Color(red: 0.94, green: 0.92, blue: 0.88)
        case .night: return Color(red: 0.04, green: 0.05, blue: 0.08)
        case .minimal: return Color(red: 0.97, green: 0.97, blue: 0.96)
        case .sport: return Color(red: 0.06, green: 0.07, blue: 0.09)
        }
    }

    /// 表盘中心填充（径向渐变内侧）
    var dialFillCenter: Color {
        switch self {
        case .classic: return Color(red: 1.0, green: 0.995, blue: 0.98)
        case .night: return Color(red: 0.14, green: 0.16, blue: 0.20)
        case .minimal: return Color.white
        case .sport: return Color(red: 0.16, green: 0.17, blue: 0.21)
        }
    }

    /// 表盘边缘填充（径向渐变 / 暗角）
    var dialFillEdge: Color {
        switch self {
        case .classic: return Color(red: 0.93, green: 0.90, blue: 0.84)
        case .night: return Color(red: 0.07, green: 0.08, blue: 0.11)
        case .minimal: return Color(red: 0.96, green: 0.96, blue: 0.95)
        case .sport: return Color(red: 0.08, green: 0.09, blue: 0.12)
        }
    }

    /// 兼容旧调用：取中心色
    var dialFill: Color { dialFillCenter }

    /// 外圈金属/主题描边
    var dialStroke: Color {
        switch self {
        case .classic: return Color(red: 0.62, green: 0.52, blue: 0.36).opacity(0.70)
        case .night: return Color(red: 0.40, green: 0.62, blue: 0.88).opacity(0.55)
        case .minimal: return Color.black.opacity(0.10)
        case .sport: return Color(red: 0.98, green: 0.38, blue: 0.14).opacity(0.85)
        }
    }

    /// 双层表圈内侧细环
    var bezelInner: Color {
        switch self {
        case .classic: return Color(red: 0.78, green: 0.68, blue: 0.48).opacity(0.55)
        case .night: return Color(red: 0.55, green: 0.75, blue: 1.0).opacity(0.28)
        case .minimal: return Color.black.opacity(0.05)
        case .sport: return Color.white.opacity(0.18)
        }
    }

    /// 分钟轨（刻度内侧细环）
    var minuteTrack: Color {
        switch self {
        case .classic: return Color(red: 0.55, green: 0.48, blue: 0.38).opacity(0.22)
        case .night: return Color(red: 0.45, green: 0.65, blue: 0.90).opacity(0.22)
        case .minimal: return Color.black.opacity(0.06)
        case .sport: return Color(red: 1.0, green: 0.45, blue: 0.18).opacity(0.28)
        }
    }

    /// 中心软环（指针下方微光）
    var hubRing: Color {
        switch self {
        case .classic: return Color(red: 0.55, green: 0.48, blue: 0.38).opacity(0.14)
        case .night: return Color(red: 0.40, green: 0.70, blue: 1.0).opacity(0.16)
        case .minimal: return Color.black.opacity(0.05)
        case .sport: return Color(red: 1.0, green: 0.40, blue: 0.15).opacity(0.18)
        }
    }

    var majorTick: Color {
        switch self {
        case .classic: return Color(red: 0.18, green: 0.15, blue: 0.12)
        case .night: return Color(red: 0.78, green: 0.90, blue: 1.0)
        case .minimal: return Color(red: 0.12, green: 0.12, blue: 0.12)
        case .sport: return Color.white
        }
    }

    var minorTick: Color {
        switch self {
        case .classic: return Color(red: 0.42, green: 0.36, blue: 0.30).opacity(0.55)
        case .night: return Color(red: 0.48, green: 0.58, blue: 0.72).opacity(0.50)
        case .minimal: return Color.black.opacity(0.16)
        case .sport: return Color.white.opacity(0.32)
        }
    }

    /// 整点刻度（12/3/6/9）强调色
    var quarterTick: Color {
        switch self {
        case .classic: return Color(red: 0.12, green: 0.10, blue: 0.08)
        case .night: return Color(red: 0.85, green: 0.94, blue: 1.0)
        case .minimal: return Color(red: 0.10, green: 0.10, blue: 0.10)
        case .sport: return Color(red: 1.0, green: 0.48, blue: 0.18)
        }
    }

    var numeral: Color {
        switch self {
        case .classic: return Color(red: 0.14, green: 0.12, blue: 0.10)
        case .night: return Color(red: 0.72, green: 0.86, blue: 1.0)
        case .minimal: return Color.clear
        case .sport: return Color(red: 1.0, green: 0.48, blue: 0.20)
        }
    }

    var hourHand: Color {
        switch self {
        case .classic: return Color(red: 0.12, green: 0.10, blue: 0.08)
        case .night: return Color(red: 0.88, green: 0.94, blue: 1.0)
        case .minimal: return Color(red: 0.10, green: 0.10, blue: 0.10)
        case .sport: return Color.white
        }
    }

    var minuteHand: Color {
        switch self {
        case .classic: return Color(red: 0.18, green: 0.15, blue: 0.12)
        case .night: return Color(red: 0.72, green: 0.84, blue: 0.96)
        case .minimal: return Color(red: 0.22, green: 0.22, blue: 0.22)
        case .sport: return Color(red: 0.92, green: 0.94, blue: 0.97)
        }
    }

    var secondHand: Color {
        switch self {
        case .classic: return Color(red: 0.70, green: 0.14, blue: 0.14)
        case .night: return Color(red: 0.28, green: 0.78, blue: 1.0)
        case .minimal: return Color(red: 0.82, green: 0.22, blue: 0.18)
        case .sport: return Color(red: 1.0, green: 0.38, blue: 0.12)
        }
    }

    var centerCap: Color {
        switch self {
        case .classic: return Color(red: 0.16, green: 0.13, blue: 0.10)
        case .night: return Color(red: 0.88, green: 0.94, blue: 1.0)
        case .minimal: return Color(red: 0.10, green: 0.10, blue: 0.10)
        case .sport: return Color(red: 1.0, green: 0.38, blue: 0.12)
        }
    }

    var centerCapInner: Color {
        switch self {
        case .classic: return Color(red: 0.70, green: 0.14, blue: 0.14)
        case .night: return Color(red: 0.28, green: 0.78, blue: 1.0)
        case .minimal: return Color(red: 0.82, green: 0.22, blue: 0.18)
        case .sport: return Color.white
        }
    }

    var shadowOpacity: Double {
        switch self {
        case .classic: return 0.22
        case .night: return 0.55
        case .minimal: return 0.10
        case .sport: return 0.40
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
