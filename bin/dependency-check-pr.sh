#!/bin/bash

set -eou pipefail
IFS=$'\n\t'
white="\e[97m"
green="\e[32m"
reset="\e[0m"

readonly AUTHOR_EMAIL="bot@getpantheon.com"
readonly AUTHOR_NAME="Pantheon Automation"

#####
# Sample dependencies.yml
# ---
# dependencies:
#   mongodb:
#     current_tag: 1.16.0
#     repo: mongodb-php-library
#     pr_note: "This message is appended to new pull requests"
#####

main() {
  for NAME in $(yq '.dependencies | to_entries | .[].key'  "${DEPENDENCIES_YML}"); do
    echo "Checking ${NAME}"

    local CURRENT_TAG
    CURRENT_TAG="$(yq ".dependencies.${NAME}.current_tag" "${DEPENDENCIES_YML}")"
    echo -e "Current Tag: ${white}${CURRENT_TAG}${reset}"

    local REPO
    REPO="$(yq ".dependencies.${NAME}.repo" "${DEPENDENCIES_YML}")"

    local SOURCE
    SOURCE="$(yq ".dependencies.${NAME}.source" "${DEPENDENCIES_YML}")"

    local LATEST_TAG
    LATEST_TAG="$(get_latest_tag "${REPO}" "${SOURCE}")"
    echo -e "Latest Tag: ${white}${LATEST_TAG}${reset}"

    # We likely don't even need to version compare, just ==
    if [[ "${CURRENT_TAG}" == "${LATEST_TAG}" ]]; then
      echo "${CURRENT_TAG} is the latest version..."
      continue
    fi

    local PR_TITLE_BASE="Bump ${REPO} from ${CURRENT_TAG}"
    local PR_TITLE="${PR_TITLE_BASE} to ${LATEST_TAG}"

    LIST_OF_PRS="$(gh pr list -R "${THIS_REPO}" \
      -l dependencies --json title,closed,number | jq -c)"

    local NUMBER_TO_CLOSE_LATER=""
    for PR in $(jq -c '.[]' <<<"${LIST_OF_PRS}"); do
      echo "${PR}"
      if [[ "$(jq -cr .title<<<"${PR}")" == *"${PR_TITLE}" ]]; then
        # This captures open PRs, or PRs closed without merging
        # Prepended wildcards allows PR to be manually edited with a JIRA ticket
        echo "PR Already Created"
        continue 2
      fi

      if [[ "$(jq -cr .title<<<"${PR}")" == *"${PR_TITLE_BASE}"* && "$(jq -cr .closed<<<"${PR}")" == "false" ]]; then
        echo "PR for a Previous version exists"
        NUMBER_TO_CLOSE_LATER="$(jq -cr .number<<<"${PR}")"
        echo "${NUMBER_TO_CLOSE_LATER}"
        break
      fi
    done

    # Define our GH User.
    git config --global user.email "${AUTHOR_EMAIL}"
    git config --global user.name "${AUTHOR_NAME}"

    BRANCH=DEPS-$(date +%s%N)
    git checkout -b "${BRANCH}"
    yq -i ".dependencies.${NAME}.current_tag = \"${LATEST_TAG}\"" "${DEPENDENCIES_YML}"
    git add "${DEPENDENCIES_YML}"

    # OUTPUT_FILE is optional, so it might not exist and we might not need to commit the change there.
    if  [[ -n "${OUTPUT_FILE}" ]]; then
      # Replace the version number in the output file
      replace_version_in_file "${NAME^^}" "${LATEST_TAG}"
      git add "${OUTPUT_FILE}"
    fi

    git commit -m "$PR_TITLE"

    if [[ ${DRY_RUN} == "false" ]]; then
        git push origin "${BRANCH}"

        PR_BODY="Bumps [${NAME}](https://github.com/${REPO}/releases/tag/${LATEST_TAG}) from ${CURRENT_TAG} to ${LATEST_TAG}."
        local PR_NOTE
        PR_NOTE=$(yq ".dependencies.${NAME}.pr_note" "${DEPENDENCIES_YML}")

        if [[ "${PR_NOTE}" != null && "${PR_NOTE}" != ""  ]];then
          PR_BODY="${PR_BODY}

${PR_NOTE}"
        fi
        
        create_label_if_not_exists "dependencies" "#207de5" "Dependencies"
        create_label_if_not_exists "automation" "#207de5" "Automation"
        NEW_PR=$(gh pr create -l dependencies,automation -t "${PR_TITLE}" -b "${PR_BODY}" -R "${THIS_REPO}")

        git checkout -

        if [[ -n "${NUMBER_TO_CLOSE_LATER}" ]]; then
        echo "Closing old PR #${NUMBER_TO_CLOSE_LATER}"
        gh pr close "${NUMBER_TO_CLOSE_LATER}" -R "${THIS_REPO}" -c "Closing in favor of ${NEW_PR}"
        fi
    fi
    echo
  done
  if [[ "${DRY_RUN}" == "true" ]]; then
    local diff_output=""
    echo "Dry run requested...checking the diff...🤔"
    BRANCH="${DEFAULT_BRANCH}"
    if [[ "${ACTIVE_BRANCH}" != "${BRANCH}" ]]; then
      if [[ "${ACTIVE_BRANCH}" =~ refs/pull/[0-9]+/merge ]]; then
        echo "Active branch is a PR branch."
        git fetch origin "${DEFAULT_BRANCH}" > /dev/null 2>&1
        # There are only two files tracked. If we start tracking more, we'll need to update this.
        files_to_compare=("${OUTPUT_FILE}" "${DEPENDENCIES_YML}")
        echo "Comparing changes between ${BRANCH} and ${ACTIVE_BRANCH}"
        for file in "${files_to_compare[@]}"; do
          diff_output+=$(git diff --color=always -U0 "origin/${DEFAULT_BRANCH}:${file}" "${file}")$'\n\n'
        done
      else
        echo "Default branch is ${BRANCH}, but active branch is ${ACTIVE_BRANCH}. We'll check out ${ACTIVE_BRANCH} instead."
        BRANCH="${ACTIVE_BRANCH}"
      fi
    fi
    # If we're doing a dry-run, let's output a diff so we can see that it did something.
    if [[ -n "${diff_output}" ]]; then
      echo "$diff_output"
    elif git rev-parse --verify HEAD >/dev/null 2>&1; then
      diff_output=$(git diff --color=always -U0 "${BRANCH}"...HEAD)
      echo "$diff_output"
    else
      echo "No commits found for diff."
    fi
  fi
  echo -e "✨ ${green}Done${reset} ✨"
}

