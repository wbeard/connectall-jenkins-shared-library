#!/bin/bash

_BUILD_END_TIME=1000000000000
_BUILD_ID="package-a"
_BUILD_START_TIME=0
_IS_SUCCESSFUL=true
_MAIN_REVISION=4c7764765a2d159c22d3e3c7b93917f57d4238f3
_INSIGHTS_API_KEY=$INSIGHTS_API_KEY
_INSIGHTS_API_URL=$INSIGHTS_API_URL
_WORKSPACE_OID=41529001

_BUILD_START_TIME_INT=$((_BUILD_START_TIME / 1000))
_Formatted_Start_Date=$(date -u -r "$_BUILD_START_TIME_INT" +'%Y-%m-%dT%H:%M:%S%z')

_BUILD_END_TIME_INT=$((_BUILD_END_TIME / 1000))
_Formatted_End_Date=$(date -u -r "$_BUILD_END_TIME_INT" +'%Y-%m-%dT%H:%M:%S%z')

echo "Finding deploy by build id: ${_BUILD_ID}"

response=$(curl -s -H "ZSESSIONID: $_INSIGHTS_API_KEY" "$_INSIGHTS_API_URL/vsmdeploy?query=(BuildId%20=%20$_BUILD_ID)&workspace=workspace/$_WORKSPACE_OID&fetch=ObjectID")
deploy_id=$(echo "$response" | grep -o '"ObjectID":[^,}]*' | head -1 | sed 's/.*: //')

echo "printing deploy id"
echo "$deploy_id"

if [ -z "$deploy_id" ]; then
    echo "No deploy found for build $_BUILD_ID"
    exit 1
fi

json="{
    \"vsmDeploy\": {
        \"IsSuccessful\": \"$_IS_SUCCESSFUL\",
        \"TimeDeployed\": \"$_Formatted_End_Date\"
    }
}"

echo "Patching deploy in Insights"
echo "$json"

response=$(curl -s -o /dev/null -H "ZSESSIONID: $_INSIGHTS_API_KEY" -H 'Content-Type: application/json' -X POST -d "$json" "$_INSIGHTS_API_URL/vsmdeploy/$deploy_id?workspace=workspace/$_WORKSPACE_OID")

if [ $? -ne 0 ]; then
    echo "Failed to update deploy in Insights"
    exit 1
fi

echo ""
echo "Deploy updated successfully"