#!/bin/bash
# Builds Angry Dudes for macOS from the same Swift files as the iPhone app, using only the
# Command Line Tools (no Xcode needed), then runs it.
#
#   ios/tools/mac-preview.sh                    build and play in a window (mouse = finger)
#   ios/tools/mac-preview.sh --build-only       just build ios/build/mac/AngryDudes.app
#   ios/tools/mac-preview.sh --test SCRIPT [--out DIR]
#                                               play a scripted battle offscreen and save
#                                               screenshots (see ios/MacPreview/Headless.swift)
#   ios/tools/mac-preview.sh --icon FILE.png    draw the 1024 px app icon
set -euo pipefail

ios="$(cd "$(dirname "$0")/.." && pwd)"
root="$(dirname "$ios")"
app="$ios/build/mac/AngryDudes.app"
bin="$app/Contents/MacOS/AngryDudes"

mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"
sources=()
while IFS= read -r f; do sources+=("$f"); done < <(find "$ios/AngryDudes" "$ios/MacPreview" -name '*.swift' | sort)

swiftc -swift-version 5 -O -target "$(uname -m)-apple-macosx14.0" \
  -module-name AngryDudes -o "$bin" "${sources[@]}"

rsync -a --delete "$root/assets/" "$app/Contents/Resources/assets/"
cat > "$app/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key><string>AngryDudes</string>
  <key>CFBundleIdentifier</key><string>com.example.angrydudes.macpreview</string>
  <key>CFBundleName</key><string>Angry Dudes</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>0.1</string>
  <key>LSMinimumSystemVersion</key><string>14.0</string>
  <key>NSHighResolutionCapable</key><true/>
</dict>
</plist>
PLIST

case "${1:-}" in
  --build-only) echo "built $app" ;;
  --test|--icon) "$bin" "$@" ;;
  *) open "$app" ;;
esac
