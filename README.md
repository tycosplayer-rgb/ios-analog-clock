# 模拟时钟（AnalogClock）

精美的 iOS SwiftUI 模拟时钟应用。大表盘几乎占满屏幕，支持多种表盘主题与三种秒针模式（含机械秒摆）。顶部与底部集成 Google AdMob 横幅广告，并提供「去广告」一次性内购。

- **最低系统**：iOS 17+
- **语言**：Swift / SwiftUI
- **广告**：Google Mobile Ads SDK（Swift Package Manager）
- **内购**：StoreKit 2 非消耗型「去广告」

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
- 轻点屏幕可显隐控制条；齿轮打开完整设置
- **顶部 + 底部** AdMob 横幅；购买「去广告」后隐藏并让表盘占满空间
- 竖屏为主，横屏自适应

## AdMob（当前为 Google 官方测试 ID）

工程默认使用 Google 官方 **测试** App ID / Banner Unit，无需你的 AdMob 账号即可在模拟器与真机看到测试广告：

| 用途 | 测试值 |
|------|--------|
| App ID（`GADApplicationIdentifier`） | `ca-app-pub-3940256099942544~1458002511` |
| Banner Ad Unit | `ca-app-pub-3940256099942544/2934735716` |

上架前请替换为真实 ID：

1. 在 [AdMob](https://admob.google.com) 创建应用与横幅广告单元。
2. 把 **App ID** 写入 `AnalogClock/Info.plist` 的 `GADApplicationIdentifier`（以及 `project.yml` 中同名字段）。
3. 把 **Banner Unit ID** 写入 `AnalogClock/AdMobConfig.swift` 的 `bannerAdUnitID`。

SDK 通过 SPM 引入：  
https://github.com/googleads/swift-package-manager-google-mobile-ads

启动时在 `AnalogClockApp` 中调用 `MobileAds.shared.start()`。

## 去广告（StoreKit 2）

- **Product ID**：`com.tycosplayer.analogclock.removeads`（非消耗型）
- 购买状态持久化到 `UserDefaults` / `@AppStorage` 键 `adsRemoved`
- 设置页提供「去广告」购买与「恢复购买」；主界面底部也有「去广告」芯片入口
- 本地测试：根目录 `Products.storekit` 已挂到 Scheme → Run → StoreKit Configuration。在 Simulator / 本地 Xcode 运行即可弹出测试购买，**无需** App Store Connect。
- **生产环境**：请在 App Store Connect 创建同名非消耗型商品，并关闭或换掉本地 StoreKit Configuration；真机沙盒可用 Sandbox 账号测试。

## 在 Xcode 中打开并运行

1. 用 Mac 克隆本仓库：
   ```bash
   git clone https://github.com/tycosplayer-rgb/ios-analog-clock.git
   cd ios-analog-clock
   ```
2. 双击打开 `AnalogClock.xcodeproj`（首次会解析 Google Mobile Ads SPM）。
3. 选择模拟器（如 iPhone 14 Pro）或真机。
4. 确认 Target → Signing & Capabilities 中 Team 已选（本仓库默认 `DEVELOPMENT_TEAM=3C2T7V7382`）。
5. 确认 Scheme → Run → Options → StoreKit Configuration = `Products.storekit`（本地测内购）。
6. 按 `⌘R` 运行。

### （可选）用 XcodeGen 重新生成工程

若你修改了文件结构，可在 Mac 上安装 [XcodeGen](https://github.com/yonaskolb/XcodeGen) 后执行：

```bash
xcodegen generate
```

会根据根目录 `project.yml` 重新生成 `.xcodeproj`（含 SPM、StoreKit Configuration scheme）。

## 项目结构

```
ios-analog-clock/
├── AnalogClock.xcodeproj/     # Xcode 工程
├── AnalogClock/
│   ├── AnalogClockApp.swift   # App 入口（禁息屏 + MobileAds.start）
│   ├── ContentView.swift      # 主界面 + 顶/底横幅 + 控制条
│   ├── BannerAdView.swift     # UIViewRepresentable 包装 BannerView
│   ├── AdMobConfig.swift      # 测试 / 正式广告单元 ID
│   ├── RemoveAdsStore.swift   # StoreKit 2 去广告
│   ├── AnalogClockView.swift  # 三种秒针模式驱动
│   ├── ClockDialView.swift    # 表盘 / 刻度 / 数字
│   ├── ClockHandsView.swift   # 时分秒针 Shape
│   ├── FaceTheme.swift        # 四种表盘主题
│   ├── SecondHandMode.swift   # 秒针模式枚举
│   ├── ClockMath.swift        # 角度计算
│   ├── SettingsPanel.swift    # 设置 Sheet（含购买/恢复）
│   ├── Info.plist             # 含 GADApplicationIdentifier
│   └── Assets.xcassets/
├── Products.storekit          # 本地 StoreKit 配置（去广告）
├── project.yml                # XcodeGen 配置
└── README.md
```

## 注意事项

- App Icon 资源为占位配置；可在 Assets → AppIcon 中自行添加 1024×1024 图标。
- 使用测试广告单元时请勿点击广告刷量；上架前务必换成自己的正式 ID。
- 「秒跳1」的秒摆为视觉过冲约 1.8°，可按喜好在 `AnalogClockView.swift` 中微调。
- 表盘数字半径使用 `size/2` 布局，修改广告栏时请勿破坏该计算。

## License

MIT
