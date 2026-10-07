#!/usr/bin/env bash

set -euo pipefail

set -x


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

    if ! grep -qE "^[[:space:]]*nutVersion[[:space:]]*=" "$file"; then
        echo "Warning: nutVersion not found in $file, skipping"
        return
    fi

    cp "$file" "${file}.bak"

    # Replace only the value of the given variable (with or without quotes)
    sed -i -E "s|^([[:space:]]*nutVersion[[:space:]]*=[[:space:]]*)(['\"]?)[^'\"#]*(['\"]?)|\1\2${NEW_VERSION}\3|" "$file"

    NEW_VALUE="$(sed -nE "s/^[[:space:]]*nutVersion[[:space:]]*=[[:space:]]*['\"]?([^'\"#[:space:]]+).*/\1/p" "$file")"

    if [ "$NEW_VALUE" != "$NEW_VERSION" ]; then
        mv "${file}.bak" "$file"
        echo "Error: failed to update nutVersion in $file (found: '${NEW_VALUE}')"
        exit 1
    fi

    rm "${file}.bak"
    grep -E "^[[:space:]]*nutVersion[[:space:]]*=" "$file"
    echo "✔ Updated version in: $file"
}

update_version "nut-base/gradle.properties"
update_version "nut-core/gradle.properties"
update_version "nut-finance/gradle.properties"
update_version "nut-headless/gradle.properties"
update_version "nut-lame/gradle.properties"
update_version "nut-desktop/gradle.properties"

for i in nut-base nut-core nut-finance nut-headless nut-lame nut-desktop
do
	(
		echo "--------------------"
		echo "$i"
		echo "--------------------"
		cd $i
		git add -A .
		git status
		
		read
		
		git commit -m "update nut version" || true
		git tag -a ${NEW_VERSION} -m "Version ${NEW_VERSION}" || git push --tags || git push
		git push
		git push --tags
	)
	git add $i
done

echo "✅ version updated to $NEW_VERSION in all subprojects"

echo "execute: git commit -m \"update nut version\"; git tag -a ${NEW_VERSION} -m \"Version ${NEW_VERSION}\"; git push --tags; git push"

