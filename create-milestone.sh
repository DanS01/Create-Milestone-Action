#!/bin/bash

# Initialize constants
LOWER_BOUND=3
UPPER_BOUND=28
NEW_TARGET=14

# Initialize variables
MILESTONE_LINKED=''

# --------------------------------------------------------------------------------

function create_milestone_curl_cmd()
{
    # First argument should be set as the milestone title
    TITLE=${1}

    # Second argument shold be set as the milestone due on date
    DUE_ON=${2}

    # Need to authenticate to obtain write access for the REST API POST event
    CREATED_MILESTONE=$( curl --silent -X POST -H "Authorization: token ${SECRETS_TOKEN}" "Accept: application/vnd.github.v3+json" https://api.github.com/repos/"${REPOSITORY}"/milestones -d '{"title":'\"${TITLE}\"',"due_on":'\"${DUE_ON}\"',"state":"open"}' )
}

function link_milestone_curl_cmd()
{
    # First argument should be set as the milestone number
    MILESTONE_NUMBER=${1}

    # The issue or pull request number used to link the milestone to
    ISSUE_NUMBER="${PULL_REQUEST_NUMBER}"

    # Need to authenticate to obtain write access for the REST API PATCH event
    LINKED_PULL_REQUEST=$( curl --silent -X PATCH -H "Authorization: token ${SECRETS_TOKEN}" "Accept: application/vnd.github.v3+json" https://api.github.com/repos/"${REPOSITORY}"/issues/"${ISSUE_NUMBER}" -d '{"milestone":'\"${MILESTONE_NUMBER}\"'}' )
}

# --------------------------------------------------------------------------------

# Display information from Github
echo Github Repository: "${REPOSITORY}"
echo Pull Request Name: "${PULL_REQUEST_TITLE}"
echo Pull Request Number: "${PULL_REQUEST_NUMBER}"
echo Pull Request Milestone: "${PULL_REQUEST_MILESTONE}"

# Check whether a milestone is linked to the pull request
# If there is no milestone linked to the pull request then a value of "null" is returned from the API
if [[ $PULL_REQUEST_MILESTONE != "null" ]];
then
    MILESTONE_LINKED='true'
else
    MILESTONE_LINKED='false'
fi

echo Milestone Linked: "$MILESTONE_LINKED"

if [[ $MILESTONE_LINKED == "true" ]];
then
    echo A milestone is already linked!
    echo New milestone cannot be created or linked
else
    echo There is no milestone linked to the pull request

    CURRENT_DATETIME=$( echo $(date +'%Y-%m-%dT%H:%M:%SZ') )
    echo Current DateTime: "$CURRENT_DATETIME"
    LOWER_BOUND_DATETIME_REF=$( echo $(date +'%Y-%m-%dT%H:%M:%SZ' --date "$CURRENT_DATETIME +$LOWER_BOUND days") )
    echo Lower Bound DateTime Ref: "$LOWER_BOUND_DATETIME_REF"
    UPPER_BOUND_DATETIME_REF=$( echo $(date +'%Y-%m-%dT%H:%M:%SZ' --date "$CURRENT_DATETIME +$UPPER_BOUND days") )
    echo Upper Bound DateTime Ref: "$UPPER_BOUND_DATETIME_REF"
    NEW_TARGET_DATETIME_REF=$( echo $(date +'%Y-%m-%dT%H:%M:%SZ' --date "$CURRENT_DATETIME +$NEW_TARGET days") )
    echo New Target DateTime Ref: "$NEW_TARGET_DATETIME_REF"

    # Get all OPEN milestones with a due date newer than the current date and time
    MILESTONE_DATA=$( curl --silent -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/"${REPOSITORY}"/milestones?state=open\&sort=due_on\&direction=asc )
    FUTURE_MILESTONES=$( echo $MILESTONE_DATA | jq --raw-output '.[] | select((.due_on >= '\"$LOWER_BOUND_DATETIME_REF\"') and (.due_on <= '\"$UPPER_BOUND_DATETIME_REF\"'))' )

    echo Future Milestones:
    echo "$FUTURE_MILESTONES"

    if [[ $FUTURE_MILESTONES != '' ]];
    then
        echo Future Milestone List is NOT EMPTY

        MILESTONE=$( echo $FUTURE_MILESTONES | jq --raw-output '.[0]' )

        echo Milestone:
        echo "$MILESTONE"

        echo Milestone Number:
        MILESTONE_NUMBER=$( echo $MILESTONE | jq --raw-output '.number' )
        echo "$MILESTONE_NUMBER"

        link_milestone_curl_cmd $MILESTONE_NUMBER
        echo Linked Pull Request:
        echo "$LINKED_PULL_REQUEST"
    else
        echo Future Milestone List is EMPTY

        create_milestone_curl_cmd $NEW_TARGET_DATETIME_REF $NEW_TARGET_DATETIME_REF

        echo Created Milestone:
        echo "$CREATED_MILESTONE"

        echo Milestone Number:
        MILESTONE_NUMBER=$( echo $CREATED_MILESTONE | jq --raw-output '.number' )
        echo "$MILESTONE_NUMBER"
        link_milestone_curl_cmd $MILESTONE_NUMBER

        echo Linked Pull Request:
        echo "$LINKED_PULL_REQUEST"
    fi
fi
