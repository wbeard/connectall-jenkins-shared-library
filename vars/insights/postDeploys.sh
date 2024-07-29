#!/bin/bash

_BUILD_COMPONENT=423575445565
_BUILD_END_TIME=1000
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

json="{ \"vsmDeploy\": {
          \"IsSuccessful\": \"$_IS_SUCCESSFUL\",
          \"TimeCreated\":  \"$_Formatted_Start_Date\",
          \"TimeDeployed\": \"$_Formatted_End_Date\",
          \"MainRevision\": \"$_MAIN_REVISION\",
          \"Component\":    \"$_BUILD_COMPONENT\",
          \"BuildId\":      \"$_BUILD_ID\"
        }
      }"

echo "Posting deploy to Insights"
echo "$json"


# Post to Insights
curl -sS -H "ZSESSIONID: $_INSIGHTS_API_KEY" -H 'Content-Type: application/json' -X POST -d "$json" $_INSIGHTS_API_URL/vsmdeploy/create?workspace=workspace/$_WORKSPACE_OID

echo "Deploy created successfully"