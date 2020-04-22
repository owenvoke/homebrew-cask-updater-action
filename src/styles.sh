function clean {
  local current_branch

  lock 'remove'

  [[ "$(dirname "$(dirname "${PWD}")")" == "${caskroom_taps_dir}" ]] || return # Do not try to clean if not in a tap dir (e.g. if script was manually aborted too fast)

  current_branch="$(git rev-parse --abbrev-ref HEAD)"

  git reset HEAD --hard --quiet
  git checkout master --quiet
  git branch -D "${current_branch}" --quiet
  [[ -f "${submission_error_log}" ]] && rm "${submission_error_log}"
  unset given_cask_version given_cask_url cask_updated
}

function skip {
  clean
  echo -e "${1}"
}

function abort {
  clean
  failure_message "\n${1}\n"
  exit 1
}

function divide {
  command -v 'hr' &>/dev/null && hr - || echo '--------------------'
}
