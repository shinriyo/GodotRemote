#!/bin/sh
# Export and compile for a physical iPhone without contacting Apple for signing.
set -eu
project_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
godot_bin=${GODOT_BIN:-/Applications/Godot.app/Contents/MacOS/Godot}
mkdir -p "$project_dir/build/ios"
"$godot_bin" --headless --audio-driver Dummy --path "$project_dir" \
  --export-debug iOS "$project_dir/build/ios/GodotRemote4.zip"
xcrun xcodebuild -project "$project_dir/build/ios/GodotRemote4.xcodeproj" \
  -scheme GodotRemote4 -configuration Debug -sdk iphoneos \
  -destination 'generic/platform=iOS' \
  -derivedDataPath "$project_dir/build/ios-derived" \
  CODE_SIGNING_ALLOWED=NO build
