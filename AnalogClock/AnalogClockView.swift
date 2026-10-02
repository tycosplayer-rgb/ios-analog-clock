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

// MARK: - 秒跳1 + 秒摆（欠阻尼振动）

private struct Tick1HandsLayer: View {
    let theme: FaceTheme
    let size: CGFloat

    @State private var displayedSecondDegrees: Double = 0
    @State private var lastWholeSecond: Int = -1
    @State private var hourDegrees: Double = 0
    @State private var minuteDegrees: Double = 0

    /// 秒摆物理参数：θ(t) = A0 * e^(-γt) * cos(ω t)
    /// ω ≈ 2π·9 Hz，γ 使约 0.35s 内包络衰减到 ~5%（几次可见来回后自然停住）
    @State private var beatStart: Date?
    @State private var beatTargetDegrees: Double = 0
    @State private var beatAmplitude: Double = 3.5
    private let beatOmega: Double = 2.0 * Double.pi * 9.0
    private let beatGamma: Double = 9.5

    var body: some View {
        ClockHandsView(
            theme: theme,
            size: size,
            hourDegrees: hourDegrees,
            minuteDegrees: minuteDegrees,
            secondDegrees: displayedSecondDegrees
        )
        .onAppear { sync(from: Date(), startBeat: false) }
        .onReceive(Timer.publish(every: 1.0 / 60.0, on: .main, in: .common).autoconnect()) { date in
            let second = Calendar.current.component(.second, from: date)
            hourDegrees = ClockMath.hourAngleDegrees(date: date)
            minuteDegrees = ClockMath.minuteAngleDegrees(date: date, continuous: true)
            if second != lastWholeSecond {
                sync(from: date, startBeat: lastWholeSecond >= 0)
            }
            applyBeat(at: date)
        }
    }

    private func sync(from date: Date, startBeat: Bool) {
        let second = Calendar.current.component(.second, from: date)
        var target = ClockMath.tick1SecondAngleDegrees(date: date)
        lastWholeSecond = second
        hourDegrees = ClockMath.hourAngleDegrees(date: date)
        minuteDegrees = ClockMath.minuteAngleDegrees(date: date, continuous: true)

        // 59→0：继续向正方向转到 360，再归一化
        if target + 180 < displayedSecondDegrees {
            target += 360
        }

        guard startBeat else {
            displayedSecondDegrees = target.truncatingRemainder(dividingBy: 360)
            beatStart = nil
            beatTargetDegrees = displayedSecondDegrees
            return
        }

        beatTargetDegrees = target
        // 初相位取 0：t=0 时 cos=1，从过冲 A0 开始，再按 e^{-γt} cos(ωt) 衰减回目标
        beatAmplitude = 3.5
        beatStart = date
        displayedSecondDegrees = target + beatAmplitude
    }

    private func applyBeat(at date: Date) {
        guard let start = beatStart else { return }
        let t = date.timeIntervalSince(start)
        if t < 0 { return }
        if t > 0.45 {
            var settled = beatTargetDegrees.truncatingRemainder(dividingBy: 360)
            if settled < 0 { settled += 360 }
            displayedSecondDegrees = settled
            beatStart = nil
            return
        }
        // 欠阻尼：指数包络 × 余弦振荡
        let envelope = exp(-beatGamma * t)
        let offset = beatAmplitude * envelope * cos(beatOmega * t)
        displayedSecondDegrees = beatTargetDegrees + offset
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
