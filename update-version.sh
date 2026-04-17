#!/usr/bin/env bash

set -euo pipefail

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <new_version>"
    exit 1
fi

NEW_VERSION="$1"

# Optional: basic version validation (can be relaxed if needed)
if ! [[ "$NEW_VERSION" =~ ^[0-9A-Za-z.\-]+$ ]]; then
    echo "Error: invalid version format"
    exit 1
fi

# --- FUNCTION ---
update_version() 
{
    local file="$1"
    
    if [ ! -f "$file" ]; then
        echo "Warning: $file does not exist, skipping"
        return
    fi

    cp "$file" "${file}.bak"

    # Replace only the value of the given variable
    sed -i -E "s/(^version[[:space:]]*=[[:space:]]*')[^']+(')/\1${NEW_VERSION}\2/" "$file"

    cat "$file" | grep -e "^version *= *"
    rm "${file}.bak"
    echo "✔ Updated version in: $file"
	    
}

update_version "nut-base/build.gradle"
update_version "nut-core/build.gradle"
update_version "nut-finance/build.gradle"
update_version "nut-headless/build.gradle"
update_version "nut-lame/build.gradle"
update_version "nut-desktop/build.gradle"


echo "✅ version updated to $NEW_VERSION in all subprojects"


