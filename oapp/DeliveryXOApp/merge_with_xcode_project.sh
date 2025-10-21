#!/bin/bash

# Script to merge scaffolding files with Xcode-generated project
# Run this after creating the Xcode project

set -e

echo "🔄 Merging scaffolding files with Xcode project..."

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Check if Xcode project exists
if [ ! -d "DeliveryXOApp.xcodeproj" ]; then
    echo "❌ Error: DeliveryXOApp.xcodeproj not found"
    echo "Please create the Xcode project first:"
    echo "  1. Open Xcode"
    echo "  2. File → New → Project → iOS App"
    echo "  3. Name: DeliveryXOApp"
    echo "  4. Save to: /Users/fahdayoubi/dev/deliveryx/oapp/"
    exit 1
fi

echo "✅ Found Xcode project"

# Backup Xcode-generated files
echo "📦 Backing up Xcode-generated files..."
mkdir -p .xcode_backup
cp -r DeliveryXOApp.xcodeproj .xcode_backup/ 2>/dev/null || true
cp DeliveryXOApp/Info.plist .xcode_backup/ 2>/dev/null || true
cp DeliveryXOApp/Assets.xcassets/Contents.json .xcode_backup/ 2>/dev/null || true

# Copy our scaffolding files (they're already in place, just verify)
echo "📁 Verifying scaffolding files..."

# Models
if [ -d "DeliveryXOApp/Models" ]; then
    echo "  ✅ Models/ folder exists"
else
    echo "  ❌ Models/ folder missing - something went wrong"
    exit 1
fi

# Services
if [ -d "DeliveryXOApp/Services" ]; then
    echo "  ✅ Services/ folder exists"
else
    echo "  ❌ Services/ folder missing - something went wrong"
    exit 1
fi

# ViewControllers
if [ -d "DeliveryXOApp/ViewControllers" ]; then
    echo "  ✅ ViewControllers/ folder exists"
else
    echo "  ❌ ViewControllers/ folder missing - something went wrong"
    exit 1
fi

# Utils
if [ -d "DeliveryXOApp/Utils" ]; then
    echo "  ✅ Utils/ folder exists"
else
    echo "  ❌ Utils/ folder missing - something went wrong"
    exit 1
fi

# Check key files
echo "📄 Checking key files..."
FILES=(
    "DeliveryXOApp/AppDelegate.swift"
    "DeliveryXOApp/SceneDelegate.swift"
    "DeliveryXOApp/Info.plist"
    "DeliveryXOApp/LaunchScreen.storyboard"
    "Podfile"
)

for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✅ $file"
    else
        echo "  ❌ $file missing"
        exit 1
    fi
done

echo ""
echo "✅ All scaffolding files verified!"
echo ""
echo "Next steps:"
echo "  1. pod install"
echo "  2. open DeliveryXOApp.xcworkspace"
echo "  3. Add files to Xcode project (Models, Services, ViewControllers, Utils)"
echo "  4. Delete default ViewController.swift"
echo "  5. Build and run (Cmd + R)"
echo ""
