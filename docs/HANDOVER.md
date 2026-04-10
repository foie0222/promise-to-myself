# 引き継ぎドキュメント: 自分との約束

> 更新日: 2026-04-10
> 最終コミット: `8182743`

---

## 現在の状態

**ビルド確認完了、シミュレータ動作確認OK。** App Storeリリースに向けた準備段階。

### 完了済み
- 要件定義書（`docs/requirements.md`）
- 実装計画書（`docs/superpowers/plans/2026-04-09-promise-to-myself-ios.md`）
- 全Swiftソースコード（16ファイル）
- XcodeGen設定（`project.yml`）— Xcode 15.2 / XcodeGen 2.42.0対応済み
- ユニットテスト（Promise + AppViewModel 計16テスト、全合格）
- Assets.xcassets（AppIcon・AccentColorプレースホルダー）
- プライバシーポリシー（`docs/privacy-policy.html`）— メールアドレス記入済み
- App Storeメタデータ（`docs/appstore-metadata.md`）— 説明文・キーワード・審査メモ
- セルフレビュー → 8件の問題を修正済み
- 日本語入力バグ修正（TextField → TextEditor）
- Xcode 15.2でのビルド成功確認
- シミュレータ（iPhone 15 / iOS 17.2）での全画面動作確認

### 未完了
- [ ] アプリアイコン作成（1024x1024）→ Geminiで生成予定
- [ ] Apple Developer Program登録（年額12,800円）
- [ ] Xcode Cloud設定（ビルド＆TestFlight配信）
- [ ] TestFlightでの実機テスト
- [ ] App Storeスクリーンショット作成
- [ ] GitHub Pagesでプライバシーポリシー公開
- [ ] App Store申請

---

## 環境制約

| 項目 | 現状 | 影響 |
|---|---|---|
| Mac | MacBook Pro 2017 (Intel) | macOS 13が最終、Xcode 15.2が上限 |
| Xcode | 15.2 | iOS 17.2シミュレータまで対応 |
| iPhone | iOS 26.3.1 | USB経由の実機インストール不可（Xcodeバージョン不足） |

**実機テストはXcode Cloud + TestFlight経由で行う必要がある。**

### XcodeGen
Homebrew版はmacOS 13非対応。GitHub Releasesから直接ダウンロード済み:
```
/tmp/xcodegen/xcodegen/bin/xcodegen generate
```

---

## アーキテクチャ

### 技術スタック
- SwiftUI / Swift 5.9+ / iOS 17.0+
- データ: UserDefaults（JSONエンコード）
- 通知: UNUserNotificationCenter（ローカル通知）
- 外部依存: なし

### 画面遷移（State Machine）

```
AppScreen enum (6 states):

  onboarding → input → display → check → achievement → input
                 ↑                          ↘ acceptance → input
                 └── cancel ←── display
```

### ファイル構成と責務

```
PromiseToMyself/Sources/
├── App/
│   └── PromiseToMyselfApp.swift    # @main + UNUserNotificationCenterDelegate
├── Assets.xcassets/                # AppIcon + AccentColor
├── Models/
│   └── Promise.swift               # Codable構造体
├── Navigation/
│   └── AppScreen.swift             # AppScreen enum + AppViewModel
├── Services/
│   └── NotificationService.swift   # 通知の許可要求・スケジュール・キャンセル
├── Theme/
│   └── AppTheme.swift              # カラーパレット・フォント定義
├── Views/
│   ├── RootView.swift              # 画面遷移ルーター
│   ├── OnboardingView.swift        # 初回起動
│   ├── PromiseInputView.swift      # 約束入力（TextEditor使用）
│   ├── PromiseDisplayView.swift    # 約束表示
│   ├── PromiseCheckView.swift      # 達成確認
│   ├── AchievementView.swift       # 達成演出
│   ├── AcceptanceView.swift        # 受容
│   └── CancelConfirmationView.swift # 取り消し確認シート
└── Effects/
    └── CosmicParticleEffect.swift  # パーティクルシステム

Tests/
├── PromiseTests.swift              # Promiseモデルのテスト（6件）XCTest
└── AppViewModelTests.swift         # 画面遷移のテスト（10件）XCTest
```

---

## 次のステップ

### 1. アプリアイコン
Geminiで生成 → `PromiseToMyself/Sources/Assets.xcassets/AppIcon.appiconset/AppIcon.png` に配置 → Contents.jsonを更新

### 2. Apple Developer Program登録
1. developer.apple.com で登録（12,800円/年）
2. 登録完了後、Xcode CloudまたはGitHub Actionsでビルドパイプライン構築

### 3. Xcode Cloud でTestFlight配信
Developer Program登録後:
1. App Store Connect でアプリ登録
2. Xcode Cloud ワークフロー設定（main pushでビルド→TestFlight配信）
3. TestFlightで実機テスト（iOS 26.3.1のiPhoneで確認）

### 4. App Store申請
- スクリーンショット作成（シミュレータから取得可能）
- GitHub Pagesでプライバシーポリシー公開
- App Store Connect で申請

---

## 参照ドキュメント
- 要件定義書: `docs/requirements.md`
- 実装計画書: `docs/superpowers/plans/2026-04-09-promise-to-myself-ios.md`
- プライバシーポリシー: `docs/privacy-policy.html`
- App Storeメタデータ: `docs/appstore-metadata.md`
