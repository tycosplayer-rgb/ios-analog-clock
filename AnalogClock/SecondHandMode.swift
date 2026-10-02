import Foundation

/// 秒针运行模式
enum SecondHandMode: String, CaseIterable, Identifiable {
    /// 平滑连续扫秒（TimelineView .animation）
    case smooth = "smooth"
    /// 每秒跳一次，并带秒摆（过冲回弹）
    case tick1 = "tick1"
    /// 每秒跳 4 次（每分钟 240 步，每步 1.5°）
    case tick4 = "tick4"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .smooth: return String(localized: "平滑")
        case .tick1: return String(localized: "秒跳1")
        case .tick4: return String(localized: "秒跳2")
        }
    }

    var subtitle: String {
        switch self {
        case .smooth: return String(localized: "连续扫秒")
        case .tick1: return String(localized: "每秒一跳 · 秒摆")
        case .tick4: return String(localized: "每秒四跳")
        }
    }
}
