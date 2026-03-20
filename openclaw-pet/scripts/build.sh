#!/bin/bash
# Build script for OpenClaw Pet

echo "🦞 Building OpenClaw Pet..."

# Check if xcodebuild is available
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode not found. Please install Xcode from App Store."
    exit 1
fi

# Get project directory
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Find .xcodeproj
PROJECT_FILE=$(find "$PROJECT_DIR" -name "*.xcodeproj" -maxdepth 2 | head -n 1)

if [ -z "$PROJECT_FILE" ]; then
    echo "❌ No Xcode project found. Creating one..."
    
    # Create project.yml for XcodeGen
    cat > "$PROJECT_DIR/project.yml" << 'EOF'
name: OpenClawPet
options:
  bundleIdPrefix: com.openclaw
  deploymentTarget:
    macOS: "14.0"
  xcodeVersion: "15.0"

settings:
  base:
    SWIFT_VERSION: "5.9"
    MACOSX_DEPLOYMENT_TARGET: "14.0"
    CODE_SIGN_IDENTITY: "-"
    CODE_SIGN_STYLE: Manual

targets:
  OpenClawPet:
    type: application
    platform: macOS
    sources:
      - path: Sources
        type: group
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.openclaw.pet
        INFOPLIST_FILE: Sources/Info.plist
        PRODUCT_NAME: OpenClaw Pet
        MARKETING_VERSION: "1.0.0"
        CURRENT_PROJECT_VERSION: "1"
        GENERATE_INFOPLIST_FILE: false
        CODE_SIGN_ENTITLEMENTS: Sources/OpenClawPet.entitlements
        ENABLE_HARDENED_RUNTIME: YES
    entitlements:
      path: Sources/OpenClawPet.entitlements
      properties:
        com.apple.security.app-sandbox: false
EOF
    
    # Check if xcodegen is installed
    if ! command -v xcodegen &> /dev/null; then
        echo "Installing XcodeGen..."
        brew install xcodegen
    fi
    
    # Generate project
    cd "$PROJECT_DIR"
    xcodegen generate
    
    echo "✅ Project generated. Opening in Xcode..."
    open "$PROJECT_DIR/OpenClawPet.xcodeproj"
else
    echo "Found project: $PROJECT_FILE"
    
    # Build
    echo "Building..."
    xcodebuild -project "$PROJECT_FILE" -scheme OpenClawPet -configuration Debug build
fi
