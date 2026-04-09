# 自分との約束 iOS App Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 自分との約束を1つ設定し、期限日に通知で「守れましたか？」と問いかけるiOSアプリを構築する

**Architecture:** SwiftUIによるシングルビューアプリ。画面遷移はenum-based state machineで管理。データはUserDefaults（@AppStorage）で永続化。ローカル通知はUNUserNotificationCenterで実装。達成演出はSwiftUIのCanvas+TimelineViewによるパーティクルシステム。

**Tech Stack:** Swift 5.9+, SwiftUI, UserDefaults (@AppStorage), UNUserNotificationCenter, iOS 17.0+, Xcode 16+

---

## File Structure

```
PromiseToMyself/
├── PromiseToMyselfApp.swift           # アプリエントリポイント + 通知デリゲート
├── Models/
│   └── Promise.swift                  # 約束データモデル（Codable）
├── Navigation/
│   └── AppScreen.swift                # 画面遷移enum + ViewModel
├── Views/
│   ├── RootView.swift                 # 画面遷移ルーター
│   ├── OnboardingView.swift           # 画面1: 初回起動
│   ├── PromiseInputView.swift         # 画面2: 約束入力
│   ├── PromiseDisplayView.swift       # 画面3: 約束表示（メイン）
│   ├── PromiseCheckView.swift         # 画面4: 達成確認
│   ├── AchievementView.swift          # 画面5a: 達成演出
│   ├── AcceptanceView.swift           # 画面5b: 受容フィードバック
│   └── CancelConfirmationView.swift   # 取り消し確認シート
├── Effects/
│   └── CosmicParticleEffect.swift     # 宇宙パーティクルエフェクト
├── Services/
│   └── NotificationService.swift      # ローカル通知管理
├── Theme/
│   └── AppTheme.swift                 # カラー・フォント定義
├── Localizable.xcstrings              # 多言語対応準備（日本語のみ）
└── Assets.xcassets/                   # アイコン・カラーアセット
```

**設計判断:**
- **UserDefaults（@AppStorage）を採用、SwiftDataは不採用:** 約束は常に1つだけ。永続化するデータはPromise構造体1つと初回起動フラグのみ。SwiftDataはオーバーキル。
- **enum-based state machineで画面遷移:** NavigationStackは不要。アプリの状態（約束なし/約束中/期限到来/達成/受容）がそのまま画面に対応するため、enumのswitchが最もシンプル。
- **Canvas+TimelineViewでパーティクル:** 外部ライブラリ不要。SwiftUI標準APIだけで宇宙的な演出が実現可能。

---

## Task 1: Xcodeプロジェクトセットアップ

**Files:**
- Create: `PromiseToMyself.xcodeproj`（Xcodeが生成）
- Create: `PromiseToMyself/PromiseToMyselfApp.swift`

**前提:** Xcode 16+がインストール済みであること。

- [ ] **Step 1: Xcodeプロジェクト作成**

Xcodeを開き:
1. File → New → Project
2. iOS → App を選択
3. 以下を入力:
   - Product Name: `PromiseToMyself`
   - Team: (Apple Developer Account)
   - Organization Identifier: `com.daiki-inoue`（自身のドメインに合わせて変更）
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Storage: **None**（SwiftDataは使わない）
   - ☑ Include Tests（チェックする）
4. 保存先: `/home/inoue-d/dev/promise-to-myself/`

- [ ] **Step 2: プロジェクト設定変更**

Xcode → Project設定:
1. TARGETS → PromiseToMyself → General
   - Minimum Deployments: **iOS 17.0**
   - Display Name: **自分との約束**
   - Bundle Identifier: `com.daiki-inoue.promise-to-myself`
2. TARGETS → PromiseToMyself → Info
   - 「Bundle display name」を追加: `自分との約束`

- [ ] **Step 3: ディレクトリ構造作成**

Xcode内でグループ（フォルダ）を作成:
- PromiseToMyself/Models/
- PromiseToMyself/Navigation/
- PromiseToMyself/Views/
- PromiseToMyself/Effects/
- PromiseToMyself/Services/
- PromiseToMyself/Theme/

- [ ] **Step 4: ビルド確認**

Cmd+B でビルドが成功することを確認。シミュレータ（iPhone 15 Pro）で実行し、デフォルトの「Hello, world!」が表示されることを確認。

- [ ] **Step 5: .gitignore作成とコミット**

リポジトリルートに`.gitignore`を作成:

```gitignore
# Xcode
*.xcodeproj/project.xcworkspace/xcuserdata/
*.xcodeproj/xcuserdata/
*.xcworkspace/xcuserdata/
*.pbxuser
*.mode1v3
*.mode2v3
*.perspectivev3
*.moved-aside
DerivedData/
build/
*.hmap
*.ipa
*.dSYM.zip
*.dSYM

# Swift Package Manager
.build/
Packages/

# OS
.DS_Store
```

```bash
git add .gitignore docs/
git commit -m "docs: add requirements and implementation plan"
```

---

## Task 2: テーマ定義

**Files:**
- Create: `PromiseToMyself/Theme/AppTheme.swift`

- [ ] **Step 1: テーマファイル作成**

