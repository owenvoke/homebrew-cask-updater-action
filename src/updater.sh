#!/usr/bin/env bash

function update() {
  cask_directory="${GITHUB_WORKSPACE}/Casks"
  cd "${cask_directory}"

  for cask in *.rb; do
    cask_name="${cask%.rb}"
    cask_file="${cask_directory}/${cask_name}.rb"

    if has_appcast "${cask_file}"; then
      echo "Checking Cask '${cask_name}' for new versions"

      cask_current_version="$(cask_version "${cask_file}")"
      cask_appcast_url="$(appcast_url "${cask_file}")"

      # Skip if not an Electron app
      if ! [[ "${cask_appcast_url}" =~ \/latest-mac.yml$ ]]; then
        continue
      fi

      cask_latest_version="$(curl --silent "${cask_appcast_url}" | yq r - version)"

      if ! [[ "${cask_latest_version}" == "${cask_current_version}" ]]; then
        echo "::debug:: - Cask '${cask_name}' is out of date"

        echo "::debug:: - Updating '${cask_name}' from ${cask_current_version} to ${cask_latest_version}"
        modify_stanza 'version' "${cask_latest_version}" "${cask_file}"

        echo "::debug:: - Update sha256 value for the cask"
        modify_sha_hash "${cask_file}"

        echo "::debug::$(git diff)"
        commit_message="Update ${cask_name} from ${cask_current_version} to ${cask_latest_version}"
        git commit "${cask_file}" --message "${commit_message}" --quiet

        echo "Updated '${cask_name}' from ${cask_current_version} to ${cask_latest_version}"
      fi
    fi
  done

  git push origin
}
