#!/usr/bin/env bash

# HOW THIS WORKFLOW WORKS
# This workflow automates building a Debian package and creating a GitHub Release.

# --- Manual Steps ---
# 1. Edit `pyproject.toml` to set the new version (e.g., `version = "1.2.3"` or
#    `version = "1.2.4-rc1"` for pre-releases).
# 2. Commit the change and merge it to the `main` branch (From the feature branch or  
#    however you work).
# 3. On your local machine, fetch and pull the latest changes from `main` to ensure
#    you're up to date.
# 4. Run the release script, then push the tags to GitHub (conditonal on success):

#    `bash .github/scripts/release.sh && git push --tags`

# This command will:
# - Check that you're on the `main` branch and that it's up to date with `origin/main`.
# - Create a new tag based on the version in `pyproject.toml`.
# - Pushes the new tag to github which, triggers this workflow file.


# The -e flag makes bash exit immediately if any command fails
# The -u flag treats unset variables as errors instead of creating empty strings
# The -o pipefail flag makes a pipeline (like cmd1 | cmd2) fail if any command in it fails
set -euo pipefail

# Step 1 of the 'release' workflow. (`make release`).
# We must be on main and it must be up to date with origin/main for the process
# to continue.
# This is because it creates a new tag based on the version in pyproject.toml,
# and then pushes the tag to GitHub. Tags are metadata that go over the top of
# branches and commits, so they're not blocked by branch protection rules.

# If we're not on main or it's not up to date with origin/main, problems could
# occur, such as:
# - The 'version' in pyproject.toml doesn't match what's in the online main
#   branch on Github
# - You push a tag that points to a commit that Github hasn't seen yet,
# it's a pain in the ass to fix if you do any of these things by mistake.

# Check if on main branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
	echo "Error: You are not on the main branch. Please switch to main."
	exit 1
fi

# Check for uncommitted changes
if [ -n "$(git status --porcelain)" ]; then
	echo "Error: There are uncommitted changes. Please commit or stash them."
	exit 1
fi

# Fetch latest changes from remote
git fetch

# Check if local main is up to date with origin/main
if ! git rev-parse origin/main > /dev/null 2>&1; then
	echo "Error: Remote branch origin/main does not exist. Please set up a remote tracking branch."
	exit 1
fi
LOCAL_HASH=$(git rev-parse main)
REMOTE_HASH=$(git rev-parse origin/main)
if [ "$LOCAL_HASH" != "$REMOTE_HASH" ]; then
	echo "Error: Your local main branch is not up to date with origin/main. Please pull the latest changes."
	exit 1
fi


# grep '^version' finds lines starting with 'version' (^ anchors to line start,
# preventing false matches on keys like 'requires-python').
# head -1 takes only the first line (just to be safe).
# sed then strips everything except the version string itself, using a capture
# group \(.*\) to grab what's between the quotes, and \1 to output just that.
version=$(grep '^version' pyproject.toml | head -1 | sed 's/version = "\(.*\)"/\1/')
tag="v${version}"

echo "Found version ${version}. Creating tag: ${tag}"

if git tag "$tag"; then
    echo "Successfully created tag '${tag}'."
else
    echo "Error: Could not create tag '${tag}'."
    exit 1
fi