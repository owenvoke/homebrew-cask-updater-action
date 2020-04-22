#!/usr/bin/env bash

set -e

export EXEC_DIRECTORY="/app"

source "${EXEC_DIRECTORY}/src/styles.sh"
source "${EXEC_DIRECTORY}/src/utils.sh"

source "${EXEC_DIRECTORY}/src/git-setup.sh"
source "${EXEC_DIRECTORY}/src/updater.sh"

update
