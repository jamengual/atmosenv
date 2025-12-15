#!/usr/bin/env bash
# atmosenv-version-file.sh - Version file detection and resolution
# Follows tfenv's hierarchical search pattern

# Find .atmos-version file by traversing up directory tree
find_local_version_file() {
  local root="${1:-${PWD}}"

  log_debug "Searching for .atmos-version starting from: ${root}"

  # Traverse up from current directory
  while [[ "${root}" != "" ]] && [[ "${root}" != "/" ]]; do
    if [[ -e "${root}/.atmos-version" ]]; then
      log_debug "Found version file: ${root}/.atmos-version"
      echo "${root}/.atmos-version"
      return 0
    fi
    log_debug "No .atmos-version in ${root}"
    root="${root%/*}"
  done

  # Check root directory
  if [[ -e "/.atmos-version" ]]; then
    log_debug "Found version file: /.atmos-version"
    echo "/.atmos-version"
    return 0
  fi

  return 1
}

# Get version file path with full search hierarchy
# Priority: local -> home -> config default
get_version_file() {
  local search_dir="${1:-${PWD}}"
  local version_file

  # 1. Search local directories (current and parents)
  version_file="$(find_local_version_file "${search_dir}")" && {
    echo "${version_file}"
    return 0
  }

  # 2. Check home directory
  if [[ -e "${HOME}/.atmos-version" ]]; then
    log_debug "Found version file: ${HOME}/.atmos-version"
    echo "${HOME}/.atmos-version"
    return 0
  fi

  # 3. Fall back to config directory default
  log_debug "Using default version file: ${ATMOSENV_CONFIG_DIR}/version"
  echo "${ATMOSENV_CONFIG_DIR}/version"
  return 0
}

# Read version from file
read_version_file() {
  local file="${1}"

  if [[ ! -f "${file}" ]]; then
    return 1
  fi

  # Read first non-empty, non-comment line
  local version
  while IFS= read -r line || [[ -n "${line}" ]]; do
    # Skip empty lines and comments
    [[ -z "${line}" ]] && continue
    [[ "${line}" =~ ^[[:space:]]*# ]] && continue

    # Trim whitespace
    version="$(echo "${line}" | tr -d '[:space:]')"
    if [[ -n "${version}" ]]; then
      echo "${version}"
      return 0
    fi
  done < "${file}"

  return 1
}
