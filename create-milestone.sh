#!/bin/bash

# Initialize constants
LOWER_BOUND=3

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
LOWER_BOUND_DATETIME=$( echo $(date -d "+$LOWER_BOUND days") )
echo Lower Bound DateTime: "$LOWER_BOUND_DATETIME"

# Get all OPEN milestones with a due date newer than the current date and time
MILESTONE_DATA=$( curl --silent -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/"${REPOSITORY}"/milestones?state=open\&sort=due_on\&direction=asc )
FUTURE_MILESTONES=$( echo $MILESTONE_DATA | jq --raw-output '.[] | select(.due_on >= '\"$CURRENT_DATETIME\"')' )

echo Future Milestones:
echo "$FUTURE_MILESTONES"



# STEPS
# Check for linked milestone
# Retrieve open milestones that are in the future (ie. due on datetime >= current datetime)
# Filter results where due on date is >= current datetime + lower bound days
# Take the milestone number of the first milestone in the list
# If no future milestone exists then create a new one
# Take the milestone number of this newly created milestone
# Assign milestone to pull request

#NEW_MILESTONE=$( curl --silent -X POST -H "Authorization: token ${SECRETS_TOKEN}" "Accept: application/vnd.github.v3+json" https://api.github.com/repos/"${REPOSITORY}"/milestones -d '{"title":"title","due_on":""}' )
#UPDATE_PULL_REQUEST=$( curl -X PATCH -H "Authorization: token ${SECRETS_TOKEN}" "Accept: application/vnd.github.v3+json" https://api.github.com/repos/"${REPOSITORY}"/issues/"${PULL_REQUEST_NUMBER}" -d '{"milestone":"1"}' )