```swift
import SwiftUI

enum AppTheme {
    // MARK: - Colors
    static let background = Color(red: 0.02, green: 0.02, blue: 0.04)
    static let textPrimary = Color.white
    static let textSecondary = Color(white: 0.53) // #888888
    static let accent = Color(red: 0.75, green: 0.63, blue: 1.0) // #C0A0FF
    static let accentBlue = Color(red: 0.5, green: 0.5, blue: 1.0) // #8080FF

    // MARK: - Fonts
    static let promiseText = Font.system(size: 24, weight: .medium, design: .default)
    static let titleText = Font.system(size: 20, weight: .semibold, design: .default)
    static let bodyText = Font.system(size: 16, weight: .regular, design: .default)
    static let captionText = Font.system(size: 14, weight: .regular, design: .default)
    static let buttonText = Font.system(size: 18, weight: .semibold, design: .default)
}
```

- [ ] **Step 2: ビルド確認**

Cmd+B でビルドが通ることを確認。

- [ ] **Step 3: コミット**

```bash
git add PromiseToMyself/Theme/AppTheme.swift
git commit -m "feat: add app theme with cosmic color palette and fonts"
```

---

## Task 3: データモデル

**Files:**
- Create: `PromiseToMyself/Models/Promise.swift`
- Create: `PromiseToMyselfTests/Models/PromiseTests.swift`

- [ ] **Step 1: テスト作成**

```swift
import Testing
import Foundation
@testable import PromiseToMyself

struct PromiseTests {
    @Test func createPromise() {
        let deadline = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        let promise = Promise(content: "毎朝7時に起きる", deadline: deadline)

        #expect(promise.content == "毎朝7時に起きる")
        #expect(promise.deadline == deadline)
    }

    @Test func isExpired_beforeDeadline_returnsFalse() {
        let future = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        let promise = Promise(content: "テスト", deadline: future)

        #expect(!promise.isExpired)
    }

    @Test func isExpired_afterDeadline_returnsTrue() {
        let past = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let promise = Promise(content: "テスト", deadline: past)

        #expect(promise.isExpired)
    }

    @Test func daysRemaining_sevenDaysFromNow() {
        let future = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        let promise = Promise(content: "テスト", deadline: future)

        #expect(promise.daysRemaining >= 6 && promise.daysRemaining <= 7)
    }

    @Test func daysRemaining_pastDeadline_returnsZero() {
        let past = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
        let promise = Promise(content: "テスト", deadline: past)

        #expect(promise.daysRemaining == 0)
    }

    @Test func jsonRoundTrip() throws {
        let deadline = Date(timeIntervalSince1970: 1750000000)
        let original = Promise(content: "ギャンブルをやめる", deadline: deadline)

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Promise.self, from: data)

        #expect(decoded.content == original.content)
        #expect(decoded.deadline == original.deadline)
    }
}
```

- [ ] **Step 2: テスト実行 → 失敗確認**

Cmd+U でテスト実行。`Promise`型が存在しないためコンパイルエラーになることを確認。

- [ ] **Step 3: モデル実装**

```swift
import Foundation

struct Promise: Codable, Equatable {
    let content: String
    let deadline: Date

    var isExpired: Bool {
        Date() >= Calendar.current.startOfDay(for: deadline)
    }

    var daysRemaining: Int {
        let days = Calendar.current.dateComponents(
            [.day],
            from: Calendar.current.startOfDay(for: Date()),
            to: Calendar.current.startOfDay(for: deadline)
        ).day ?? 0
        return max(0, days)
    }
}
```

- [ ] **Step 4: テスト実行 → 成功確認**

Cmd+U でテスト実行。全テストがパスすることを確認。

- [ ] **Step 5: コミット**

```bash
git add PromiseToMyself/Models/Promise.swift PromiseToMyselfTests/
git commit -m "feat: add Promise data model with expiration and days remaining"
```

---

## Task 4: 画面遷移（State Machine）

**Files:**
- Create: `PromiseToMyself/Navigation/AppScreen.swift`
- Create: `PromiseToMyselfTests/Navigation/AppScreenTests.swift`

- [ ] **Step 1: テスト作成**

