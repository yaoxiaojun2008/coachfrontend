#!/bin/bash
set -e

# Define absolute paths
ROOT_DIR=$(pwd)
FLUTTER_BIN="$ROOT_DIR/flutter/bin/flutter"

# 1. Clone Flutter (using depth 1 for speed)
if [ ! -d "flutter" ]; then
    echo "Cloning Flutter SDK..."
    git clone https://github.com/flutter/flutter.git -b stable --depth 1
fi

# 2. Setup path
export PATH="$ROOT_DIR/flutter/bin:$PATH"

# 3. Verify version and Enable web
$FLUTTER_BIN --version
$FLUTTER_BIN config --enable-web

# 4. Inject Environment Variables into assets/.env.local
mkdir -p assets
echo "SUPABASE_URL=$SUPABASE_URL" > assets/.env.local
echo "SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY" >> assets/.env.local
echo "API_BASE_URL=$API_BASE_URL" >> assets/.env.local

# 5. Build
# Using absolute path to ensure we use our stable version
$FLUTTER_BIN build web --release --web-renderer html
