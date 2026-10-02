import SwiftUI

/// 完整模拟时钟：表盘 + 指针，按秒针模式驱动
struct AnalogClockView: View {
    let theme: FaceTheme
    let secondMode: SecondHandMode
    let size: CGFloat

    var body: some View {
        ZStack {
            ClockDialView(theme: theme, size: size)

            switch secondMode {
            case .smooth:
                SmoothHandsLayer(theme: theme, size: size)
            case .tick1:
                Tick1HandsLayer(theme: theme, size: size)
            case .tick4:
                Tick4HandsLayer(theme: theme, size: size)
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - 平滑扫秒

private struct SmoothHandsLayer: View {
    let theme: FaceTheme
    let size: CGFloat

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60.0, paused: false)) { context in
            let date = context.date
            ClockHandsView(
                theme: theme,
                size: size,
                hourDegrees: ClockMath.hourAngleDegrees(date: date),
                minuteDegrees: ClockMath.minuteAngleDegrees(date: date, continuous: true),
                secondDegrees: ClockMath.smoothSecondAngleDegrees(date: date)
            )
        }
    }
}

// MARK: - 秒跳1 + 秒摆

private struct Tick1HandsLayer: View {
    let theme: FaceTheme
    let size: CGFloat

    @State private var displayedSecondDegrees: Double = 0
    @State private var lastWholeSecond: Int = -1
    @State private var hourDegrees: Double = 0
    @State private var minuteDegrees: Double = 0

    var body: some View {
        ClockHandsView(
            theme: theme,
            size: size,
            hourDegrees: hourDegrees,
            minuteDegrees: minuteDegrees,
            secondDegrees: displayedSecondDegrees
        )
        .onAppear { sync(from: Date(), animateWiggle: false) }
        // 高频轮询以捕捉整秒边界；时/分针也同步更新
        .onReceive(Timer.publish(every: 1.0 / 30.0, on: .main, in: .common).autoconnect()) { date in
            let second = Calendar.current.component(.second, from: date)
            hourDegrees = ClockMath.hourAngleDegrees(date: date)
            minuteDegrees = ClockMath.minuteAngleDegrees(date: date, continuous: true)
            if second != lastWholeSecond {
                sync(from: date, animateWiggle: lastWholeSecond >= 0)
            }
        }
    }

    private func sync(from date: Date, animateWiggle: Bool) {
        let second = Calendar.current.component(.second, from: date)
        let target = ClockMath.tick1SecondAngleDegrees(date: date)
        lastWholeSecond = second
        hourDegrees = ClockMath.hourAngleDegrees(date: date)
        minuteDegrees = ClockMath.minuteAngleDegrees(date: date, continuous: true)

        guard animateWiggle else {
            displayedSecondDegrees = target
            return
        }

        var destination = target
        // 59→0：继续向正方向转到 360，再归一化
        if destination + 180 < displayedSecondDegrees {
            destination += 360
        }

        // 秒摆：过冲约 1.8°，再弹簧回落
        let overshoot = destination + 1.8
        withAnimation(.easeOut(duration: 0.045)) {
            displayedSecondDegrees = overshoot
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation(.interpolatingSpring(stiffness: 420, damping: 12)) {
                displayedSecondDegrees = destination
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                if displayedSecondDegrees >= 360 {
                    var t = Transaction()
                    t.disablesAnimations = true
                    withTransaction(t) {
                        displayedSecondDegrees = displayedSecondDegrees.truncatingRemainder(dividingBy: 360)
                    }
                }
            }
        }
    }
}

// MARK: - 秒跳2（每秒 4 步）

private struct Tick4HandsLayer: View {
    let theme: FaceTheme
    let size: CGFloat

    @State private var displayedSecondDegrees: Double = 0
    @State private var lastStepIndex: Int = -1
    @State private var hourDegrees: Double = 0
    @State private var minuteDegrees: Double = 0

    var body: some View {
        ClockHandsView(
            theme: theme,
            size: size,
            hourDegrees: hourDegrees,
            minuteDegrees: minuteDegrees,
            secondDegrees: displayedSecondDegrees
        )
        .onAppear { sync(from: Date(), animate: false) }
        .onReceive(Timer.publish(every: 1.0 / 40.0, on: .main, in: .common).autoconnect()) { date in
            let calendar = Calendar.current
            let s = calendar.component(.second, from: date)
            let ns = calendar.component(.nanosecond, from: date)
            let quarter = ns / 250_000_000
            let stepIndex = s * 4 + quarter
            hourDegrees = ClockMath.hourAngleDegrees(date: date)
            minuteDegrees = ClockMath.minuteAngleDegrees(date: date, continuous: true)
            if stepIndex != lastStepIndex {
                sync(from: date, animate: lastStepIndex >= 0)
            }
        }
    }

    private func sync(from date: Date, animate: Bool) {
        let calendar = Calendar.current
        let s = calendar.component(.second, from: date)
        let ns = calendar.component(.nanosecond, from: date)
        let quarter = ns / 250_000_000
        lastStepIndex = s * 4 + quarter

        let target = ClockMath.tick4SecondAngleDegrees(date: date)
        hourDegrees = ClockMath.hourAngleDegrees(date: date)
        minuteDegrees = ClockMath.minuteAngleDegrees(date: date, continuous: true)

        var destination = target
        if destination + 180 < displayedSecondDegrees {
            destination += 360
        }

        if animate {
            withAnimation(.easeOut(duration: 0.04)) {
                displayedSecondDegrees = destination
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                if displayedSecondDegrees >= 360 {
                    var t = Transaction()
                    t.disablesAnimations = true
                    withTransaction(t) {
                        displayedSecondDegrees = displayedSecondDegrees.truncatingRemainder(dividingBy: 360)
                    }
                }
            }
        } else {
            displayedSecondDegrees = destination.truncatingRemainder(dividingBy: 360)
        }
    }
}