```swift
import Testing
import Foundation
@testable import PromiseToMyself

struct AppViewModelTests {
    @Test func initialState_firstLaunch_showsOnboarding() {
        let vm = AppViewModel(isFirstLaunch: true, savedPromise: nil)
        #expect(vm.currentScreen == .onboarding)
    }

    @Test func initialState_noPromise_showsInput() {
        let vm = AppViewModel(isFirstLaunch: false, savedPromise: nil)
        #expect(vm.currentScreen == .input)
    }

    @Test func initialState_activePromise_showsDisplay() {
        let future = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        let promise = Promise(content: "テスト", deadline: future)
        let vm = AppViewModel(isFirstLaunch: false, savedPromise: promise)
        #expect(vm.currentScreen == .display)
    }

    @Test func initialState_expiredPromise_showsCheck() {
        let past = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let promise = Promise(content: "テスト", deadline: past)
        let vm = AppViewModel(isFirstLaunch: false, savedPromise: promise)
        #expect(vm.currentScreen == .check)
    }

    @Test func completeOnboarding_transitionsToInput() {
        let vm = AppViewModel(isFirstLaunch: true, savedPromise: nil)
        vm.completeOnboarding()
        #expect(vm.currentScreen == .input)
    }

    @Test func makePromise_transitionsToDisplay() {
        let vm = AppViewModel(isFirstLaunch: false, savedPromise: nil)
        let future = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        vm.makePromise(content: "毎朝7時に起きる", deadline: future)
        #expect(vm.currentScreen == .display)
        #expect(vm.currentPromise?.content == "毎朝7時に起きる")
    }

    @Test func answerYes_transitionsToAchievement() {
        let past = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let promise = Promise(content: "テスト", deadline: past)
        let vm = AppViewModel(isFirstLaunch: false, savedPromise: promise)
        vm.answerKept(yes: true)
        #expect(vm.currentScreen == .achievement)
    }

    @Test func answerNo_transitionsToAcceptance() {
        let past = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let promise = Promise(content: "テスト", deadline: past)
        let vm = AppViewModel(isFirstLaunch: false, savedPromise: promise)
        vm.answerKept(yes: false)
        #expect(vm.currentScreen == .acceptance)
    }

    @Test func cancelPromise_transitionsToInput() {
        let future = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        let promise = Promise(content: "テスト", deadline: future)
        let vm = AppViewModel(isFirstLaunch: false, savedPromise: promise)
        vm.cancelPromise()
        #expect(vm.currentScreen == .input)
        #expect(vm.currentPromise == nil)
    }

    @Test func proceedFromAchievement_transitionsToInput() {
        let past = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let promise = Promise(content: "テスト", deadline: past)
        let vm = AppViewModel(isFirstLaunch: false, savedPromise: promise)
        vm.answerKept(yes: true)
        vm.proceedToNextPromise()
        #expect(vm.currentScreen == .input)
        #expect(vm.currentPromise == nil)
    }
}
```

- [ ] **Step 2: テスト実行 → 失敗確認**

Cmd+U でコンパイルエラーを確認。

- [ ] **Step 3: 実装**

```swift
import SwiftUI
import Foundation

enum AppScreen: Equatable {
    case onboarding
    case input
    case display
    case check
    case achievement
    case acceptance
}

@Observable
final class AppViewModel {
    private(set) var currentScreen: AppScreen
    private(set) var currentPromise: Promise?

    @ObservationIgnored
    private let userDefaults: UserDefaults

    init(
        isFirstLaunch: Bool = !UserDefaults.standard.bool(forKey: "hasLaunched"),
        savedPromise: Promise? = nil,
        userDefaults: UserDefaults = .standard
    ) {
        self.userDefaults = userDefaults

        // Load saved promise if not injected
        let promise: Promise?
        if let savedPromise {
            promise = savedPromise
        } else if let data = userDefaults.data(forKey: "currentPromise") {
            promise = try? JSONDecoder().decode(Promise.self, from: data)
        } else {
            promise = nil
        }
        self.currentPromise = promise

        // Determine initial screen
        if isFirstLaunch {
            self.currentScreen = .onboarding
        } else if let promise {
            self.currentScreen = promise.isExpired ? .check : .display
        } else {
            self.currentScreen = .input
        }
    }

    func completeOnboarding() {
        userDefaults.set(true, forKey: "hasLaunched")
        currentScreen = .input
    }

    func makePromise(content: String, deadline: Date) {
        let promise = Promise(content: content, deadline: deadline)
        currentPromise = promise
        savePromise(promise)
        currentScreen = .display
    }

    func answerKept(yes: Bool) {
        currentScreen = yes ? .achievement : .acceptance
    }

    func cancelPromise() {
        currentPromise = nil
        clearPromise()
        currentScreen = .input
    }

    func proceedToNextPromise() {
        currentPromise = nil
        clearPromise()
        currentScreen = .input
    }

    private func savePromise(_ promise: Promise) {
        if let data = try? JSONEncoder().encode(promise) {
            userDefaults.set(data, forKey: "currentPromise")
        }
    }

    private func clearPromise() {
        userDefaults.removeObject(forKey: "currentPromise")
    }
}
```

- [ ] **Step 4: テスト実行 → 成功確認**

Cmd+U でテスト実行。全テストパスを確認。

- [ ] **Step 5: コミット**

```bash
git add PromiseToMyself/Navigation/AppScreen.swift PromiseToMyselfTests/
git commit -m "feat: add app state machine with screen transitions"
```

---

## Task 5: 通知サービス

**Files:**
- Create: `PromiseToMyself/Services/NotificationService.swift`

- [ ] **Step 1: 通知サービス実装**

```swift
import UserNotifications
import Foundation

enum NotificationService {
    private static let promiseNotificationID = "promise-deadline"

    static func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    static func scheduleDeadlineNotification(for deadline: Date) {
        let content = UNMutableNotificationContent()
        content.title = "自分との約束"
        content.body = "約束の期限です。守れましたか？"
        content.sound = .default

        // 期限日の朝9:00 JST
        var dateComponents = Calendar.current.dateComponents(
            [.year, .month, .day],
            from: deadline
        )
        dateComponents.hour = 9
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: promiseNotificationID,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    static func cancelScheduledNotification() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(
                withIdentifiers: [promiseNotificationID]
            )
    }
}
```

