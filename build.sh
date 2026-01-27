#!/bin/bash
set -ev

# Define variables
ROOT_DIR=$(pwd)
FLUTTER_SDK_DIR="$ROOT_DIR/flutter_sdk"
FLUTTER_BIN="$FLUTTER_SDK_DIR/bin/flutter"

# 1. Clear any existing SDK to ensure a fresh, correct version
rm -rf "$FLUTTER_SDK_DIR"

# 2. Clone the latest Stable Flutter SDK
echo "Installing Flutter Stable SDK..."
git clone https://github.com/flutter/flutter.git -b stable --depth 1 "$FLUTTER_SDK_DIR"

# 3. Setup Environment
export PATH="$FLUTTER_SDK_DIR/bin:$PATH"
export FLUTTER_HOME="$FLUTTER_SDK_DIR"

# 4. Verify Version (This will trigger the first-run download of artifacts)
$FLUTTER_BIN --version

# 5. Configure Web
$FLUTTER_BIN config --enable-web

# 6. Inject Environment Variables
mkdir -p assets
echo "SUPABASE_URL=$SUPABASE_URL" > assets/.env.local
echo "SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY" >> assets/.env.local
echo "API_BASE_URL=$API_BASE_URL" >> assets/.env.local

# 7. Build Website
# We use the absolute path to our fresh binary to be 100% sure
$FLUTTER_BIN precache --web
$FLUTTER_BIN config --enable-web
$FLUTTER_BIN pub get
$FLUTTER_BIN build web --release --web-renderer html

# 8. Move output to the expected location if necessary (Vercel uses build/web by default)
echo "Build complete!"
