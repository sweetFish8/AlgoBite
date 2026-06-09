# AlgoBite 仕様書

## 1. アプリ概要

**AlgoBite** は、アルゴリズムとデータ構造を毎日少しずつ（Bite-size）学ぶ iOS アプリです。  
「コードの穴埋めパズル」と「処理順の並べ替えクイズ」を日替わりで出題し、クリア後はアルゴリズムの動きを SwiftUI アニメーションで視覚確認できます。

---

## 2. アーキテクチャ

| 項目 | 内容 |
|---|---|
| フレームワーク | SwiftUI |
| アーキテクチャ | MVVM |
| iOS 最小バージョン | iOS 17 |
| 外部パッケージ | なし |
| データ永続化 | UserDefaults（App Group 経由でウィジェットと共有） |
| App Group | `group.group.app.Goto.Sakana.AlgoBite` |

### 主要ファイル構成

```
AlgoBite/
├── AlgoBiteApp.swift          # エントリポイント
├── ContentView.swift          # NavigationStack とすべての画面
├── GameViewModel.swift        # 今日のチャレンジ・進行状態・ストリーク
├── Models.swift               # PuzzleProblem / PuzzleSlot モデル
├── AppTypes.swift             # AppScreen / DailyChallenge / SlotCheckState など
├── Problems.swift             # 穴埋めパズル 103 問のデータ
├── ReorderQuiz.swift          # 並べ替えクイズ UI と LCS 判定
├── ExplanationView.swift      # 解説 + アニメーション画面
├── TopicAnimations.swift      # アニメーションのルーティング
├── BuiltInAnimations.swift    # Binary Search など汎用アニメーション
├── Animations_DP.swift        # DP アニメーション
├── Animations_Sorting.swift   # ソートアニメーション
├── Animations_Graph.swift     # グラフアニメーション
├── Animations_Tree.swift      # 木アニメーション
├── Animations_LinkedList.swift
├── Animations_Stack.swift
├── Animations_String.swift
├── Animations_Math.swift
├── Animations_Misc.swift
├── PopStyle.swift             # デザインシステム
├── DebugCapture.swift         # デバッグ・スクショ補助（#if DEBUG のみ）
└── Extras/
    ├── ReorderQuizData.swift  # 並べ替えクイズ 31 問のデータ
    ├── ReorderQuizList.swift  # 並べ替え一覧画面
    ├── StatsStore.swift       # 学習統計（累計クリア数・トピック別）
    ├── Badges.swift           # バッジ定義とアンロック判定
    ├── BadgesCard.swift       # バッジ表示 UI
    ├── HintStore.swift        # ヒントテキスト
    ├── ReviewMode.swift       # 復習モード
    ├── OnboardingView.swift
    ├── AchievementsView.swift
    ├── SettingsView.swift
    ├── AppDefaults.swift      # UserDefaults キー定数
    ├── AppNotifications.swift # デイリーリマインダー
    ├── Haptics.swift
    ├── Icons.swift
    ├── TopicIllustration.swift
    ├── ShareSheet.swift
    └── StatsCard.swift

AlgoBiteWidget/
├── AlgoBiteWidget.swift
└── AlgoBiteWidgetBundle.swift
```

---

## 3. データモデル

### PuzzleProblem（`Models.swift`）
穴埋めパズル 1 問を表す。

| フィールド | 型 | 内容 |
|---|---|---|
| `id` | String | 一意の識別子（例: `"binary-search"`） |
| `title` | String | 問題タイトル |
| `difficulty` | String | `"Easy"` / `"Medium"` / `"Hard"` |
| `topic` | String | アルゴリズムカテゴリ |
| `prompt` | String | 問題文 |
| `example` | String | 入出力例 |
| `template` | [String] | `{{slot_id}}` を含むコードテンプレート行 |
| `slots` | [String: PuzzleSlot] | スロット定義（正解・選択肢・ラベル） |

### ReorderQuiz（`Extras/ReorderQuizData.swift`）
並べ替えクイズ 1 問を表す。