- [ ] **Step 2: ビルド確認**

Cmd+B でビルドが通ることを確認。

注意: ローカル通知のテストはシミュレータでは制限があるため、実機テストはTask 10で行う。

- [ ] **Step 3: コミット**

```bash
git add PromiseToMyself/Services/NotificationService.swift
git commit -m "feat: add notification service for deadline reminders"
```

---

## Task 6: AppViewModelに通知連携を追加

**Files:**
- Modify: `PromiseToMyself/Navigation/AppScreen.swift`

- [ ] **Step 1: makePromise・cancelPromise・proceedToNextPromiseに通知処理を追加**

`AppScreen.swift`の`AppViewModel`の3つのメソッドを更新:

```swift
    func makePromise(content: String, deadline: Date) {
        let promise = Promise(content: content, deadline: deadline)
        currentPromise = promise
        savePromise(promise)
        NotificationService.scheduleDeadlineNotification(for: deadline)
        currentScreen = .display
    }

    func cancelPromise() {
        currentPromise = nil
        clearPromise()
        NotificationService.cancelScheduledNotification()
        currentScreen = .input
    }

    func proceedToNextPromise() {
        currentPromise = nil
        clearPromise()
        NotificationService.cancelScheduledNotification()
        currentScreen = .input
    }
```

- [ ] **Step 2: テスト実行 → 成功確認**

Cmd+U で既存テストが引き続きパスすることを確認。

- [ ] **Step 3: コミット**

```bash
git add PromiseToMyself/Navigation/AppScreen.swift
git commit -m "feat: integrate notification scheduling into app state transitions"
```

---

## Task 7: UIビュー実装（画面1〜3）

**Files:**
- Create: `PromiseToMyself/Views/RootView.swift`
- Create: `PromiseToMyself/Views/OnboardingView.swift`
- Create: `PromiseToMyself/Views/PromiseInputView.swift`
- Create: `PromiseToMyself/Views/PromiseDisplayView.swift`
- Modify: `PromiseToMyself/PromiseToMyselfApp.swift`

- [ ] **Step 1: RootView（画面遷移ルーター）**

```swift
import SwiftUI

struct RootView: View {
    @State private var viewModel = AppViewModel()

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            switch viewModel.currentScreen {
            case .onboarding:
                OnboardingView(viewModel: viewModel)
            case .input:
                PromiseInputView(viewModel: viewModel)
            case .display:
                PromiseDisplayView(viewModel: viewModel)
            case .check:
                PromiseCheckView(viewModel: viewModel)
            case .achievement:
                AchievementView(viewModel: viewModel)
            case .acceptance:
                AcceptanceView(viewModel: viewModel)
            }
        }
        .preferredColorScheme(.dark)
    }
}
```

- [ ] **Step 2: OnboardingView（画面1: 初回起動）**

```swift
import SwiftUI

struct OnboardingView: View {
    let viewModel: AppViewModel

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            Text("自分との約束")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(AppTheme.textPrimary)

            VStack(spacing: 16) {
                Text("たった一つの約束を、自分と交わす。")
                    .font(AppTheme.bodyText)
                    .foregroundStyle(AppTheme.textSecondary)

                Text("それだけのアプリです。")
                    .font(AppTheme.bodyText)
                    .foregroundStyle(AppTheme.textSecondary)
            }
            .multilineTextAlignment(.center)

            Spacer()

            Button {
                Task {
                    await NotificationService.requestPermission()
                    viewModel.completeOnboarding()
                }
            } label: {
                Text("はじめる")
                    .font(AppTheme.buttonText)
                    .foregroundStyle(AppTheme.background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppTheme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 60)
        }
    }
}
```

- [ ] **Step 3: PromiseInputView（画面2: 約束入力）**

```swift
import SwiftUI

struct PromiseInputView: View {
    let viewModel: AppViewModel
    @State private var content: String = ""
    @State private var deadline: Date = Calendar.current.date(
        byAdding: .day, value: 1, to: Date()
    )!

    private var isValid: Bool {
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && deadline > Date()
    }

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Text("自分に、約束する")
                .font(AppTheme.titleText)
                .foregroundStyle(AppTheme.textSecondary)

            TextField("", text: $content, prompt: Text("約束の内容")
                .foregroundStyle(AppTheme.textSecondary.opacity(0.5)),
                axis: .vertical
            )
            .font(AppTheme.promiseText)
            .foregroundStyle(AppTheme.textPrimary)
            .multilineTextAlignment(.center)
            .lineLimit(1...5)
            .padding(.horizontal, 32)

            VStack(spacing: 8) {
                Text("いつまでに")
                    .font(AppTheme.captionText)
                    .foregroundStyle(AppTheme.textSecondary)

                DatePicker(
                    "",
                    selection: $deadline,
                    in: Calendar.current.date(byAdding: .day, value: 1, to: Date())!...,
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .labelsHidden()
                .colorScheme(.dark)
                .tint(AppTheme.accent)
            }

            Spacer()

            Button {
                viewModel.makePromise(
                    content: content.trimmingCharacters(in: .whitespacesAndNewlines),
                    deadline: deadline
                )
            } label: {
                Text("約束する")
                    .font(AppTheme.buttonText)
                    .foregroundStyle(AppTheme.background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(isValid ? AppTheme.accent : AppTheme.textSecondary.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(!isValid)
            .padding(.horizontal, 40)
            .padding(.bottom, 60)
        }
    }
}
```

