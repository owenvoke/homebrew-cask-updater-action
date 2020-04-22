#!/usr/bin/env bash
_setup_git() {
    git_remote="https://${GITHUB_ACTOR}:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"

    git config --global user.name "${INPUT_COMMIT_USER_NAME}"
    git config --global user.email "${INPUT_COMMIT_USER_EMAIL}"

    git remote set-url --push origin "${git_remote}"
}

_setup_git
