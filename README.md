# GitHub Pages Deploy Action :rocket: 

[![Actions Status](https://github.com/JamesIves/github-pages-deploy-action/workflows/integration/badge.svg)](https://github.com/JamesIves/github-pages-deploy-action/actions) [![View Action](https://img.shields.io/badge/view-action-blue.svg)](https://github.com/marketplace/actions/deploy-to-github-pages) [![Issues](https://img.shields.io/github/issues/JamesIves/github-pages-deploy-action.svg)](https://github.com/JamesIves/github-pages-deploy-action/issues)

This [GitHub action](https://github.com/features/actions) will handle the building and deploying process of your project to [GitHub Pages](https://pages.github.com/). It can be configured to upload your production ready code into any branch you'd like, including `gh-pages` and `docs`. This action is built on [Node](https://nodejs.org/en/), which means that you can call any optional build scripts your project requires prior to deploying.

❗️**You can find instructions for using version 1 of the GitHub Actions workflow format [here](https://github.com/JamesIves/github-pages-deploy-action/tree/1.1.3).**

## Getting Started :airplane:
You can include the action in your workflow to trigger on any event that [GitHub actions supports](https://help.github.com/en/articles/events-that-trigger-workflows). If the remote branch that you wish to deploy to doesn't already exist the action will create it for you. Your workflow will also need to include the `actions/checkout` step before this workflow runs in order for the deployment to work. 

You can view an example of this below.

```yml
name: Build and Deploy
on: [push]
jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout
      uses: actions/checkout@master

    - name: Build and Deploy
      uses: JamesIves/github-pages-deploy-action@master
      env:
        PAGES_TOKEN: ${{ secrets.ACCESS_TOKEN }}
        PAGES_SOURCE_BRANCH: master # The branch the action should deploy from.
        PAGES_TARGET_BRANCH: gh-pages # The branch the action should deploy to.
        PAGES_SOURCE_FOLDER: build # The folder the action should deploy.
```

If you'd like to make it so the workflow only triggers on push events to specific branches then you can modify the `on` section. You'll still need to specify a `PAGES_SOURCE_BRANCH` if you're deploying from a branch other than `master`.

```yml
on:
  push:	
    branches:	
      - master
```

## Configuration 📁

The `env` portion of the workflow **must** be configured before the action will work. You can add these in the `env` section found in the examples above. Any `secrets` must be referenced using the bracket syntax and stored in the GitHub repositories `Settings/Secrets` menu. You can learn more about setting environment variables with GitHub actions [here](https://help.github.com/en/articles/workflow-syntax-for-github-actions#jobsjob_idstepsenv).

Below you'll find a description of what each option does.

| Key  | Value Information | Type | Required |
| ------------- | ------------- | ------------- | ------------- |
| `PAGES_TOKEN`  | In order for GitHub to trigger the rebuild of your page you must provide the action with a GitHub personal access token with read/write permissions. You can [learn more about how to generate one here](https://help.github.com/en/articles/creating-a-personal-access-token-for-the-command-line). This **should be stored as a secret.**  | `secrets` | **Yes** |
| `PAGES_SOURCE_BRANCH`  | The base branch of your repository which you'd like to checkout prior to deploying. This defaults to `master`.  | `env` | **No** |
| `PAGES_SOURCE_FOLDER`  | The folder in your repository that you want to deploy. If your build script compiles into a directory named `build` you'd put it here. **Folder paths cannot have a leading `/` or `./`**. | `env` | **Yes** |
| `PAGES_TARGET_BRANCH`  | This is the branch you wish to deploy to, for example `gh-pages` or `docs`.  | `env` | **Yes** |
| `PAGES_TARGET_REPO`  | This is the repository you want to deploy to if different than the one you're running this action on. For example, `jakejarvis.github.io`.  | `env` | **No** |
| `PAGES_CNAME`  | If you're using a [custom domain](https://help.github.com/en/articles/using-a-custom-domain-with-github-pages), you will need to add the domain name to the `CNAME` environment variable. If you don't do this GitHub will wipe out your domain configuration after each deploy. This value will look something like this: `jives.dev`.  | `env` | **No** |
| `PAGES_COMMIT_EMAIL`  | Used to sign the commit, this should be your email. If not provided it will default to your username. | `env` | **No** |
| `PAGES_COMMIT_NAME`  | Used to sign the commit, this should be your name. If not provided it will default to `username@users.noreply.github.com`  | `env` | **No** |

With the action correctly configured you should see the workflow trigger the deployment under the configured conditions.

![Example](screenshot.png)
