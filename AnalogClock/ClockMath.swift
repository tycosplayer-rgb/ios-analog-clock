import Foundation

enum ClockMath {
    /// 将角度（度，0 = 12 点方向）转为弧度（SwiftUI 旋转，0 = 3 点方向）
    static func rotationRadians(degreesFrom12: Double) -> Double {
        (degreesFrom12 - 90.0) * .pi / 180.0
    }

    /// 小时指针角度：含分钟与秒的平滑贡献（每小时 30°，每分钟 0.5°）
    static func hourAngleDegrees(date: Date, calendar: Calendar = .current) -> Double {
        let h = Double(calendar.component(.hour, from: date) % 12)
        let m = Double(calendar.component(.minute, from: date))
        let s = fractionalSeconds(date: date, calendar: calendar)
        return h * 30.0 + m * 0.5 + s * (0.5 / 60.0)
    }

    /// 分针：随秒连续移动（更优雅）；也可只按整分钟步进
    static func minuteAngleDegrees(date: Date, continuous: Bool = true, calendar: Calendar = .current) -> Double {
        let m = Double(calendar.component(.minute, from: date))
        if continuous {
            let s = fractionalSeconds(date: date, calendar: calendar)
            return m * 6.0 + s * 0.1
        }
        return m * 6.0
    }

    /// 平滑秒针：含小数秒
    static func smoothSecondAngleDegrees(date: Date, calendar: Calendar = .current) -> Double {
        fractionalSeconds(date: date, calendar: calendar) * 6.0
    }

    /// 秒跳1：整秒位置（6° 一步）
    static func tick1SecondAngleDegrees(date: Date, calendar: Calendar = .current) -> Double {
        Double(calendar.component(.second, from: date)) * 6.0
    }

    /// 秒跳2：每秒 4 步 = 每分钟 240 步 = 每步 1.5°
    static func tick4SecondAngleDegrees(date: Date, calendar: Calendar = .current) -> Double {
        let s = Double(calendar.component(.second, from: date))
        let ns = Double(calendar.component(.nanosecond, from: date))
        let quarter = floor(ns / 250_000_000.0) // 0..3
        return s * 6.0 + quarter * 1.5
    }

    static func fractionalSeconds(date: Date, calendar: Calendar = .current) -> Double {
        let s = Double(calendar.component(.second, from: date))
        let ns = Double(calendar.component(.nanosecond, from: date))
        return s + ns / 1_000_000_000.0
    }
}
