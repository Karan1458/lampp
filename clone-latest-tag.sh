#!/bin/bash

set -euo pipefail
basename=${0##*/}

if [[ $# -lt 1 ]]; then
    printf '%s: Clone the latest tag on remote.\n' "$basename" >&2
    printf 'Usage: %s [other args] <remote>\n' "$basename" >&2
    exit 1
fi

remote=${*: -1} # Get last argument

echo "Getting list of tags from: $remote"

tag=$(git ls-remote --tags --exit-code --refs "$remote" \
  | sed -E 's/^[[:xdigit:]]+[[:space:]]+refs\/tags\/(.+)/\1/g' \
  | sort --version-sort | tail -n1)

echo "Selected tag: $tag"

# Clone as shallowly as possible. Remote is the last argument.
git clone --branch "$tag" --depth 1 --shallow-submodules --recurse-submodules "$@"