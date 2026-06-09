# AlgoBite App Store Screenshots

Simulatorのアプリ画面を撮影し、App Store向けの見出し・背景・端末フレームを付けて、iPhoneの各提出サイズへ一括書き出しするプロジェクトです。

## Setup

リポジトリのルートで一度だけ実行します。

```bash
./scripts/app-store-screenshots.sh setup
```

## Commands

```bash
# 6画面をSimulatorから撮影
./scripts/app-store-screenshots.sh capture

# ブラウザ上のエディタで文言・配置を調整
./scripts/app-store-screenshots.sh edit

# 現在の設定から4サイズ x 6画面のZIPを自動生成
./scripts/app-store-screenshots.sh export

# 撮影からZIP生成まで一括実行
./scripts/app-store-screenshots.sh all
```

`capture` は既定で撮影専用の `AlgoBite Screenshots` Simulatorを作成して使用します。既存の別端末を使う場合:

```bash
SIMULATOR_NAME="iPhone 16 Pro" ./scripts/app-store-screenshots.sh capture
```

## Files

- `app-store-screenshots.json`: スライドの文言、テーマ、配置
- `public/screenshots/apple/iphone/ja/`: Simulatorから撮影した元画像
- `exports/`: App Store提出用ZIPの出力先

生成されるZIPには、各スライドの `1320x2868`、`1284x2778`、`1206x2622`、`1125x2436` のPNGが含まれます。
