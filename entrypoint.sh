#!/bin/sh -l

set -e

if [ -z "$PAGES_TOKEN" ]
then
  echo "You must provide the action with a GitHub Personal Access Token secret in order to deploy."
  exit 1
fi

if [ -z "$PAGES_TARGET_BRANCH" ]
then
  echo "You must provide the action with a branch name it should deploy to, for example gh-pages or docs."
  exit 1
fi

if [ -z "$PAGES_TARGET_REPO" ]
then
  PAGES_TARGET_REPO="${GITHUB_REPOSITORY}"
fi

if [ -z "$PAGES_SOURCE_FOLDER" ]
then
  echo "You must provide the action with the folder name in the repository where your compiled page lives."
  exit 1
fi

case "$PAGES_SOURCE_FOLDER" in /*|./*)
  echo "The deployment folder cannot be prefixed with '/' or './'. Instead reference the folder name directly."
  exit 1
esac

if [ -z "$PAGES_COMMIT_EMAIL" ]
then
  PAGES_COMMIT_EMAIL="${GITHUB_ACTOR}@users.noreply.github.com"
fi

if [ -z "$PAGES_COMMIT_NAME" ]
then
  PAGES_COMMIT_NAME="${GITHUB_ACTOR}"
fi

# Directs the action to the the Github workspace.
cd "$GITHUB_WORKSPACE"

# Configures Git.
git init
git config --global user.email "${PAGES_COMMIT_EMAIL}"
git config --global user.name "${PAGES_COMMIT_NAME}"

## Initializes the repository path using the access token.
REPOSITORY_PATH="https://${PAGES_TOKEN}@github.com/${GITHUB_ACTOR}/${PAGES_TARGET_REPO}.git"

# Checks out the base branch to begin the deploy process.
git checkout "${PAGES_SOURCE_BRANCH:-master}"

if [ "$PAGES_CNAME" ]; then
  echo "Generating a CNAME file in in the $PAGES_SOURCE_FOLDER directory..."
  echo "$PAGES_CNAME" > "$FOLDER"/CNAME
fi

# Commits the data to Github.
echo "Deploying to GitHub..."
git add -f "$PAGES_SOURCE_FOLDER"

git commit -m "Pages deploy from ${GITHUB_ACTOR}/${GITHUB_REPOSITORY}:${PAGES_SOURCE_BRANCH}" --quiet
git push "$REPOSITORY_PATH" "$PAGES_TARGET_BRANCH" --force

echo "Deployment succesful!"