- [ ] **Step 4: PromiseDisplayView（画面3: 約束表示）**

```swift
import SwiftUI

struct PromiseDisplayView: View {
    let viewModel: AppViewModel
    @State private var showCancelConfirmation = false

    private var promise: Promise? { viewModel.currentPromise }

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            if let promise {
                Text(promise.content)
                    .font(AppTheme.promiseText)
                    .foregroundStyle(AppTheme.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                VStack(spacing: 8) {
                    Text("あと \(promise.daysRemaining) 日")
                        .font(.system(size: 48, weight: .thin, design: .default))
                        .foregroundStyle(AppTheme.accent)

                    Text(promise.deadline, style: .date)
                        .font(AppTheme.captionText)
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }

            Spacer()

            Button {
                showCancelConfirmation = true
            } label: {
                Text("約束を取り消す")
                    .font(AppTheme.captionText)
                    .foregroundStyle(AppTheme.textSecondary.opacity(0.5))
            }
            .padding(.bottom, 40)
        }
        .sheet(isPresented: $showCancelConfirmation) {
            CancelConfirmationView(
                viewModel: viewModel,
                isPresented: $showCancelConfirmation
            )
        }
    }
}
```

- [ ] **Step 5: PromiseToMyselfApp.swift更新**

```swift
import SwiftUI

@main
struct PromiseToMyselfApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
```

- [ ] **Step 6: ビルド確認**

Cmd+B でビルドが通ることを確認。この時点ではPromiseCheckView、AchievementView、AcceptanceView、CancelConfirmationViewが未実装のためコンパイルエラーになる。次のTaskで作成するので、一旦RootViewの該当case部分を仮のText()に置き換える:

```swift
            case .check:
                Text("check") // TODO: Task 8
            case .achievement:
                Text("achievement") // TODO: Task 8
            case .acceptance:
                Text("acceptance") // TODO: Task 8
```

また、CancelConfirmationViewのsheetも一時的にコメントアウト。PromiseDisplayViewの`.sheet`修飾子を一時削除し、代わりに空のalertを設定しておく:

```swift
        .alert("取り消し", isPresented: $showCancelConfirmation) {
            Button("キャンセル", role: .cancel) {}
        }
```

Cmd+B → ビルド成功を確認。シミュレータで実行し、オンボーディング画面が表示されることを確認。

- [ ] **Step 7: コミット**

```bash
git add PromiseToMyself/
git commit -m "feat: add root view, onboarding, promise input, and display screens"
```

---

## Task 8: UIビュー実装（画面4〜5b + 取り消し確認）

**Files:**
- Create: `PromiseToMyself/Views/PromiseCheckView.swift`
- Create: `PromiseToMyself/Views/AchievementView.swift`
- Create: `PromiseToMyself/Views/AcceptanceView.swift`
- Create: `PromiseToMyself/Views/CancelConfirmationView.swift`
- Modify: `PromiseToMyself/Views/RootView.swift` — TODOプレースホルダを実ビューに戻す
- Modify: `PromiseToMyself/Views/PromiseDisplayView.swift` — 仮alertをsheetに戻す

- [ ] **Step 1: PromiseCheckView（画面4: 達成確認）**

```swift
import SwiftUI

struct PromiseCheckView: View {
    let viewModel: AppViewModel

    var body: some View {
        VStack(spacing: 48) {
            Spacer()

            VStack(spacing: 16) {
                Text("自分との約束、")
                    .font(AppTheme.titleText)
                    .foregroundStyle(AppTheme.textSecondary)

                Text("守れましたか？")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)
            }

            if let promise = viewModel.currentPromise {
                Text(promise.content)
                    .font(AppTheme.bodyText)
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()

            VStack(spacing: 16) {
                Button {
                    viewModel.answerKept(yes: true)
                } label: {
                    Text("はい")
                        .font(AppTheme.buttonText)
                        .foregroundStyle(AppTheme.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppTheme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Button {
                    viewModel.answerKept(yes: false)
                } label: {
                    Text("いいえ")
                        .font(AppTheme.buttonText)
                        .foregroundStyle(AppTheme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppTheme.textSecondary.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 60)
        }
    }
}
```

- [ ] **Step 2: AchievementView（画面5a: 達成演出）**

```swift
import SwiftUI

struct AchievementView: View {
    let viewModel: AppViewModel
    @State private var animate = false

    var body: some View {
        ZStack {
            // パーティクルエフェクト（Task 9で実装、ここではプレースホルダ）
            CosmicParticleEffect()
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                Text("約束を、果たした。")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .opacity(animate ? 1 : 0)
                    .scaleEffect(animate ? 1 : 0.8)

                Text("新しい自分が、ここにいる。")
                    .font(AppTheme.bodyText)
                    .foregroundStyle(AppTheme.accent)
                    .opacity(animate ? 1 : 0)

                Spacer()

                Text("タップして次へ")
                    .font(AppTheme.captionText)
                    .foregroundStyle(AppTheme.textSecondary.opacity(0.5))
                    .opacity(animate ? 1 : 0)
                    .padding(.bottom, 60)
            }
        }
        .onTapGesture {
            viewModel.proceedToNextPromise()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.5).delay(0.5)) {
                animate = true
            }
        }
    }
}
```

