#!/bin/bash

# Initialize variables
MILESTONE_LINKED=''

# Display information from Github
echo Github Repository: "${REPOSITORY}"
echo Pull Request Name: "${PULL_REQUEST_TITLE}"
echo Pull Request Number: "${PULL_REQUEST_NUMBER}"
echo Pull Request Milestone: "${PULL_REQUEST_MILESTONE}"

# Check whether a milestone is linked to the pull request
# If there is no milestone linked to the pull request then a value of "null" is returned from the API
if [[ $PULL_REQUEST_MILESTONE != "null" ]];
then
    echo A milestone is already linked
    MILESTONE_LINKED='true'
else
    echo There is no milestone linked to the pull request
    MILESTONE_LINKED='false'
fi

echo Milestone Linked: "$MILESTONE_LINKED"

CURRENT_DATETIME=$( echo $(date +'%Y-%m-%dT%H:%M:%SZ') )
echo Current DateTime: "$CURRENT_DATETIME"

# Get all OPEN milestones with a due date newer than the current date and time
MILESTONE_DATA=$( curl --silent -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/"${REPOSITORY}"/milestones?state=open\&sort=due_on\&direction=desc )
FUTURE_MILESTONES=$( echo $MILESTONE_DATA | jq --raw-output '.[] | select(.due_on >= '\"$CURRENT_DATETIME\"')' )

echo Future Milestones:
echo "$FUTURE_MILESTONES"