| フィールド | 型 | 内容 |
|---|---|---|
| `id` | String | 一意の識別子 |
| `title` | String | 問題タイトル |
| `topic` | String | アルゴリズムカテゴリ |
| `prompt` | String | 問題文 |
| `answer` | [String] | 正解の順序配列 |
| `pool` | [String] | ドラッグ操作用のシャッフル済み配列 |

### DailyChallenge（`AppTypes.swift`）
```swift
enum DailyChallenge: Hashable {
    case puzzle(PuzzleProblem)
    case reorder(ReorderQuiz)
}
```

### AppScreen（`AppTypes.swift`）
```swift
enum AppScreen: Hashable {
    case problem
    case reorder(ReorderQuiz)
    case dailyReorder(ReorderQuiz)
    case reorderList
    case review
    case practice(PuzzleProblem)
    case achievements
    case settings
}
```

---

## 4. 収録問題

### 穴埋めパズル：103 問

| 難易度 | 問題数 |
|---|---:|
| Easy | 40 |
| Medium | 49 |
| Hard | 14 |
| **合計** | **103** |

主なトピック内訳：

| トピック | 問題数 |
|---|---:|
| Dynamic Programming | 14 |
| Tree | 12 |
| Linked List | 6 |
| Sorting | 5 |
| Binary Search | 4 |
| Backtracking | 4 |
| Two Pointers | 3 |
| Bit Manipulation | 3 |
| Graph (BFS / DFS / Union Find / Topological / Shortest Path) | 9 |
| Trie | 2 |
| Sliding Window / Deque | 3 |
| Stack / Queue / Design | 7 |
| Heap / Greedy | 4 |
| String / Math | 15 |
| その他 | 11 |

### 並べ替えクイズ：31 問（26 トピック）

`ReorderQuiz.allList` に登録された 31 問を収録。トピックは 26 種類で、一部は複数問ある。

| トピック | 問題数 |
|---|---:|
| 木 / DFS | 3（前順・中順・後順） |
| ソート / マージソート | 2 |
| グラフ / BFS | 2 |
| ソート / バブルソート | 1 |
| ソート / 選択ソート | 1 |
| ソート / 挿入ソート | 1 |
| ソート / クイックソート | 1 |
| ソート / ヒープソート | 1 |
| ソート / counting sort | 1 |
| グラフ / DFS | 1 |
| グラフ / DAG | 1 |
| グラフ / ダイクストラ | 1 |
| グラフ / Union Find | 1 |
| 木 / BFS | 1 |
| データ構造 / スタック | 1 |
| データ構造 / キュー | 1 |
| データ構造 / デック | 1 |
| データ構造 / ヒープ | 1 |
| 二分探索 | 1 |
| DP / メモ化 | 1 |
| DP / LIS | 1 |
| バックトラック / 順列 | 1 |
| 再帰 / ハノイ | 1 |
| 再帰 / コールスタック | 1 |
| 文字列 / 反転 | 1 |
| 文字列 / KMP | 1 |
| **合計** | **31** |

クリア後のアニメーションは `topicAnimationFallback(topic:)` が日本語トピック名のキーワードで自動選択する（すべてのトピックでカバー済み）。

### 毎日の出題プール

穴埋め 3 問 → 並べ替え 1 問のインターリーブで結合した **134 問のローテーション**。  
当日の出題は `Calendar.current.ordinality(of: .day, in: .era, for: Date())` を pool サイズで割った余りで決定する。

---

## 5. コア機能

### 5.1 ホーム画面

- ストリーク（連続学習日数）をロールケーキ + いちごのカスタムアニメーションで表示
- 今日のチャレンジをプレビューカードで提示（タイトル・難易度・問題文・入出力例）
- クリア済みの場合は完了カードと解説を表示

### 5.2 穴埋めパズル

- コードテンプレート内のスロット（`{{id}}`）をタップして選択
- 下部パネルに選択肢チップを表示し、タップで入力
- 入力後は次の空スロットへ自動フォーカス移動
- 不正解スロットはシェイクアニメーション + 赤波線で再挑戦を促す

**ヒントシステム（2 段階）**

| 段階 | 内容 |
|---|---|
| ヒント 1/2 | `HintStore` からふんわりテキストヒントを表示 |
| ヒント 2/2 | 未回答スロット 1 箇所の正解を自動入力 |

