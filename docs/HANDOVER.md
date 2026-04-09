# 引き継ぎドキュメント: 自分との約束

> 作成日: 2026-04-09
> 前回セッションの最終コミット: `7c6626f`

---

## 現在の状態

**実装完了、未ビルド。** 全Swiftソースコードはlinux環境で作成済み。MacでXcodeGenを実行してビルド確認が必要。

### 完了済み
- 要件定義書（`docs/requirements.md`）
- 実装計画書（`docs/superpowers/plans/2026-04-09-promise-to-myself-ios.md`）
- 全Swiftソースコード（16ファイル）
- XcodeGen設定（`project.yml`）
- ユニットテスト（Promise + AppViewModel 計16テスト）
- プライバシーポリシー（`docs/privacy-policy.html`）
- セルフレビュー → 8件の問題を修正済み

### 未完了
- [ ] Macでのビルド確認（最優先）
- [ ] Macでのテスト実行確認
- [ ] Apple Developer Program登録
- [ ] アプリアイコン作成（1024x1024）
- [ ] App Storeスクリーンショット作成
- [ ] App Store説明文・キーワード
- [ ] プライバシーポリシーのメールアドレス記入（`docs/privacy-policy.html`）
- [ ] GitHub Pagesでプライバシーポリシー公開
- [ ] App Store申請

---

## アーキテクチャ

### 技術スタック
- SwiftUI / Swift 5.9+ / iOS 17.0+
- データ: UserDefaults（@AppStorage相当、JSONエンコード）
- 通知: UNUserNotificationCenter（ローカル通知）
- 外部依存: なし

### 画面遷移（State Machine）

```
AppScreen enum (6 states):

  onboarding → input → display → check → achievement → input
                 ↑                          ↘ acceptance → input
                 └── cancel ←── display
```

`AppViewModel`（`@Observable`）がState Machineの中核。RootViewがcurrentScreenをswitchして表示するViewを決定。

### ファイル構成と責務

```
PromiseToMyself/Sources/
├── App/
│   └── PromiseToMyselfApp.swift    # @main + UNUserNotificationCenterDelegate
├── Models/
│   └── Promise.swift               # Codable構造体（content, deadline, isExpired, daysRemaining）
├── Navigation/
│   └── AppScreen.swift             # AppScreen enum + AppViewModel（状態遷移・永続化・通知連携）
├── Services/
│   └── NotificationService.swift   # 通知の許可要求・スケジュール・キャンセル
├── Theme/
│   └── AppTheme.swift              # カラーパレット・フォント定義
├── Views/
│   ├── RootView.swift              # 画面遷移ルーター（.id + .transition(.opacity)でアニメーション）
│   ├── OnboardingView.swift        # 初回起動：コンセプト説明 + 通知許可
│   ├── PromiseInputView.swift      # 約束入力：テキスト + 日付ピッカー
│   ├── PromiseDisplayView.swift    # 約束表示：内容 + 残り日数 + 取り消しボタン
│   ├── PromiseCheckView.swift      # 達成確認：「守れましたか？」はい/いいえ
│   ├── AchievementView.swift       # 達成演出：CosmicParticleEffect + テキストフェード
│   ├── AcceptanceView.swift        # 受容：責めない、事実として受け止める
│   └── CancelConfirmationView.swift # 取り消し確認シート：「言葉は命です」
└── Effects/
    └── CosmicParticleEffect.swift  # Canvas + TimelineView パーティクルシステム

Tests/
├── PromiseTests.swift              # Promiseモデルのテスト（6件）
└── AppViewModelTests.swift         # 画面遷移のテスト（10件）
```

### 設計判断と理由

| 判断 | 理由 |
|---|---|
| SwiftData不採用 → UserDefaults | 約束は常に1つ。保存するのはJSON 1つとフラグ1つだけ |
| NavigationStack不採用 → enum switch | アプリ状態がそのまま画面に対応。スタック管理不要 |
| 外部ライブラリなし | この規模では不要。依存ゼロで審査もシンプル |
| Canvas + TimelineView | SpriteKit等を使わずSwiftUI標準だけで達成演出を実現 |
| XcodeGenでプロジェクト管理 | .xcodeprojをgit管理しない。コンフリクト回避 |

---

## 重要な実装詳細

### isExpiredの閾値
`Promise.isExpired`は期限日の**午前9時**を基準に判定する（通知時刻と一致）。当初はstartOfDay（午前0時）だったがセルフレビューで修正済み。

### 取り消しUXの設計意図
取り消しは機能的に可能だが、UXで「言葉の重み」を伝える。「約束を続ける」を目立つアクセントカラー、「それでも取り消す」を極薄グレーの小テキストにして、継続をデフォルト行動に。

### 通知はローカル通知のみ
APNs（リモート通知）は一切不要。サーバーなし。`UNCalendarNotificationTrigger`で期限日9:00 JSTにスケジュール。

---

## 次のセッションですべきこと

### 最優先: Macでビルド確認
```bash
cd ~/dev/promise-to-myself
brew install xcodegen
xcodegen generate
open PromiseToMyself.xcodeproj
# Xcode: Signing → Team設定 → Cmd+R → Cmd+U
```

ビルドエラーが出たらClaude Codeに共有。linux環境で書いたコードなのでXcode固有の問題がある可能性あり。

### ビルド成功後
1. 全画面の動作確認（シミュレータ）
2. 通知テスト（NotificationServiceのtriggerを一時的に5秒後に変更して確認）
3. App Store素材作成（アイコン、スクショ、説明文）
4. GitHub Pages設定 → プライバシーポリシー公開
5. Apple Developer Program登録完了を待つ
6. App Store Connect → 申請

---

## 参照ドキュメント
- 要件定義書: `docs/requirements.md`
- 実装計画書: `docs/superpowers/plans/2026-04-09-promise-to-myself-ios.md`
- プライバシーポリシー: `docs/privacy-policy.html`
