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

# Installs Git.
apt-get update && \
apt-get install -y git && \

# Directs the action to the the Github workspace.
cd "$GITHUB_WORKSPACE" && \

# Configures Git.
git init && \
git config --global user.email "${PAGES_COMMIT_EMAIL}" && \
git config --global user.name "${PAGES_COMMIT_NAME}" && \

## Initializes the repository path using the access token.
REPOSITORY_PATH="https://${PAGES_TOKEN}@github.com/${GITHUB_ACTOR}/${PAGES_TARGET_REPO}.git" && \

# Checks to see if the remote exists prior to deploying.
# If the branch doesn't exist it gets created here as an orphan.
if [ "$(git ls-remote --heads "$REPOSITORY_PATH" "$PAGES_TARGET_BRANCH" | wc -l)" -eq 0 ];
then
  echo "Creating remote branch ${PAGES_TARGET_BRANCH} as it doesn't exist..."
  git checkout "${PAGES_SOURCE_BRANCH:-master}" && \
  git checkout --orphan "$PAGES_TARGET_BRANCH" && \
  git rm -rf . && \
  touch README.md && \
  git add README.md && \
  git commit -m "Initial ${PAGES_TARGET_BRANCH} commit" && \
  git push "$REPOSITORY_PATH" "$PAGES_TARGET_BRANCH"
fi

# Checks out the base branch to begin the deploy process.
git checkout "${PAGES_SOURCE_BRANCH:-master}" && \

if [ "$PAGES_CNAME" ]; then
  echo "Generating a CNAME file in in the $PAGES_SOURCE_FOLDER directory..."
  echo "$PAGES_CNAME" > "$FOLDER"/CNAME
fi

# Commits the data to Github.
echo "Deploying to GitHub..." && \
git add -f "$PAGES_SOURCE_FOLDER" && \

git commit -m "Deploying to ${PAGES_TARGET_BRANCH} - $(date +"%T")" --quiet && \
git push "$REPOSITORY_PATH" $(git subtree split --prefix "$FOLDER" "${PAGES_SOURCE_BRANCH:-master}"):"$PAGES_TARGET_BRANCH" --force && \
echo "Deployment succesful!"
