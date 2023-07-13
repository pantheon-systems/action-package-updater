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

# Extract the major version number
MAJOR_VERSION=$(echo "${NEW_RELEASE}" | cut -d'.' -f1)

echo "Major version: ${MAJOR_VERSION}"

MAJOR_VERSION_BRANCH="v${MAJOR_VERSION}"
if git show-ref --verify --quiet "refs/heads/${MAJOR_VERSION_BRANCH}"; then
  git checkout "${MAJOR_VERSION_BRANCH}"
  git merge --ff-only main
else
  git checkout -b "${MAJOR_VERSION_BRANCH}"
fi

git push origin "${MAJOR_VERSION_BRANCH}"