#!/usr/bin/env bash

function appcast_url {
  local cask_file="${1}"

  brew cask _stanza appcast "${cask_file}"
}

function has_appcast {
  local cask_file="${1}"

  [[ -n "$(appcast_url "${cask_file}" 2>/dev/null)" ]]
}

function cask_version {
  local cask_file="${1}"

  brew cask _stanza version "${cask_file}"
}

function modify_stanza {
  local stanza_to_modify new_stanza_value cask_file stanza_match_regex last_stanza_match stanza_start ending_comma

  stanza_to_modify="${1}"
  new_stanza_value="${2}"
  cask_file="${3}"

  stanza_match_regex="^\s*${stanza_to_modify} "
  last_stanza_match="$(grep "${stanza_match_regex}" "${cask_file}" | tail -1)"
  stanza_start="$(/usr/bin/perl -pe "s/(${stanza_match_regex}).*/\1/" <<< "${last_stanza_match}")"
  if grep --quiet ',$' <<< "${last_stanza_match}"; then
    ending_comma=','
  fi

  /usr/bin/perl -0777 -i -e'
    $last_stanza_match = shift(@ARGV);
    $stanza_start = shift(@ARGV);
    $new_stanza_value = shift(@ARGV);
    $ending_comma = shift(@ARGV);
    print <> =~ s|\Q$last_stanza_match\E|$stanza_start$new_stanza_value$ending_comma|r;
  ' "${last_stanza_match}" "${stanza_start}" "${new_stanza_value}" "${ending_comma}" "${cask_file}"
}

function sha_change {
  local cask_sha_deliberatedly_unchecked downloaded_file package_sha cask_file

  cask_file="${1}"

  echo "::debug::Checking if deliberately disabled"
  cask_sha_deliberatedly_unchecked="$(grep 'sha256 :no_check # required as upstream package is updated in-place' "${cask_file}")"
  [[ -n "${cask_sha_deliberatedly_unchecked}" ]] && return # Abort function if cask deliberately uses :no_check with a version

  # Set sha256 as :no_check temporarily, to prevent mismatch errors when fetching
  echo "::debug::Setting ':no_check' temporarily"
  modify_stanza 'sha256' ':no_check' "${cask_file}"

  echo "::debug::Attempting to fetch cask"
  if ! brew cask fetch --force "${cask_file}"; then
    clean
    abort "There was an error fetching ${cask_file}. Please check your connection and try again."
  fi

  echo "::debug::Generating sha256 hash for Cask"
  downloaded_file=$(brew cask fetch "${cask_file}" 2>/dev/null | tail -1 | sed 's/==> Success! Downloaded to -> //')
  package_sha=$(shasum --algorithm 256 "${downloaded_file}" | awk '{ print $1 }')

  modify_stanza 'sha256' "'${package_sha}'" "${cask_file}"
}
