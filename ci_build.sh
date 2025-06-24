#!/bin/bash

git pull

# Use first argument as tag prefix, default to 'v'
ARGUMENT="${1:-v}"

# Get the latest tag with the specified prefix, default to ${ARGUMENT}0.0.0 if none exists
LATEST_TAG=$(git tag --sort=-v:refname | grep "^${ARGUMENT}" | head -n 1)
LATEST_TAG=${LATEST_TAG:-${ARGUMENT}0.0.0}

# Remove prefix to extract version
VERSION=${LATEST_TAG#${ARGUMENT}}

# Extract version number and increment the last part
IFS='.' read -r -a parts <<< "$VERSION"
((parts[2]++))

# Handle carrying over
if [ "${parts[2]}" -ge 10 ]; then
  parts[2]=0
  ((parts[1]++))
  if [ "${parts[1]}" -ge 10 ]; then
    parts[1]=0
    ((parts[0]++))
  fi
fi

# Generate new tag
NEW_TAG="${ARGUMENT}${parts[0]}.${parts[1]}.${parts[2]}"

# Create and push new tag
git tag "$NEW_TAG" && git push origin "$NEW_TAG"

echo "New tag created: $NEW_TAG"
