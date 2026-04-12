#!/usr/bin/env bash

set -euo pipefail

base_sha=${1:-}
head_sha=${2:-HEAD}

empty_tree_sha=$(git hash-object -t tree /dev/null)

if [ -z "$base_sha" ] || [ "$base_sha" = "0000000000000000000000000000000000000000" ]; then
  base_sha=$empty_tree_sha
fi

if [ -z "$head_sha" ]; then
  head_sha=HEAD
fi

changed_dirs=$(
  git diff --name-only "$base_sha" "$head_sha" |
    cut -d/ -f1 |
    sort -u |
    while read -r dir; do
      if [ -f "$dir/Dockerfile" ]; then
        printf '%s\n' "$dir"
      fi
    done
)

printf '%s\n' "$changed_dirs" |
  jq -R -s -c 'split("\n") | map(select(. != ""))'