# Get the latest tag from the source. If source is undefined, default to "github".
# Usage example: LATEST_TAG=$(get_latest_tag "mongodb-php-library" "pecl")
get_latest_tag() {
  local repo="$1"
  local source="$2"
  local LATEST_TAG

  # We're defaulting to GitHub, but we want to check against releases AND tags.
  if [[ "${source}" == "github" || "${source}" == "null" || "${source}" == "" ]]; then
    LATEST_TAG=$(gh release view -R "${REPO}" --json tagName -q .tagName 2>/dev/null)
    # Check for a release first, then fall back to tags
    if [[ -z "${LATEST_TAG}" ]]; then
      LATEST_TAG=$(gh api "repos/${REPO}/tags" --jq '.[0].name' 2>/dev/null)
    fi
  # Oh, you want a PECL?
  elif [[ "${source}" == "pecl" ]]; then
    LATEST_TAG=$(curl -s https://pecl.php.net/rest/r/"${repo}"/latest.txt)
  # New source, who dis?
  else
    echo "Unknown source: ${source}"
    exit 1
  fi

  echo "${LATEST_TAG}"
}

replace_version_in_file() {
  local name="$1"
  local version="$2"

  # Strip out non-numeric prefixes before the version number
  version=$(echo "$version" | sed 's/^[^0-9]*//' | sed 's/[^0-9.]//g')

  # Replace the version number in the output file
  sed -i "s/^declare -r ${name}_DEFAULT_VERSION=.*/declare -r ${name}_DEFAULT_VERSION=${version}/" "${OUTPUT_FILE}"
}

create_label_if_not_exists() {
  local label_name="$1"
  local label_color="$2"
  local label_description="$3"

  if ! gh label list -R "${THIS_REPO}" | grep -q "${label_name}"; then
    gh label create -R "${THIS_REPO}" -c "${label_color}" -d "${label_description}" "${label_name}"
  fi
}

main
