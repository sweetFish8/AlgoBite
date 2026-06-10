#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT="$ROOT_DIR/AlgoBite.xcodeproj"
SCHEME="${SCHEME:-AlgoBite}"
SIMULATOR_NAME="${SIMULATOR_NAME:-AlgoBite Screenshots}"
SIMULATOR_DEVICE_TYPE="${SIMULATOR_DEVICE_TYPE:-com.apple.CoreSimulator.SimDeviceType.iPhone-17-Pro}"
WAIT_SECONDS="${WAIT_SECONDS:-3}"
BOOT_TIMEOUT_SECONDS="${BOOT_TIMEOUT_SECONDS:-180}"
DERIVED_DATA="$ROOT_DIR/.build/app-store-screenshots/DerivedData"
OUTPUT_DIR="${OUTPUT_DIR:-$ROOT_DIR/store-screenshots/public/screenshots/apple/iphone/ja}"

run_with_timeout() {
  local seconds="$1"
  shift
  perl -e '
    my $timeout = shift;
    my $pid = fork();
    die "fork failed\n" unless defined $pid;
    if ($pid == 0) {
      setpgrp(0, 0);
      exec @ARGV;
      exit 127;
    }
    $SIG{ALRM} = sub {
      kill "TERM", -$pid;
      select undef, undef, undef, 0.5;
      kill "KILL", -$pid;
      waitpid($pid, 0);
      exit 124;
    };
    alarm $timeout;
    waitpid($pid, 0);
    alarm 0;
    exit($? >> 8);
  ' "$seconds" "$@"
}

if ! devices_json="$(run_with_timeout 30 xcrun simctl list devices available -j)"; then
  echo "CoreSimulator did not respond while listing devices." >&2
  exit 1
fi

device_udid="$(
  printf '%s' "$devices_json" |
    node -e '
      let raw = "";
      process.stdin.on("data", (chunk) => raw += chunk);
      process.stdin.on("end", () => {
        const target = process.argv[1];
        const devices = Object.values(JSON.parse(raw).devices).flat();
        const match = devices.find((device) => device.name === target && device.isAvailable);
        if (!match) process.exit(1);
        process.stdout.write(match.udid);
      });
    ' "$SIMULATOR_NAME"
)" || true

if [[ -z "$device_udid" ]]; then
  if ! runtimes_json="$(run_with_timeout 30 xcrun simctl list runtimes available -j)"; then
    echo "CoreSimulator did not respond while listing runtimes." >&2
    exit 1
  fi
  simulator_runtime="$(
    printf '%s' "$runtimes_json" |
      node -e '
        let raw = "";
        process.stdin.on("data", (chunk) => raw += chunk);
        process.stdin.on("end", () => {
          const runtimes = JSON.parse(raw).runtimes
            .filter((runtime) => runtime.isAvailable && runtime.platform === "iOS")
            .sort((a, b) => a.version.localeCompare(b.version, undefined, { numeric: true }));
          const latest = runtimes.at(-1);
          if (!latest) process.exit(1);
          process.stdout.write(latest.identifier);
        });
      '
  )"
  device_udid="$(
    run_with_timeout 30 \
      xcrun simctl create "$SIMULATOR_NAME" "$SIMULATOR_DEVICE_TYPE" "$simulator_runtime"
  )"
  echo "Created Simulator: $SIMULATOR_NAME ($device_udid)"
fi

CAPTURE_TMP="$(mktemp -d)"
mkdir -p "$OUTPUT_DIR" "$DERIVED_DATA"

cleanup() {
  run_with_timeout 15 xcrun simctl status_bar "$device_udid" clear >/dev/null 2>&1 || true
  run_with_timeout 15 xcrun simctl shutdown "$device_udid" >/dev/null 2>&1 || true
  rm -rf "$CAPTURE_TMP"
}
trap cleanup EXIT

if ! devices_text="$(run_with_timeout 30 xcrun simctl list devices)"; then
  echo "CoreSimulator did not respond while checking device state." >&2
  exit 1
fi
if ! printf '%s' "$devices_text" | grep -F "$device_udid" | grep -q "(Booted)"; then
  run_with_timeout 30 xcrun simctl boot "$device_udid"
fi
if ! run_with_timeout \
  "$BOOT_TIMEOUT_SECONDS" \
  xcrun simctl bootstatus "$device_udid" -b; then
  echo "Simulator did not finish booting within ${BOOT_TIMEOUT_SECONDS}s: $SIMULATOR_NAME" >&2
  echo "Open Xcode > Window > Devices and Simulators, then retry capture." >&2
  exit 1
fi

run_with_timeout 30 xcrun simctl status_bar "$device_udid" override \
  --time "9:41" \
  --batteryState charged \
  --batteryLevel 100 \
  --wifiBars 3 \
  --cellularBars 4

xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Debug \
  -destination "platform=iOS Simulator,id=$device_udid" \
  -derivedDataPath "$DERIVED_DATA" \
  CODE_SIGNING_ALLOWED=NO \
  build

app_path="$(find "$DERIVED_DATA/Build/Products/Debug-iphonesimulator" -maxdepth 1 -name "$SCHEME.app" -print -quit)"
if [[ -z "$app_path" ]]; then
  echo "Built app not found under $DERIVED_DATA" >&2
  exit 1
fi

bundle_id="${BUNDLE_ID:-$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$app_path/Info.plist")}"
run_with_timeout 60 xcrun simctl install "$device_udid" "$app_path"

capture() {
  local filename="$1"
  shift
  run_with_timeout 15 xcrun simctl terminate "$device_udid" "$bundle_id" >/dev/null 2>&1 || true
  run_with_timeout 30 \
    xcrun simctl launch --terminate-running-process "$device_udid" "$bundle_id" "$@"
  sleep "$WAIT_SECONDS"
  # macOS TCC の制限で Desktop 配下に simctl が直接書けない場合があるため
  # 一時ディレクトリに撮影してから OUTPUT_DIR へコピーする
  run_with_timeout 60 \
    xcrun simctl io "$device_udid" screenshot "$CAPTURE_TMP/$filename"
  cp "$CAPTURE_TMP/$filename" "$OUTPUT_DIR/$filename"
  echo "Captured $filename"
}

capture "01-home.png" -captureMode
capture "02-problem.png" -captureMode -nav problem -selectSlot first
WAIT_SECONDS=8 capture "03-problem-correct.png" -captureMode -nav problem -autoplay correct
capture "04-achievements.png" -captureMode -nav achievements
capture "05-reorder-list.png" -captureMode -nav reorderList
capture "06-review.png" -captureMode -nav review

echo "Source screenshots: $OUTPUT_DIR"
