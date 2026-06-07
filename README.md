# AlgoBite

毎日ひと口ずつ、アルゴリズムとデータ構造を学ぶためのiOSアプリです。

コードの穴埋めパズルと処理順の並べ替えクイズを解き、クリア後のアニメーションでアルゴリズムの動きを視覚的に確認できます。

![AlgoBite screens](screen-output/screens-overview.png)

## Features

- **今日のひと口**
  - 穴埋めパズルと並べ替えクイズを `3:1` の割合で日替わり出題
  - 全134問をローテーション
- **コード穴埋めパズル**
  - 103問を収録
  - コード中のスロットを選び、候補から回答
  - 不正解箇所の表示と再挑戦
  - テキストヒント、1スロット自動入力の2段階ヒント
- **並べ替えクイズ**
  - 31問を収録
  - LCS（最長共通部分列）を使い、正しい並びを残しながら誤った要素だけを戻す判定
- **アルゴリズムアニメーション**
  - DP、ソート、グラフ、木、文字列、連結リスト、スタックなどをSwiftUIで可視化
  - 問題クリア後に解説とアニメーションを表示
- **継続と振り返り**
  - ロールケーキといちごで連続学習日数を表示
  - 過去問題をストリークに影響なく解ける復習モード
  - 28日間の活動ヒートマップとトピック別統計
  - 条件に応じて解除される7種類のバッジ
- **通知とWidget**
  - 時刻を指定できるデイリーリマインダー
  - ストリークと当日のクリア状況を表示するSmall/Medium Widget
- **その他**
  - オンボーディング
  - 結果共有
  - ダークモード
  - 進捗リセット

## Screens

| Home | Problem | Correct | Wrong |
| --- | --- | --- | --- |
| ![Home](screen-output/01-home.png) | ![Problem](screen-output/02-problem.png) | ![Correct](screen-output/03-problem-correct.png) | ![Wrong](screen-output/04-problem-wrong.png) |

| Achievements | Settings | Reorder | Review |
| --- | --- | --- | --- |
| ![Achievements](screen-output/05-achievements.png) | ![Settings](screen-output/06-settings.png) | ![Reorder](screen-output/07-reorder-list.png) | ![Review](screen-output/08-review.png) |

## Tech Stack

- Swift 5
- SwiftUI
- Charts
- WidgetKit
- UserNotifications
- MVVM
- UserDefaults / App Group
- iOS 17+

外部パッケージには依存していません。

## Requirements

- macOS
- Xcode（iOS 17 SDKを利用できるバージョン）
- iOS 17以降の実機またはSimulator
- Apple Developer Team

## Getting Started

```bash
git clone git@github.com:sweetFish8/AlgoBite.git
cd AlgoBite
open AlgoBite.xcodeproj
```

Xcodeで次の設定を確認してから、`AlgoBite` schemeを実行してください。

1. `AlgoBite` と `AlgoBiteWidget` のSigning Teamを設定する
2. 両ターゲットのBundle Identifierを自分の環境で一意な値にする
3. 両ターゲットで同じApp Groupを有効にする
4. App Groupの識別子をアプリ側とWidget側のentitlements、および共有`UserDefaults`で一致させる

コマンドラインでのビルド確認:

```bash
xcodebuild \
  -project AlgoBite.xcodeproj \
  -scheme AlgoBite \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  build
```

## Project Structure

```text
AlgoBite/
├── AlgoBiteApp.swift              # App entry point
├── ContentView.swift              # Navigation and main screens
├── GameViewModel.swift            # Daily challenge and progress state
├── Models.swift                   # Puzzle models
├── Problems.swift                 # Code puzzle data
├── ReorderQuiz.swift              # Reorder quiz UI and LCS grading
├── ExplanationView.swift          # Explanation and animation screen
├── TopicAnimations.swift          # Animation routing
├── Animations_*.swift             # Topic-specific animations
├── PopStyle.swift                 # Design system
└── Extras/
    ├── ReorderQuizData.swift      # Reorder quiz data
    ├── StatsStore.swift           # Learning statistics
    ├── Badges.swift               # Badge definitions and unlock logic
    ├── SettingsView.swift         # Notifications and reset controls
    └── ...                        # Icons, onboarding, review, etc.

AlgoBiteWidget/
├── AlgoBiteWidget.swift
└── AlgoBiteWidgetBundle.swift
```

## Data and Progress

学習状況はApp Groupの`UserDefaults`に保存されます。

- ストリークと最終クリア日
- 当日の回答、正誤、試行回数
- 累計クリア数
- トピック別クリア数
- 活動日
- バッジ解除状況
- 通知設定

設定画面の「進捗をリセット」では、通知設定を残して学習データを初期化します。

## Debug Capture

Debugビルドでは起動引数を使って、画面確認用の状態を再現できます。

```bash
xcrun simctl launch booted <bundle-id> \
  -captureMode \
  -nav problem \
  -selectSlot first
```

主な引数:

| Argument | Description |
| --- | --- |
| `-captureMode` | オンボーディングと通知ダイアログを省略し、撮影用データを投入 |
| `-nav problem` | 問題画面へ直接移動 |
| `-nav achievements` | 実績画面へ直接移動 |
| `-nav settings` | 設定画面へ直接移動 |
| `-nav reorderList` | 並べ替え一覧へ直接移動 |
| `-nav review` | 復習一覧へ直接移動 |
| `-selectSlot first` | 最初のスロットを選択 |
| `-autoplay correct` | 正解を自動入力して採点 |
| `-autoplay wrong` | 不正解を自動入力して採点 |

これらの処理は`#if DEBUG`内にあり、Releaseビルドには含まれません。