- [ ] **Step 3: AcceptanceView（画面5b: 受容フィードバック）**

```swift
import SwiftUI

struct AcceptanceView: View {
    let viewModel: AppViewModel
    @State private var showFirst = false
    @State private var showSecond = false

    var body: some View {
        VStack(spacing: 48) {
            Spacer()

            Text("約束は果たせなかった。\nそれだけのこと。")
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(AppTheme.textPrimary)
                .multilineTextAlignment(.center)
                .opacity(showFirst ? 1 : 0)

            Text("次はどんな約束を、\n自分と交わしますか？")
                .font(AppTheme.bodyText)
                .foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .opacity(showSecond ? 1 : 0)

            Spacer()

            Text("タップして次へ")
                .font(AppTheme.captionText)
                .foregroundStyle(AppTheme.textSecondary.opacity(0.5))
                .opacity(showSecond ? 1 : 0)
                .padding(.bottom, 60)
        }
        .onTapGesture {
            viewModel.proceedToNextPromise()
        }
        .onAppear {
            withAnimation(.easeIn(duration: 1.0).delay(0.5)) {
                showFirst = true
            }
            withAnimation(.easeIn(duration: 1.0).delay(2.0)) {
                showSecond = true
            }
        }
    }
}
```

- [ ] **Step 4: CancelConfirmationView（取り消し確認シート）**

```swift
import SwiftUI

struct CancelConfirmationView: View {
    let viewModel: AppViewModel
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 20) {
                Text("言葉は命です。")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(AppTheme.textPrimary)

                Text("あなたが自分に誓った言葉を、\n本当に手放しますか？")
                    .font(AppTheme.bodyText)
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            VStack(spacing: 16) {
                Button {
                    isPresented = false
                } label: {
                    Text("約束を続ける")
                        .font(AppTheme.buttonText)
                        .foregroundStyle(AppTheme.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppTheme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Button {
                    isPresented = false
                    viewModel.cancelPromise()
                } label: {
                    Text("それでも取り消す")
                        .font(AppTheme.captionText)
                        .foregroundStyle(AppTheme.textSecondary.opacity(0.5))
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 60)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.background)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}
```

- [ ] **Step 5: RootViewのTODOを実ビューに置き換え**

`RootView.swift`のswitch内の仮のText()を元に戻す:

```swift
            case .check:
                PromiseCheckView(viewModel: viewModel)
            case .achievement:
                AchievementView(viewModel: viewModel)
            case .acceptance:
                AcceptanceView(viewModel: viewModel)
```

- [ ] **Step 6: PromiseDisplayViewのsheetを復元**

`PromiseDisplayView.swift`の仮alertを削除し、元のsheetに戻す:

```swift
        .sheet(isPresented: $showCancelConfirmation) {
            CancelConfirmationView(
                viewModel: viewModel,
                isPresented: $showCancelConfirmation
            )
        }
```

- [ ] **Step 7: ビルド確認**

この時点ではCosmicParticleEffectが未実装のためコンパイルエラーになる。AchievementViewのCosmicParticleEffect()を一旦コメントアウトしてColor.clear.ignoresSafeArea()に置き換え:

```swift
            // CosmicParticleEffect() // TODO: Task 9
            Color.clear.ignoresSafeArea()
```

Cmd+B → ビルド成功を確認。シミュレータで全画面遷移を確認。

- [ ] **Step 8: コミット**

```bash
git add PromiseToMyself/Views/
git commit -m "feat: add check, achievement, acceptance, and cancel confirmation views"
```

---

## Task 9: 宇宙パーティクルエフェクト

**Files:**
- Create: `PromiseToMyself/Effects/CosmicParticleEffect.swift`
- Modify: `PromiseToMyself/Views/AchievementView.swift` — プレースホルダを実エフェクトに戻す

- [ ] **Step 1: パーティクルエフェクト実装**

