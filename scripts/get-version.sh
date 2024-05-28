#!/bin/bash
FILE_PATH="./../lib/globals.dart"

# Extract version string from the file
VERSION=$(grep -o "currentVersion = '[^']*" "$FILE_PATH" | cut -d "'" -f 2)

echo "$VERSION"