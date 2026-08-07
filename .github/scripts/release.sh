#!/usr/bin/env bash
set -euo pipefail
# -e: exit immediately if any command fails
# -u: treat unset variables as errors instead of creating empty strings
# '-o pipefail': pipelines fail if any command in it fails

# HOW THIS WORKFLOW WORKS

# 1. Edit `VERSION` (in project root) to set the new version. (Use "1.2.4-rc1"`for pre-releases)
# 2. Commit the change and push/merge it to main.
# 3. On your local machine, fetch and pull the latest changes from `main`.
# 4. Run the release command (make/just release)

# This script will:
# - Check that devscripts is installed.
# - Check that you're on the `main` branch.
# - Check that there's no uncommitted changes.
# - Check that it's up to date with `origin/main`.
# - Check that the VERSION file matches the CHANGELOG.md file

if ! command -v dch &> /dev/null; then
	echo "Missing devscripts package. Must install first..."
    sudo apt install devscripts
fi

echo "Current working dir: $(pwd)"

# Check if on main branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
	echo "Error: You are not on the main branch. Switch to main."
	exit 1
fi

# Check for unstaged changes
if ! git diff --quiet; then
	echo "Error: There are unstaged changes. Must stage all changes first."
	read -r -p "Do you want to stage all changes? [y/N] " response

	if [[ "$response" =~ ^[Yy]$ ]]; then
		echo "Staging all..."
		git add -A
	else
		echo "Aborting."
		exit 1
	fi
else
	echo "All changes are staged."
fi

# Fetch latest changes from remote
git fetch

# Check if local main is up to date with origin/main
if ! git rev-parse origin/main > /dev/null 2>&1; then
	echo "Error: Remote branch origin/main does not exist. Set up a remote tracking branch."
	exit 1
fi
LOCAL_HASH=$(git rev-parse main)
REMOTE_HASH=$(git rev-parse origin/main)
if [ "$LOCAL_HASH" != "$REMOTE_HASH" ]; then
	echo "Error: Your local main branch is not up to date with origin/main. Pull the latest changes first."
	exit 1
fi

CHANGELOG_FILE="CHANGELOG.md"
if [ ! -f "CHANGELOG.md" ]; then
    echo "Error: CHANGELOG.md does not exist." >&2
    exit 1
fi

VERSION=$(cat VERSION)
echo "Found version ${VERSION}"

CHANGELOG_VERSION=$(grep -m 1 '^## ' CHANGELOG.md | sed -E 's/^## *\[?v?([0-9]+\.[0-9]+\.[0-9]+[a-zA-Z0-9.-]*)\]?.*/\1/')

if [ "$VERSION" != "$CHANGELOG_VERSION" ]; then
	echo "Error: VERSION file ($VERSION) does not match latest CHANGELOG.md entry ($CHANGELOG_VERSION)"
	exit 1
fi

echo "VERSION and CHANGELOG.md are in sync: $VERSION"

LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

if [ -z "$LAST_TAG" ]; then
	echo "No previous tag found, treating as changed"
else
	LAST_TAG_VERSION=$(git show "$LAST_TAG:VERSION" 2>/dev/null || echo "")
	if [ "$VERSION" != "$LAST_TAG_VERSION" ]; then
		echo "Version $VERSION is different from last tag ($LAST_TAG_VERSION)"
	else
		echo "ERROR: VERSION ($VERSION) is the same as most recent tag. Aborting"
		exit 1
	fi
fi

LATEST_NOTES=$(awk '/^## / { if (++count == 2) exit; next } count == 1 { print }' "CHANGELOG.md")

read -r -p "Are you sure you want to continue? [y/N] " response

if [[ "$response" =~ ^[Yy]$ ]]; then
    echo "Continuing..."
else
    echo "Aborting."
    exit 1
fi


CHANGELOG_FILE="./debian/changelog"

# This is from the devscripts package
# "" as the message : create the entry with no bullet text yet;
#                      we'll append each bullet in the loop below
dch -c "$CHANGELOG_FILE" -v "$VERSION" -D unstable ""

# -c FILE      : use FILE instead of the default debian/changelog
# -v VERSION   : create a new entry for this version (same as --newversion)
# -D DIST      : set the distribution field (e.g. unstable)

# Read CHANGELOG.md one line at a time.
# IFS= and -r stop `read` from trimming whitespace or treating
# backslashes specially, so lines come through intact.
while IFS= read -r line; do
    [[ -z "$line" ]] && continue                  # skip blank lines

    # skip markdown header lines with **
    if [[ "$line" =~ ^\*\*.*\*\*:?$ ]]; then
        continue
    fi
    line="${line#- }"   # strip leading "- " markdown bullet marker

    # -a : append this text as a new bullet ("*") to the entry
    #      created above, instead of starting a new version entry
    dch -c "$CHANGELOG_FILE" -a "$line"

done <<< "$LATEST_NOTES"

# -r : close out ("release") the changelog entry, stamping the
#      current date/time and finalizing it
dch -c "$CHANGELOG_FILE" -r ""

read -r -p "Debian changelog updated. Ready to commit? [y/N] " response

if [[ "$response" =~ ^[Yy]$ ]]; then
	echo "Adding updated changelog..."
	git add -A
    echo "Committing..."
	git commit
else
    echo "Aborting."
    exit 1
fi