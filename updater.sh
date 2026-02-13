#!/usr/bin/env bash
set -e

# Configuration
DOWNLOAD_API="https://api.lunarclientprod.com/site/download?os=linux"
FLAKE_FILE="flake.nix"

echo "🔍 Fetching latest version..."

# 1. Get the Real URL
HEADERS=$(curl -s -I "$DOWNLOAD_API")
RAW_URL=$(echo "$HEADERS" | grep -i "^location:" | sed 's/^location: //i' | tr -d '\r')

if [ -z "$RAW_URL" ]; then
    echo "❌ Error: Could not retrieve URL from headers."
    exit 1
fi

# 2. Prepare variables
ENCODED_URL="${RAW_URL// /%20}"
NEW_VERSION=$(echo "$RAW_URL" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
SANITIZED_NAME="lunar-client-${NEW_VERSION}.AppImage"

echo "✅ Version: $NEW_VERSION"
echo "📦 URL: $ENCODED_URL"

# 3. Calculate Hash
echo "⬇️  Calculating Hash..."
NEW_HASH=$(nix-prefetch-url --name "$SANITIZED_NAME" "$ENCODED_URL")
SRI_HASH=$(nix hash convert --hash-algo sha256 --to sri "$NEW_HASH")

echo "🔒 Hash: $SRI_HASH"

# 4. Safely update flake.nix
if [ -f "$FLAKE_FILE" ]; then
    echo "📝 Editing $FLAKE_FILE..."

    # Update version (General)
    sed -i -E "s/version = \".*\";/version = \"$NEW_VERSION\";/" "$FLAKE_FILE"

    # Update URL (Only where # LUNAR_URL comment exists)
    # The regex looks for: url = "..." # LUNAR_URL
    sed -i "s|url = \".*\"; # LUNAR_URL|url = \"$ENCODED_URL\"; # LUNAR_URL|" "$FLAKE_FILE"

    # Update Hash (Only where # LUNAR_HASH comment exists)
    sed -i "s|sha256 = \".*\"; # LUNAR_HASH|sha256 = \"$SRI_HASH\"; # LUNAR_HASH|" "$FLAKE_FILE"

    echo "🎉 Flake fixed and updated!"
    echo "🚀 You can now run: nix run ."
else
    echo "❌ File $FLAKE_FILE not found."
fi