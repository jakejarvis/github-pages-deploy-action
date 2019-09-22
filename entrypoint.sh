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
git config --global user.email "${PAGES_COMMIT_EMAIL}"
git config --global user.name "${PAGES_COMMIT_NAME}"

## Initializes the repository path using the access token.
REPOSITORY_PATH="https://${PAGES_TOKEN}@github.com/${GITHUB_ACTOR}/${PAGES_TARGET_REPO}.git"

# Checks out the base branch to begin the deploy process.
git checkout "${PAGES_SOURCE_BRANCH:-master}"


# --- TODO: Only necessary if the target repo isn't the current one ---

mkdir gh-pages-target

# Copy source directory into target repo
cp -r "$PAGES_SOURCE_FOLDER"/* gh-pages-target

cd gh-pages-target

git init
git remote add target "$REPOSITORY_PATH"
git checkout -B "$PAGES_TARGET_BRANCH"

## --- END TODO ---

if [ "$PAGES_CNAME" ]; then
  echo "Generating a CNAME file..."
  echo "$PAGES_CNAME" > CNAME
fi

git add .

echo "Deploying to target branch..."

git commit -m "GitHub Pages deploy from $GITHUB_REPOSITORY@$GITHUB_SHA" --quiet
git push target "$PAGES_TARGET_BRANCH" --force

echo "Deployment succesful!"
