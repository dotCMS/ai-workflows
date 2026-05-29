#!/usr/bin/env bash
# Find-or-update a single PR comment identified by STICKY_MARKER.
#
# Usage:   sticky-comment.sh <pr_number> <body_file>
# Env:     GH_TOKEN, GITHUB_REPOSITORY, STICKY_MARKER
#
# The marker MUST be the first line of the body file. We match comments whose
# body starts with the marker; the first match wins (there should only ever be one).

set -euo pipefail

PR_NUMBER="${1:?pr number required}"
BODY_FILE="${2:?body file required}"

: "${GH_TOKEN:?GH_TOKEN must be set}"
: "${GITHUB_REPOSITORY:?GITHUB_REPOSITORY must be set}"
: "${STICKY_MARKER:?STICKY_MARKER must be set}"

[ -r "$BODY_FILE" ] || { echo "Body file not readable: $BODY_FILE" >&2; exit 1; }

# gh api --paginate streams concatenated JSON arrays; piping to jq handles them in sequence.
# Using `--arg` keeps the marker shell-safe (avoids embedding it into a jq expression literal).
EXISTING_ID=$(
  gh api "repos/${GITHUB_REPOSITORY}/issues/${PR_NUMBER}/comments" --paginate \
    | jq -r --arg marker "$STICKY_MARKER" \
        '.[] | select(.body | startswith($marker)) | .id' \
    | head -1
)

# Defensive: if jq emitted anything non-numeric (shouldn't happen, but the value
# flows directly into an API path), refuse to use it and create a fresh comment.
if [ -n "$EXISTING_ID" ] && ! [[ "$EXISTING_ID" =~ ^[0-9]+$ ]]; then
  echo "::warning::EXISTING_ID is non-numeric ($EXISTING_ID); creating a new comment instead"
  EXISTING_ID=""
fi

# Build the request payload as JSON via stdin; jq does the body escaping.
PAYLOAD=$(jq -Rs --arg key body '{($key): .}' < "$BODY_FILE")

if [ -n "$EXISTING_ID" ]; then
  echo "Updating existing sticky comment $EXISTING_ID"
  echo "$PAYLOAD" | gh api "repos/${GITHUB_REPOSITORY}/issues/comments/${EXISTING_ID}" \
    -X PATCH --input -
else
  echo "Creating new sticky comment on PR #${PR_NUMBER}"
  echo "$PAYLOAD" | gh api "repos/${GITHUB_REPOSITORY}/issues/${PR_NUMBER}/comments" \
    -X POST --input -
fi