### 5.3 並べ替えクイズ（`ReorderQuiz.swift`）

- コードブロックをドラッグ＆ドロップで正しい順序に並べる
- 採点に **LCS（最長共通部分列）アルゴリズム**を使用
  - LCS に含まれる（相対順序が正しい）ブロックはその場に残留
  - LCS に含まれないブロックのみシェイクしてプールに戻る

### 5.4 クリア後の解説とアニメーション

- `ExplanationView` でアルゴリズムの解説テキストを表示
- `TopicAnimations.swift` が問題 ID からアニメーションをルーティング
- **103 パターン**の SwiftUI アニメーション（各問題に 1 対 1 で対応）
- `@State token` + `DispatchQueue.main.asyncAfter` によるキャンセル・再実行可能なステップ実行

アニメーションカテゴリ：

| ファイル | 内容 |
|---|---|
| `BuiltInAnimations.swift` | Binary Search など汎用 |
| `Animations_DP.swift` | DP テーブル埋め・メモ化 |
| `Animations_Sorting.swift` | バブル・クイック・マージなど |
| `Animations_Graph.swift` | BFS / DFS / Dijkstra / Union Find |
| `Animations_Tree.swift` | 走査・反転・LCA など |
| `Animations_LinkedList.swift` | リバース・サイクル検出など |
| `Animations_Stack.swift` | スタック操作の可視化 |
| `Animations_String.swift` | KMP・アナグラムなど |
| `Animations_Math.swift` | GCD・素数など |
| `Animations_Misc.swift` | Trie・Heap など |

### 5.5 復習モード

- `ReviewMode.swift` で過去問題を一覧表示
- `.practice(PuzzleProblem)` ルートで開く
- ストリークに影響しない練習セッション

### 5.6 実績・統計

- 28 日間の活動ヒートマップ
- トピック別クリア数のグラフ

**バッジ（7 種類）**

| ID | タイトル | 絵文字 | 解除条件 |
|---|---|---|---|
| `first_clear` | はじめての一歩 | 🌱 | 累計 1 問クリア |
| `streak_3` | 3日連続 | 🔥 | 3 日連続クリア |
| `streak_7` | 1週間達成 | 🌟 | 7 日連続クリア |
| `reorder_first` | 並べ替えデビュー | 📋 | 並べ替え初クリア |
| `total_10` | 10問達成 | 🍪 | 累計 10 問クリア |
| `total_30` | 30問達成 | 🏅 | 累計 30 問クリア |
| `topic_5` | 得意分野 | 🎓 | 同一トピック 5 問クリア |

バッジ解除時は紙吹雪 + 絵文字のアニメーション演出あり。

### 5.7 Widget（`AlgoBiteWidget`）

- Small / Medium の 2 サイズに対応
- 表示内容: ストリーク日数・当日のクリア状況
- App Group 経由で本体アプリとデータ共有

### 5.8 通知

- `AppNotifications.swift` でデイリーリマインダーを管理
- 設定画面から通知時刻を変更可能
- 初回起動時のみ許可ダイアログを表示

---

## 6. デザインシステム（`PopStyle.swift`）

Duolingo にインスパイアされた Pop Aesthetic を採用。

| 要素 | 内容 |
|---|---|
| `Pop.primary` | グリーン（正解・ストリーク） |
| `Pop.accent` | アンバー（アクセント） |
| `Pop.danger` | レッド（不正解） |
| `PopButton` | 押下で沈み込む 3D ボタン |
| `PopCard` | 角丸 + ボーダーのカード |
| イラスト | `Shape` / `Path` で描画したスイーツ（クッキー・ドーナツ・ケーキ）<br>`TopicIllustration` でトピック別の抽象アルゴリズムアート |
| ダークモード | ライト / ダーク動的対応 |

---

## 7. データ永続化

学習状況はすべて App Group の UserDefaults に保存される。