```swift
import SwiftUI

struct CosmicParticleEffect: View {
    @State private var particles: [Particle] = []
    @State private var startTime: Date = .now

    private let particleCount = 150

    var body: some View {
        TimelineView(.animation) { timeline in
            let elapsed = timeline.date.timeIntervalSince(startTime)

            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height / 2)

                for particle in particles {
                    let progress = min(elapsed / particle.duration, 1.0)
                    let easedProgress = easeOutCubic(progress)

                    let currentX = center.x + particle.direction.x * particle.distance * easedProgress
                    let currentY = center.y + particle.direction.y * particle.distance * easedProgress

                    let alpha = alphaForProgress(progress)
                    let size = particle.size * (0.5 + easedProgress * 0.5)

                    let color = particle.color.opacity(alpha)
                    let rect = CGRect(
                        x: currentX - size / 2,
                        y: currentY - size / 2,
                        width: size,
                        height: size
                    )

                    context.fill(
                        Circle().path(in: rect),
                        with: .color(color)
                    )

                    // Glow effect for larger particles
                    if particle.size > 3 {
                        let glowRect = CGRect(
                            x: currentX - size,
                            y: currentY - size,
                            width: size * 2,
                            height: size * 2
                        )
                        context.fill(
                            Circle().path(in: glowRect),
                            with: .color(color.opacity(alpha * 0.3))
                        )
                    }
                }
            }
        }
        .onAppear {
            particles = (0..<particleCount).map { _ in
                Particle.random()
            }
            startTime = .now
        }
    }

    private func easeOutCubic(_ t: Double) -> Double {
        1 - pow(1 - t, 3)
    }

    private func alphaForProgress(_ progress: Double) -> Double {
        if progress < 0.1 {
            return progress / 0.1
        } else if progress > 0.7 {
            return max(0, 1 - (progress - 0.7) / 0.3)
        }
        return 1.0
    }
}

private struct Particle {
    let direction: CGPoint
    let distance: CGFloat
    let duration: TimeInterval
    let size: CGFloat
    let color: Color

    static func random() -> Particle {
        let angle = Double.random(in: 0...(2 * .pi))
        let colors: [Color] = [
            Color(red: 0.75, green: 0.63, blue: 1.0),  // accent purple
            Color(red: 0.5, green: 0.5, blue: 1.0),     // accent blue
            Color.white,
            Color(red: 0.6, green: 0.8, blue: 1.0),     // light blue
            Color(red: 1.0, green: 0.8, blue: 0.9),     // light pink
        ]

        return Particle(
            direction: CGPoint(x: cos(angle), y: sin(angle)),
            distance: CGFloat.random(in: 100...500),
            duration: TimeInterval.random(in: 2.0...4.0),
            size: CGFloat.random(in: 1...6),
            color: colors.randomElement()!
        )
    }
}
```

- [ ] **Step 2: AchievementViewのプレースホルダを実エフェクトに戻す**

`AchievementView.swift`で:

```swift
            // 変更前:
            // CosmicParticleEffect() // TODO: Task 9
            Color.clear.ignoresSafeArea()

            // 変更後:
            CosmicParticleEffect()
                .ignoresSafeArea()
```

- [ ] **Step 3: ビルド+シミュレータ確認**

Cmd+B → ビルド成功。シミュレータで約束を作成 → 期限を過去に設定（テスト用にコード内で一時的に`Date()`を許可）→「はい」→ パーティクルが中央から放射状に広がることを確認。

- [ ] **Step 4: コミット**

```bash
git add PromiseToMyself/Effects/CosmicParticleEffect.swift PromiseToMyself/Views/AchievementView.swift
git commit -m "feat: add cosmic particle effect for achievement celebration"
```

---

## Task 10: 通知デリゲート + アプリ起動時の状態復元

**Files:**
- Modify: `PromiseToMyself/PromiseToMyselfApp.swift`

- [ ] **Step 1: アプリデリゲート追加**

通知タップ時にアプリがフォアグラウンドに来た時のハンドリング:

```swift
import SwiftUI
import UserNotifications

@main
struct PromiseToMyselfApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    // フォアグラウンドでも通知バナーを表示
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }
}
```

- [ ] **Step 2: ビルド+テスト**

Cmd+B → ビルド成功。Cmd+U → 全テストパス。

- [ ] **Step 3: コミット**

```bash
git add PromiseToMyself/PromiseToMyselfApp.swift
git commit -m "feat: add notification delegate for foreground notification display"
```

---

## Task 11: 多言語対応の準備（Localizable.xcstrings）

**Files:**
- Create: `PromiseToMyself/Localizable.xcstrings`

- [ ] **Step 1: Xcode上で文字列カタログ作成**

Xcode → PromiseToMyselfグループ右クリック → New File → String Catalog → `Localizable.xcstrings`

v1.0では日本語のみだが、SwiftUIの`Text("key")`が自動的にLocalizable.xcstringsを参照する仕組みを利用する。将来多言語対応する際には、このファイルに翻訳を追加するだけで済む。

現時点ではXcodeのビルド時に自動的にStringが収集されるため、追加作業不要。

- [ ] **Step 2: ビルド確認**

Cmd+B → ビルド成功。

- [ ] **Step 3: コミット**

```bash
git add PromiseToMyself/Localizable.xcstrings
git commit -m "feat: add string catalog for future localization support"
```

---

## Task 12: プライバシーポリシー（GitHub Pages）

**Files:**
- Create: `docs/privacy-policy.html`

- [ ] **Step 1: プライバシーポリシー作成**

