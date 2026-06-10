#!/usr/bin/env bash
set -euo pipefail

# App Store 用アプリプレビュー動画を撮影する。
# iPhone 16 Pro Max シミュレータ（録画解像度 1320x2868 = 6.9" 要件に合致）で
# 「ホーム → 問題を解いてクリア演出」の流れを録画し、ffmpeg で 30fps に整える。

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT="$ROOT_DIR/AlgoBite.xcodeproj"
SCHEME="${SCHEME:-AlgoBite}"
SIMULATOR_NAME="${SIMULATOR_NAME:-AlgoBite Preview}"
SIMULATOR_DEVICE_TYPE="${SIMULATOR_DEVICE_TYPE:-com.apple.CoreSimulator.SimDeviceType.iPhone-16-Pro-Max}"
BOOT_TIMEOUT_SECONDS="${BOOT_TIMEOUT_SECONDS:-180}"
DERIVED_DATA="$ROOT_DIR/.build/app-store-screenshots/DerivedData"
OUTPUT_DIR="$ROOT_DIR/store-screenshots/exports"
HOME_SECONDS="${HOME_SECONDS:-7}"
SOLVE_SECONDS="${SOLVE_SECONDS:-22}"
# 各クリップの最終的な尺（最後のフレームを静止保持して埋める）
HOME_TARGET="${HOME_TARGET:-5}"
SOLVE_TARGET="${SOLVE_TARGET:-20}"
# 冒頭の springboard / 起動白画面を削る秒数（ウォームアップ後はどちらも速く描画される）
HOME_TRIM="${HOME_TRIM:-2.0}"
SOLVE_TRIM="${SOLVE_TRIM:-1.6}"

run_with_timeout() {
  local seconds="$1"; shift
  perl -e '
    my $timeout = shift @ARGV;
    my $pid = fork();
    if ($pid == 0) { exec @ARGV or exit 127; }
    local $SIG{ALRM} = sub { kill "TERM", $pid; waitpid($pid, 0); exit 124; };
    alarm $timeout;
    waitpid($pid, 0);
    exit($? >> 8);
  ' "$seconds" "$@"
}

# --- シミュレータを用意（無ければ作成） ---
devices_json="$(run_with_timeout 30 xcrun simctl list devices available -j)"
device_udid="$(
  printf '%s' "$devices_json" | node -e '
    let raw=""; process.stdin.on("data",c=>raw+=c);
    process.stdin.on("end",()=>{
      const t=process.argv[1];
      const d=Object.values(JSON.parse(raw).devices).flat();
      const m=d.find(x=>x.name===t && x.isAvailable);
      if(!m) process.exit(1);
      process.stdout.write(m.udid);
    });
  ' "$SIMULATOR_NAME"
)" || true

if [[ -z "$device_udid" ]]; then
  runtimes_json="$(run_with_timeout 30 xcrun simctl list runtimes available -j)"
  simulator_runtime="$(
    printf '%s' "$runtimes_json" | node -e '
      let raw=""; process.stdin.on("data",c=>raw+=c);
      process.stdin.on("end",()=>{
        const r=JSON.parse(raw).runtimes
          .filter(x=>x.isAvailable && x.platform==="iOS")
          .sort((a,b)=>a.version.localeCompare(b.version,undefined,{numeric:true}));
        const l=r.at(-1); if(!l) process.exit(1);
        process.stdout.write(l.identifier);
      });
    '
  )"
  device_udid="$(run_with_timeout 30 xcrun simctl create "$SIMULATOR_NAME" "$SIMULATOR_DEVICE_TYPE" "$simulator_runtime")"
  echo "Created Simulator: $SIMULATOR_NAME ($device_udid)"
fi

TMP="$(mktemp -d)"
mkdir -p "$OUTPUT_DIR"

cleanup() {
  # 注意: ここで shutdown すると次回起動が headless になり recordVideo が空になるため、
  # デバイスは起動したまま（Simulator.app に GUI 接続したまま）残す。
  rm -rf "$TMP"
}
trap cleanup EXIT

# --- 起動 ---
devices_text="$(run_with_timeout 30 xcrun simctl list devices)"
if ! printf '%s' "$devices_text" | grep -F "$device_udid" | grep -q "(Booted)"; then
  run_with_timeout 30 xcrun simctl boot "$device_udid"
fi
run_with_timeout "$BOOT_TIMEOUT_SECONDS" xcrun simctl bootstatus "$device_udid" -b

run_with_timeout 30 xcrun simctl status_bar "$device_udid" override \
  --time "9:41" --batteryState charged --batteryLevel 100 --wifiBars 3 --cellularBars 4

# --- アプリをビルド & インストール ---
xcodebuild -project "$PROJECT" -scheme "$SCHEME" -configuration Debug \
  -destination "platform=iOS Simulator,id=$device_udid" \
  -derivedDataPath "$DERIVED_DATA" CODE_SIGNING_ALLOWED=NO build

