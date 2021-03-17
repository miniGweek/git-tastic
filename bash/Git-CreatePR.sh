#!/bin/bash
# Requires curl to send https post
# Requires JQ to be installed to show output
currentBranch=$(git branch --show-current)
commitMsgLine=$(git log -1 --oneline $currentBranch)
lastCommitHash=$(git rev-parse --short HEAD)
#Remove the commit # from the message
commitMsg="${commitMsgLine##$lastCommitHash}"
#Remove the extra space before the message body
commitMsg="${commitMsg## }"
title=$commitMsg
description=$commitMsg
devopsPRUri="https://dev.azure.com/${MYVAR_ORGANIZATION}/${MYVAR_PROJECT}/_apis/git/repositories/${MYVAR_REPOSITORYID}/pullrequests?api-version=6.0"

read -r -d '' requestBody <<EOM
 {
    'sourceRefName': 'refs/heads/$currentBranch',
    'targetRefName': 'refs/heads/master',
    'title':'$title',
    'description':'$description'
  }
EOM

result=$(
  curl -u ":${MYVAR_AZUREDEVOPSPAT}" \
    -H "Content-Type:application/json" \
    --data-raw "$requestBody" \
    -X POST \
    "$devopsPRUri"
)

prTitle=$(echo $result | jq -r '.title')
prDescription=$(echo $result | jq -r '.description')
pullRequestId=$(echo $result | jq -r '.pullRequestId')
prStatus=$(echo $result | jq -r '.status')
prCreationDate=$(echo $result | jq -r '.creationDate')
prSourceRefName=$(echo $result | jq -r '.sourceRefName')
prTargetRefName=$(echo $result | jq -r '.targetRefName')
prUrl=$(echo $result | jq -r '.url')

echo prTitle=$prTitle
echo prDescription=$prDescription
echo pullRequestId=$pullRequestId
echo prStatus=$prStatus
echo prCreationDate=$prCreationDate
echo prSourceRefName=$prSourceRefName
echo prTargetRefName=$prTargetRefName
echo prUrl=$prUrl
# Launch default browser with the pr url
devOpsPRViewUri="https://dev.azure.com/${MYVAR_ORGANIZATION}/_git/${MYVAR_PROJECT}/pullrequest/${pullRequestId}"
x-www-browser "$devOpsPRViewUri"
