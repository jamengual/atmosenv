#!/usr/bin/env bash
# helpers.sh - Core utilities for atmosenv
# Follows tfenv patterns adapted for Atmos

set -uo pipefail

# Ensure ATMOSENV_ROOT is set
if [[ -z "${ATMOSENV_ROOT:-}" ]]; then
  early_death "ATMOSENV_ROOT is not set"
fi

# Source logging if not already loaded
if ! declare -f log >/dev/null 2>&1; then
  # shellcheck source=lib/bashlog.sh
  source "${ATMOSENV_ROOT}/lib/bashlog.sh"
fi

# Default configuration directory (XDG compliant)
: "${ATMOSENV_CONFIG_DIR:=${XDG_CONFIG_HOME:-${HOME}/.config}/atmosenv}"

# Default remote URL for Atmos releases
: "${ATMOSENV_REMOTE:=https://github.com/cloudposse/atmos/releases}"

# GitHub API endpoint
: "${ATMOSENV_GITHUB_API:=https://api.github.com/repos/cloudposse/atmos/releases}"

# Auto-install missing versions
: "${ATMOSENV_AUTO_INSTALL:=true}"

# Create config directory if it doesn't exist
mkdir -p "${ATMOSENV_CONFIG_DIR}/versions" 2>/dev/null || true

# Cross-platform readlink -f implementation
# macOS doesn't have readlink -f by default
readlink_f() {
  local target_file="${1}"
  local file_name

  while [[ "${target_file}" != "" ]]; do
    cd "$(dirname "${target_file}")" || return 1
    file_name="$(basename "${target_file}")"
    target_file="$(readlink "${file_name}" 2>/dev/null || true)"
  done

  echo "$(pwd -P)/${file_name}"
}

# Detect operating system
detect_os() {
  local os
  os="$(uname -s)"

  case "${os}" in
    Darwin)  echo "darwin" ;;
    Linux)   echo "linux" ;;
    FreeBSD) echo "freebsd" ;;
    MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
    *)
      log_error "Unsupported operating system: ${os}"
      return 1
      ;;
  esac
}

# Detect architecture
detect_arch() {
  local arch
  arch="$(uname -m)"

  case "${arch}" in
    x86_64|amd64)  echo "amd64" ;;
    arm64|aarch64) echo "arm64" ;;
    armv7l|armv6l) echo "arm" ;;
    i386|i686)     echo "386" ;;
    *)
      log_error "Unsupported architecture: ${arch}"
      return 1
      ;;
  esac
}

# Get binary extension for OS
get_binary_extension() {
  local os="${1}"
  if [[ "${os}" == "windows" ]]; then
    echo ".exe"
  else
    echo ""
  fi
}

# Construct download URL for a specific version
# Atmos releases use format:
#   URL path: /v{VERSION}/
#   Filename: atmos_{VERSION}_{OS}_{ARCH} (no 'v' prefix in filename)
construct_download_url() {
  local version="${1}"
  local os="${2:-$(detect_os)}"
  local arch="${3:-$(detect_arch)}"
  local ext
  ext="$(get_binary_extension "${os}")"

  # Clean version (remove 'v' prefix if present)
  local clean_ver="${version#v}"

  # URL path needs 'v' prefix, filename does NOT
  # Example: /v1.201.0/atmos_1.201.0_darwin_arm64
  echo "https://github.com/cloudposse/atmos/releases/download/v${clean_ver}/atmos_${clean_ver}_${os}_${arch}${ext}"
}

# Check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Download with curl or wget
curlw() {
  if command_exists curl; then
    curl -fsSL "$@"
  elif command_exists wget; then
    wget -qO- "$@"
  else
    abort "Neither curl nor wget found. Please install one of them."
  fi
}

# Download file with progress
download_file() {
  local url="${1}"
  local dest="${2}"

  log_info "Downloading ${url}"

  if command_exists curl; then
    curl -fL --progress-bar -o "${dest}" "${url}"
  elif command_exists wget; then
    wget --progress=bar:force -O "${dest}" "${url}"
  else
    abort "Neither curl nor wget found. Please install one of them."
  fi
}

# Verify SHA256 checksum
verify_checksum() {
  local file="${1}"
  local expected="${2}"
  local actual

  if command_exists shasum; then
    actual="$(shasum -a 256 "${file}" | cut -d ' ' -f 1)"
  elif command_exists sha256sum; then
    actual="$(sha256sum "${file}" | cut -d ' ' -f 1)"
  else
    log_warn "Neither shasum nor sha256sum found. Skipping checksum verification."
    return 0
  fi

  if [[ "${actual}" != "${expected}" ]]; then
    log_error "Checksum mismatch!"
    log_error "Expected: ${expected}"
    log_error "Actual:   ${actual}"
    return 1
  fi

  log_debug "Checksum verified: ${actual}"
  return 0
}

# Semver comparison: returns 0 if $1 >= $2
version_ge() {
  local v1="${1#v}"
  local v2="${2#v}"

  # Use sort -V if available (GNU coreutils)
  if echo | sort -V >/dev/null 2>&1; then
    [[ "$(printf '%s\n%s' "${v1}" "${v2}" | sort -V | head -n1)" == "${v2}" ]]
  else
    # Fallback: simple string comparison (not perfect but works for most cases)
    [[ "${v1}" > "${v2}" ]] || [[ "${v1}" == "${v2}" ]]
  fi
}

# Clean version string (remove 'v' prefix if present)
clean_version() {
  local version="${1}"
  echo "${version#v}"
}

# Add 'v' prefix if not present
prefix_version() {
  local version="${1}"
  if [[ "${version}" != v* ]]; then
    echo "v${version}"
  else
    echo "${version}"
  fi
}
