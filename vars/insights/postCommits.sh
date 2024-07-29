#!/bin/bash

_CURRENT_BUILD_COMMIT=HEAD
_DEPLOY_ID=423575567561
_GIT_REPO_LOC="."
_INSIGHTS_API_KEY=$INSIGHTS_API_KEY
_INSIGHTS_API_URL=$INSIGHTS_API_URL
_PREVIOUS_SUCCESS_BUILD_COMMIT=HEAD~2
_WORKSPACE_OID=41529001

touch "$_GIT_REPO_LOC/commit_log"
git --git-dir=$_GIT_REPO_LOC/.git log --pretty=format:'%H %ad' --date=iso $_PREVIOUS_SUCCESS_BUILD_COMMIT..$_CURRENT_BUILD_COMMIT > "$_GIT_REPO_LOC/commit_log"
echo >> $_GIT_REPO_LOC/commit_log

echo ""
echo "Deploy ID: $_DEPLOY_ID"

while IFS= read -r input_text; do
    read -r commit_id timestamp <<< "$input_text"

    # formatted_date=\$(date -d \"\$timestamp\" +'%Y-%m-%dT%H:%M:%S%z')
    formatted_date=$(date -j -f '%Y-%m-%d %H:%M:%S %z' "$timestamp" +'%Y-%m-%dT%H:%M:%S%z')

    json="{
      \"vsmChange\": {
        \"Revision\":   \"$commit_id\",
        \"CommitTime\": \"$formatted_date\",
        \"Deploy\":     \"$_DEPLOY_ID\"
      }
    }"

    curl -sS -o /dev/null -H "ZSESSIONID: $_INSIGHTS_API_KEY" -H 'Content-Type: application/json' -X POST -d "$json" $_INSIGHTS_API_URL/vsmchange/create?workspace=workspace/$_WORKSPACE_OID
done < "$_GIT_REPO_LOC/commit_log"