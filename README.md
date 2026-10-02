# 模拟时钟（AnalogClock）

精美的 iOS SwiftUI 模拟时钟应用。大表盘几乎占满屏幕，支持多种表盘主题与三种秒针模式（含机械秒摆）。

- **最低系统**：iOS 17+
- **语言**：Swift / SwiftUI
- **依赖**：无第三方付费依赖

## 功能一览

### 表盘主题（可切换，自动记住）

| 主题 | 说明 |
|------|------|
| **经典** | 浅色衬线数字，温暖表盘 |
| **夜黑** | 深色夜光风格 |
| **极简** | 无数字、细刻度 |
| **运动** | 高对比，仅 12/3/6/9 |

### 秒针模式（可切换，自动记住）

| 模式 | 说明 |
|------|------|
| **平滑** | `TimelineView(.animation)` 连续扫秒 |
| **秒跳1** | 每秒跳一格，并带 **秒摆**（短暂过冲 + 弹簧回落） |
| **秒跳2** | 每秒跳 **4** 次（每分钟 240 步，每步 1.5°） |

其他：

- 时针随分钟连续推进；分针随秒平滑移动
- 显示时钟时禁用息屏（`isIdleTimerDisabled`）
- 轻点屏幕可显隐底部控制条；齿轮打开完整设置
- 竖屏为主，横屏自适应

## 在 Xcode 中打开并运行

1. 用 Mac 克隆本仓库：
   ```bash
   git clone https://github.com/tycosplayer-rgb/ios-analog-clock.git
   cd ios-analog-clock
   ```
2. 双击打开 `AnalogClock.xcodeproj`（或在 Xcode 中 File → Open）。
3. 选择模拟器（如 iPhone 16）或真机。
4. 若真机运行：在 Target → Signing & Capabilities 中选择你的 **Team**。
5. 按 `⌘R` 运行。

### （可选）用 XcodeGen 重新生成工程

若你修改了文件结构，可在 Mac 上安装 [XcodeGen](https://github.com/yonaskolb/XcodeGen) 后执行：

```bash
xcodegen generate
```

会根据根目录 `project.yml` 重新生成 `.xcodeproj`。

## 项目结构

```
ios-analog-clock/
├── AnalogClock.xcodeproj/     # Xcode 工程
├── AnalogClock/
│   ├── AnalogClockApp.swift   # App 入口（禁息屏）
│   ├── ContentView.swift      # 主界面 + 控制条
│   ├── AnalogClockView.swift  # 三种秒针模式驱动
│   ├── ClockDialView.swift    # 表盘 / 刻度 / 数字
│   ├── ClockHandsView.swift   # 时分秒针 Shape
│   ├── FaceTheme.swift        # 四种表盘主题
│   ├── SecondHandMode.swift   # 秒针模式枚举
│   ├── ClockMath.swift        # 角度计算
│   ├── SettingsPanel.swift    # 设置 Sheet
│   ├── Info.plist
│   └── Assets.xcassets/
├── project.yml                # XcodeGen 配置（可选）
└── README.md
```

## 注意事项

- App Icon 资源为占位配置；可在 Assets → AppIcon 中自行添加 1024×1024 图标。
- 本仓库在 Linux 环境生成了可打开的 `.xcodeproj`；首次在 Xcode 打开若提示升级工程，选同意即可。
- 「秒跳1」的秒摆为视觉过冲约 1.8°，可按喜好在 `AnalogClockView.swift` 中微调。

## License

MIT
