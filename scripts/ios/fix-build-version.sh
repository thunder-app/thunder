#!/bin/bash

# This script fixes the version generated from Generated.xcconfig to not include the nightly build number.
# It'll read the current version from lib/globals.dart, and use that to update the version in Generated.xcconfig
# This is used to fix the version that gets generated when building the iOS app (e.g., 0.4.05 -> 0.4.0)

# Path to the lib/globals.dart file
VERSION_FILE_PATH="./../lib/globals.dart"

# Regular expression to match version number
VERSION_PATTERN="([0-9]+\.[0-9]+\.[0-9]+)"

# Path to the Generated.xcconfig file
GENERATED_XCCONFIG="./../ios/Flutter/Generated.xcconfig"

# Read current FLUTTER_BUILD_NAME from Generated.xcconfig
CURRENT_BUILD_NAME=$(grep -o "FLUTTER_BUILD_NAME=[^ ]*" "$GENERATED_XCCONFIG" | sed "s/FLUTTER_BUILD_NAME=//")
echo "Current FLUTTER_BUILD_NAME: $CURRENT_BUILD_NAME"

# Extract version number from lib/globals.dart
NEW_BUILD_NAME=$(grep -oE "$VERSION_PATTERN" "$VERSION_FILE_PATH")
echo "New FLUTTER_BUILD_NAME: $NEW_BUILD_NAME"

# Replace the old FLUTTER_BUILD_NAME with the new one in the Generated.xcconfig file
sed -i '' "s/FLUTTER_BUILD_NAME=$CURRENT_BUILD_NAME/FLUTTER_BUILD_NAME=$NEW_BUILD_NAME/" "$GENERATED_XCCONFIG"
echo "FLUTTER_BUILD_NAME updated in Generated.xcconfig"