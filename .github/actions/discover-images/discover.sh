#!/usr/bin/env bash

set -euo pipefail

: "${HEAD_SHA:?head commit is required}"
: "${GITHUB_OUTPUT:?GITHUB_OUTPUT is required}"
base_sha=${BASE_SHA:-}
full_rebuild_paths=${FULL_REBUILD_PATHS:-}
require_base=${REQUIRE_BASE:-false}

empty_tree=$(git hash-object -t tree /dev/null)
diff_base=$empty_tree
unavailable=
if [[ -z $base_sha || $base_sha =~ ^0+$ ]] ||
   ! git cat-file -e "${base_sha}^{commit}" 2>/dev/null ||
   ! git cat-file -e "${HEAD_SHA}^{commit}" 2>/dev/null; then
  unavailable='the base commit is unavailable'
elif ! diff_base=$(git merge-base "$base_sha" "$HEAD_SHA"); then
  unavailable='no merge base could be determined'
  diff_base=$empty_tree
fi

if [[ -n $unavailable ]]; then
  if [[ $require_base == true ]]; then
    echo "::error::Refusing to select images because $unavailable; history was probably rewritten."
    exit 1
  fi
  echo "::warning::Selecting every current image because $unavailable."
fi

mapfile -t changed_files < <(git diff --name-only "$diff_base" "$HEAD_SHA")
mapfile -t rebuild_patterns < <(printf '%s\n' "$full_rebuild_paths" | sed '/^[[:space:]]*$/d')

for path in "${changed_files[@]}"; do
  for pattern in "${rebuild_patterns[@]}"; do
    # shellcheck disable=SC2053 # Patterns are supplied as globs on purpose.
    if [[ $path == $pattern ]]; then
      echo "::notice::$path matches '$pattern'; selecting every current image."
      mapfile -t changed_files < <(git ls-tree -r --name-only "$HEAD_SHA")
      break 2
    fi
  done
done

declare -A seen=()
images=()
for path in "${changed_files[@]}"; do
  [[ $path == */* ]] || continue
  image=${path%%/*}
  if [[ -z ${seen["$image"]+present} ]] &&
     git cat-file -e "$HEAD_SHA:$image/Dockerfile" 2>/dev/null; then
    seen["$image"]=1
    images+=("$image")
  fi
done

{
  printf 'images='
  jq -cn '$ARGS.positional' --args "${images[@]}"
} >> "$GITHUB_OUTPUT"
