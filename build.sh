#!/bin/bash

# 1. Clone Flutter
if [ ! -d "flutter" ]; then
    git clone https://github.com/flutter/flutter.git -b stable
fi

# 2. Add Flutter to path (PREPEND to ensure we use our cloned version)
export PATH="`pwd`/flutter/bin:$PATH"

# 3. Enable web and verify version
flutter --version
flutter config --enable-web

# 4. Inject Environment Variables into assets/.env.local
# This is required because Flutter Web loads these at runtime from assets
mkdir -p assets
echo "SUPABASE_URL=$SUPABASE_URL" > assets/.env.local
echo "SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY" >> assets/.env.local
echo "API_BASE_URL=$API_BASE_URL" >> assets/.env.local

# 5. Clear and build
# Using --web-renderer html to avoid CanvasKit/WASM "Aborted" errors on Vercel
flutter build web --release --web-renderer html
