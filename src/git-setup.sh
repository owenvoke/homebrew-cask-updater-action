#!/usr/bin/env bash

_setup_git() {
    git_remote="https://${GITHUB_ACTOR}:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"

    git config --global user.name "${INPUT_COMMIT_USER_NAME:-Homebrew Updater Bot}"
    git config --global user.email "${INPUT_COMMIT_USER_EMAIL:-action@github.com}"

    git remote set-url --push origin "${git_remote}"

    echo "::debug::Git name: $(git config user.name)"
    echo "::debug::Git email: $(git config user.email)"
}

_setup_git
