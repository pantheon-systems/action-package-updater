#!/bin/sh
set -e

curl -sL https://git.io/autotag-install | sh --

# fetch all tags and history:
git fetch --tags --unshallow --prune

if [ "$(git rev-parse --abbrev-ref HEAD)" != "main" ]; then
  # ensure a local 'main' branch exists at 'refs/heads/main'
  git branch --track main origin/main
fi

NEW_RELEASE=$(./bin/autotag)
git push --tags
gh release create "v${NEW_RELEASE}" -t "v${NEW_RELEASE}" --generate-notes