app_path="$(find "$DERIVED_DATA/Build/Products/Debug-iphonesimulator" -maxdepth 1 -name "$SCHEME.app" -print -quit)"
bundle_id="${BUNDLE_ID:-$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$app_path/Info.plist")}"
run_with_timeout 60 xcrun simctl install "$device_udid" "$app_path"

# --- 1クリップ録画 ---
# simctl の recordVideo は「画面が変化したフレーム」しか記録しない。
# そのため (1) 録画を先に開始 → (2) アプリ起動 の順にして、起動遷移〜アニメの動きを捉える。
record_clip() {
  local out="$1"; local seconds="$2"; shift 2
  run_with_timeout 15 xcrun simctl terminate "$device_udid" "$bundle_id" >/dev/null 2>&1 || true
  xcrun simctl io "$device_udid" recordVideo --codec h264 --force "$out" >/dev/null 2>&1 &
  local rec_pid=$!
  sleep 0.5
  run_with_timeout 30 xcrun simctl launch --terminate-running-process "$device_udid" "$bundle_id" "$@"
  sleep "$seconds"
  kill -INT "$rec_pid" 2>/dev/null || true   # ← pkill -f は自身も巻き込むので使わない
  wait "$rec_pid" 2>/dev/null || true
  sleep 1   # moov atom 書き込みの猶予
  echo "Recorded clip: $out (${seconds}s)"
}

# ホームは「今日まだ未完」のフレッシュ状態で見せたい。
# 素の -captureMode は今日を解決済みにしてしまうため、未完にリセットする -selectSlot を併用
# （-nav を渡さないのでホームに留まる。-selectSlot は問題画面でのみ作用する）。
# 事前ウォームアップ：初回コールド起動の長い白画面を避けるため、一度起動して捨てる
run_with_timeout 30 xcrun simctl launch --terminate-running-process "$device_udid" "$bundle_id" -captureMode >/dev/null 2>&1 || true
sleep 4
run_with_timeout 15 xcrun simctl terminate "$device_udid" "$bundle_id" >/dev/null 2>&1 || true

record_clip "$TMP/01-home.mov"  "$HOME_SECONDS" -captureMode -selectSlot first
record_clip "$TMP/02-solve.mov" "$SOLVE_SECONDS" -captureMode -nav problem -autoplay demo

# --- ffmpeg で結合 + 30fps 化（App Store は最大30fps） ---
STAMP="$(date +%Y%m%d-%H%M 2>/dev/null || echo preview)"
FINAL="$OUTPUT_DIR/algobite-app-preview-${STAMP}.mp4"

if command -v ffmpeg >/dev/null 2>&1; then
  # 各クリップ：30fps CFR 化 + 最後のフレームを静止保持して目標尺まで伸ばす + 解像度を 1320x2868 に固定。
  # in を trim 秒スキップ（冒頭の springboard/白画面除去）→ 解像度固定 → 末尾を静止保持 → target 秒に切り出し
  pad_clip() {
    local in="$1"; local out="$2"; local target="$3"; local trim="$4"
    ffmpeg -y -ss "$trim" -i "$in" \
      -vf "scale=1320:2868:force_original_aspect_ratio=decrease,pad=1320:2868:(ow-iw)/2:(oh-ih)/2,tpad=stop_mode=clone:stop_duration=30,fps=30,format=yuv420p" \
      -t "$target" -c:v libx264 -pix_fmt yuv420p "$out"
  }
  pad_clip "$TMP/01-home.mov"  "$TMP/01-home-pad.mp4"  "$HOME_TARGET"  "$HOME_TRIM"
  pad_clip "$TMP/02-solve.mov" "$TMP/02-solve-pad.mp4" "$SOLVE_TARGET" "$SOLVE_TRIM"

  : > "$TMP/list.txt"
  printf "file '%s'\n" "$TMP/01-home-pad.mp4"  >> "$TMP/list.txt"
  printf "file '%s'\n" "$TMP/02-solve-pad.mp4" >> "$TMP/list.txt"
  ffmpeg -y -f concat -safe 0 -i "$TMP/list.txt" \
    -c:v libx264 -pix_fmt yuv420p -profile:v high -level 4.0 -r 30 \
    -movflags +faststart -an "$FINAL"
  echo ""
  echo "✅ App preview ready: $FINAL"
  ffprobe -v error -select_streams v:0 \
    -show_entries stream=width,height,r_frame_rate -show_entries format=duration \
    -of default=noprint_wrappers=1 "$FINAL" 2>/dev/null || true
else
  cp "$TMP/01-home.mov"  "$OUTPUT_DIR/algobite-preview-01-home.mov"
  cp "$TMP/02-solve.mov" "$OUTPUT_DIR/algobite-preview-02-solve.mov"
  echo "⚠️ ffmpeg が無いため未結合。2クリップを $OUTPUT_DIR に保存しました。"
fi
