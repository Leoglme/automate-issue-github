#!/bin/bash
#Install github cli instruction if not exit on your machine
command -v gh >/dev/null 2>&1 || {
  echo >&2 "please install github cli and run command gh auth login: https://cli.github.com/manual/installation"
  exit 1
}

# Global variable

# Retrieving the current date
date=$(date +"%d/%m/%Y %T")

# Get Your github Username
github_name=$(gh api user -q .name)

# Help command

# Fonction for display help
Help() {
  echo "#####################################################################################################"
  echo "#"
  echo "#                                    IZIGIT.SH"
  echo "#"
  echo "# This script allows izidor developers to automate and manage git workflow easily."
  echo "#"
  echo "#####################################################################################################"
  echo ""
  echo
  echo "Syntax: izigit [-s|c|i|p|h]"
  echo "options:"
  echo ""
  echo "create [ticket_number] Create, fetch and checkout branch for ticket ( example: izigit create 654 )"
  echo "reset [branch_name] Reset of a branch, so that it is strictly identical to the preprod branch ( example: izigit reset test )"
  echo "test Merge issue branch into test branch ( example: izigit test )"
  echo "pr Creating a pull request from the github issue branch to the preprod branch ( example: izigit pr )"
  echo "h     Print this Help."
}

# Creating a pull request from the github issue branch to the preprod branch //ticket number
PrIssueToPreprod() {
  # Get the current git branch
  current_branch=$(git rev-parse --abbrev-ref HEAD)
  # Create a pull request from the issue branch to the target branch (preprod)
  gh pr create --base preprod --head $current_branch
}

# Fonction for merge issue branch into test branch //ticket number
MergeIssueInTest() {
  #  # Get branch name with ticket number
  #  branch_name=$(git branch -r | grep $2 | sed 's/origin\///')
  #
  #  if [ $branch_name ]
  #  then
  #    echo "No git branch found for ticket 703"
  #    exit 0
  #  fi

  #  git checkout test
  #  git pull origin test
  #  git merge $current_branch

  #  # Configurer les variables d'environnement
  #  REPO=sportoutdoor
  #  COLUMN_ID_FROM=COLUMN_ID_FROM
  #  COLUMN_ID_TO=COLUMN_ID_TO
  #  CARD_ID=738
  #  GITHUB_TOKEN=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
  #
  #  # Déplacer la carte vers une autre colonne
  #  curl -X POST \
  #    -H "Accept: application/vnd.github+json" \
  #    -H "Authorization: Bearer $GITHUB_TOKEN" \
  #    -H "Content-Type: application/json" \
  #    -d "{\"column_id\": $COLUMN_ID_TO}" \
  #    https://api.github.com/projects/columns/$COLUMN_ID_FROM/cards/$CARD_ID/moves

  gh api graphql -f query='
    query{
      organization(login: "sportoutdoor"){
        projectV2(number: 1) {
          id
          title
        }
      }
    }'
  gh api graphql -f query='
    query{
        node(id: "PVT_kwDOBrk6n84AFqb8") {
             id,
             columns
             }
      }'

}

# Fonction for reset test branch, so that it is strictly identical to the preprod branch
ResetTestToPreprod() {
    test_branch="test"
    reference_branch="preprod"

    # Fetch and checkout the reference branch (preprod)
    git fetch
    git checkout $reference_branch
    git pull $reference_branch

    # Delete the local working branch
    git branch -D $test_branch

    # Create a new branch from the reference branch (preprod)
    git checkout -b $test_branch

    # Push the new branch to the remote repository
    git push -u origin $test_branch --force

    comment="$date - $test_branch reset to $reference_branch - $github_name"
    echo $comment
}

# Fonction for create branch for ticket and fetch, checkout this branch
# Arguments: $2 = ticket number
CreateBranch() {
  if [ $2 ]; then
    # Get the title of the issue using the gh command
    issue_title=$(gh issue view $2 --json title --jq .title)
    # remove special characters from issue_title
    issue_title=${issue_title//[^a-zA-Z0-9 ]/}
    # replace multiple spaces with single space and trim title
    issue_title="$(echo -e "${issue_title}" | tr -s ' ' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
    # Replace spaces with dashes and concatenate the issue number to the branch name to avoid filename issues
    branch_name=$2-${issue_title// /-}
    # Create the issue branch and link the branch to the GitHub issue
    gh issue develop $2 --name $branch_name --base $branch_name

    git fetch origin
    # Checkout to the created branch
    git checkout $branch_name

    comment="$date - creation of the $branch_name branch and branch link to issue $2 - $github_name"

    # Add comment to issue
    gh issue comment $2 -b "$comment"

    echo $comment
    exit 0
  fi
  echo "Please specify allows ticket number, izigit create [ticket_number] ( example: izigit create 654 )"
}

# Enable options arguments
while getopts "h" option; do
  case $option in
  h)
    Help
    exit
    ;;
  ?)
    printf "Command not found, please use command -h for display help"
    exit 1
    ;;
  esac
done

# Display message if no argument or option supplied
if [ $OPTIND -eq 1 ] && [ $# -eq 0 ]; then echo "An argument is required, please use command -h for display help"; fi

# Enable options
if [ "$1" == "create" ]; then CreateBranch $1 $2; fi
if [ "$1" == "reset" ]; then ResetTestToPreprod; fi
if [ "$1" == "test" ]; then MergeIssueInTest $1 $2; fi