```html
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>プライバシーポリシー - 自分との約束</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, sans-serif;
            max-width: 600px;
            margin: 40px auto;
            padding: 0 20px;
            line-height: 1.8;
            color: #333;
            background: #fff;
        }
        h1 { font-size: 1.5em; }
        h2 { font-size: 1.2em; margin-top: 2em; }
    </style>
</head>
<body>
    <h1>プライバシーポリシー</h1>
    <p><strong>自分との約束（Promise to Myself）</strong></p>
    <p>最終更新日: 2026年4月9日</p>

    <h2>データの収集について</h2>
    <p>本アプリは、お客様の個人データを一切収集しません。</p>

    <h2>データの保存について</h2>
    <p>約束の内容と期限日は、お客様のデバイス内にのみ保存されます。外部サーバーへの送信は一切行いません。</p>

    <h2>第三者サービスについて</h2>
    <p>本アプリは、アナリティクスツール、広告ネットワーク、その他の第三者サービスを一切使用しません。</p>

    <h2>通知について</h2>
    <p>本アプリはローカル通知を使用します。通知はお客様のデバイス上で処理され、外部サービスは関与しません。</p>

    <h2>お問い合わせ</h2>
    <p>ご質問がある場合は、以下にお問い合わせください。</p>
    <p>Email: [メールアドレスを記入]</p>
</body>
</html>
```

- [ ] **Step 2: GitHub Pagesの設定**

1. GitHubリポジトリのSettings → Pages
2. Source: Deploy from a branch
3. Branch: `main` / `/docs`
4. Save

公開後URL: `https://[username].github.io/promise-to-myself/privacy-policy.html`

- [ ] **Step 3: コミット**

```bash
git add docs/privacy-policy.html
git commit -m "docs: add privacy policy for App Store submission"
```

---

## Task 13: 結合テスト + 実機デバッグ

**Files:** 既存ファイルの修正のみ

- [ ] **Step 1: シミュレータで全フロー確認**

以下のシナリオをシミュレータで手動テスト:

1. **初回起動フロー:** アプリ削除 → 再インストール → オンボーディング表示 → 通知許可 → 「はじめる」→ 入力画面
2. **約束作成フロー:** 内容入力 → 期限選択 → 「約束する」→ メイン画面に約束と残り日数表示
3. **取り消しフロー:** 「約束を取り消す」→ 確認シート表示 → 「言葉は命です」メッセージ確認 → 「約束を続ける」→ メイン画面 → 再度取り消し → 「それでも取り消す」→ 入力画面
4. **達成フロー:** （テスト用に期限を過去日にする）→ アプリ起動 → 達成確認画面 → 「はい」→ パーティクル演出 → タップ → 入力画面
5. **受容フロー:** 同上 → 「いいえ」→ 「約束は果たせなかった。それだけのこと。」→ 「次はどんな約束を...」→ タップ → 入力画面

- [ ] **Step 2: アプリ再起動時の状態復元確認**

1. 約束を作成
2. アプリをタスクキル
3. アプリ再起動 → メイン画面に約束が表示されることを確認

- [ ] **Step 3: 通知テスト（実機推奨）**

実機またはシミュレータで:
1. 約束を作成（期限: 翌日）
2. シミュレータの場合: Xcode → Debug → Simulate Push Notification... は使えない（ローカル通知のため）。代わりに期限を数分後に設定してテスト。

テスト用に`NotificationService.swift`のtriggerを一時的にUNTimeIntervalNotificationTrigger(5秒後)に変更:

```swift
// テスト用（テスト後に必ず戻す）
let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
```

通知が表示され、タップでアプリが開くことを確認。テスト後にUNCalendarNotificationTriggerに戻す。

- [ ] **Step 4: バグ修正があればコミット**

```bash
git add -A
git commit -m "fix: address issues found during integration testing"
```

---

## 自己レビューチェック

### Spec coverage
| 要件 | 対応Task |
|---|---|
| 約束1つだけ | Task 3 (Model), Task 4 (ViewModel) |
| 約束入力（内容+期限） | Task 7 (PromiseInputView) |
| 期限日9:00に通知 | Task 5, 6 (NotificationService) |
| はい/いいえ | Task 8 (PromiseCheckView) |
| 達成演出 | Task 8 (AchievementView), Task 9 (CosmicParticleEffect) |
| 受容フィードバック | Task 8 (AcceptanceView) |
| 取り消し + 重みあるUX | Task 8 (CancelConfirmationView) |
| デバイス内保存のみ | Task 4 (UserDefaults) |
| 黒/宇宙テーマ | Task 2 (AppTheme) |
| 初回起動 | Task 7 (OnboardingView) |
| 通知許可 | Task 7 (OnboardingView) |
| 多言語準備 | Task 11 (Localizable.xcstrings) |
| プライバシーポリシー | Task 12 |

### Placeholder scan
全Taskにコード記載済み。TBD/TODO/implement laterなし（Task 7のビルド用一時プレースホルダはTask 8で解消される手順を明記）。

### Type consistency
- `Promise` — Task 3で定義、Task 4/7/8で参照。プロパティ名一致（content, deadline, isExpired, daysRemaining）。
- `AppViewModel` — Task 4で定義、Task 7/8で参照。メソッド名一致（completeOnboarding, makePromise, answerKept, cancelPromise, proceedToNextPromise）。
- `AppScreen` — Task 4で定義、Task 7/8で参照。case名一致。
- `NotificationService` — Task 5で定義、Task 6/7で参照。メソッド名一致。
- `AppTheme` — Task 2で定義、全View Taskで参照。プロパティ名一致。
- `CosmicParticleEffect` — Task 9で定義、Task 8で参照。