| キー | 内容 |
|---|---|
| `algobite.streak` | 連続学習日数 |
| `algobite.lastSolvedDate` | 最終クリア日（yyyy-MM-dd） |
| `algobite.todayAnswers.<date>` | 当日の回答 |
| `algobite.todayResults.<date>` | 当日の正誤 |
| `algobite.todayAttempts.<date>` | 当日の試行回数 |
| `algobite.stats.totalSolved` | 累計クリア数 |
| `algobite.stats.reorderClears` | 並べ替えクリア累計 |
| `algobite.stats.topicCounts` | トピック別クリア数 |
| `algobite.stats.solvedDates` | クリアした日付一覧（ヒートマップ用） |
| `algobite.badges.unlocked` | 解除済みバッジ ID 配列 |
| `algobite.onboarded` | オンボーディング完了フラグ |
| `algobite.notifications.asked` | 通知許可ダイアログ表示済みフラグ |

設定画面の「進捗をリセット」は通知設定を保持したまま学習データを初期化する。

---

## 8. デバッグ機能（`DebugCapture.swift`）

`#if DEBUG` ブロック内にのみ存在し、Release ビルドには含まれない。

### デバッグビルド固定問題

デバッグビルドでは `todayChallenge` が常に **Climbing Stairs**（`climbing-stairs`）を返す。  
プログラミング未経験者でも直感的に分かる Easy 問題を固定することで、開発中のデバッグを容易にしている。  
変更する場合は `DebugCapture.pinnedProblemID` の文字列を書き換える。

### 起動引数フラグ（`-captureMode` 時のみ有効）

| フラグ | 内容 |
|---|---|
| `-captureMode` | オンボーディング・通知ダイアログをスキップ、撮影用サンプルデータを投入 |
| `-nav problem` | 起動時に問題画面へ直接遷移 |
| `-nav achievements` | 実績画面へ直接遷移 |
| `-nav settings` | 設定画面へ直接遷移 |
| `-nav reorderList` | 並べ替え一覧へ直接遷移 |
| `-nav review` | 復習一覧へ直接遷移 |
| `-selectSlot first` | 最初のスロットを選択状態にする |
| `-autoplay correct` | 全スロットに正解を自動入力して採点 |
| `-autoplay wrong` | 全スロットに不正解を自動入力して採点 |
| `-keepOnboarding` | オンボーディングをスキップしない |
| `-freshBadges` | バッジ・統計をリセットしてバッジ解除演出を撮影 |

---

## 9. App Store スクリーンショット自動化（`scripts/`）

Simulator 撮影 → Next.js エディタで装飾 → ZIP エクスポートまでを自動化するツール。

```
scripts/
├── app-store-screenshots.sh         # エントリポイント（コマンドディスパッチャー）
└── capture-app-store-screenshots.sh # シミュレータ撮影スクリプト

store-screenshots/                   # Next.js 15 スクリーンショットエディタ
├── src/components/editor/           # Toolbar / Sidebar / Inspector / Canvas
├── scripts/export.mjs               # Playwright ヘッドレスエクスポート
└── public/screenshots/apple/iphone/ja/  # 撮影した生スクショの置き場
```

### コマンド

| コマンド | 内容 |
|---|---|
| `./scripts/app-store-screenshots.sh setup` | npm install + Playwright Chromium のインストール |
| `./scripts/app-store-screenshots.sh capture` | シミュレータで 6 画面を撮影 |
| `./scripts/app-store-screenshots.sh edit` | エディタを localhost で起動 |
| `./scripts/app-store-screenshots.sh export` | Playwright でヘッドレスエクスポート（ZIP） |
| `./scripts/app-store-screenshots.sh all` | capture + export を一括実行 |

### 撮影される 6 画面

| ファイル名 | 画面 | フラグ |
|---|---|---|
| `01-home.png` | ホーム | `-captureMode` |
| `02-problem.png` | 問題（スロット選択中） | `-captureMode -nav problem -selectSlot first` |
| `03-problem-correct.png` | 問題（正解） | `-captureMode -nav problem -autoplay correct` |
| `04-achievements.png` | 実績 | `-captureMode -nav achievements` |
| `05-reorder-list.png` | 並べ替え一覧 | `-captureMode -nav reorderList` |
| `06-review.png` | 復習 | `-captureMode -nav review` |
