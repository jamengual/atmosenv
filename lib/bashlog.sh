#!/usr/bin/env bash
# bashlog.sh - Logging framework for atmosenv
# Compatible with bash 3.x (macOS default) and bash 4+

# Configuration (can be overridden via environment)
: "${ATMOSENV_LOG_LEVEL:=INFO}"
: "${ATMOSENV_LOG_COLORS:=1}"

# Get numeric log level
_get_level_num() {
  case "${1}" in
    DEBUG) echo 0 ;;
    INFO)  echo 1 ;;
    WARN)  echo 2 ;;
    ERROR) echo 3 ;;
    *)     echo 1 ;;
  esac
}

# Get color for level
_get_color() {
  if [[ "${ATMOSENV_LOG_COLORS}" != "1" ]] || [[ ! -t 2 ]]; then
    echo ""
    return
  fi

  case "${1}" in
    DEBUG) echo "\033[0;36m" ;;  # Cyan
    INFO)  echo "\033[0;32m" ;;  # Green
    WARN)  echo "\033[0;33m" ;;  # Yellow
    ERROR) echo "\033[0;31m" ;;  # Red
    RESET) echo "\033[0m" ;;
    *)     echo "" ;;
  esac
}

# Log function
# Usage: log LEVEL "message"
log() {
  local level="${1:-INFO}"
  shift
  local message="$*"

  local current_level
  current_level="$(_get_level_num "${ATMOSENV_LOG_LEVEL}")"
  local msg_level
  msg_level="$(_get_level_num "${level}")"

  if [[ "${msg_level}" -ge "${current_level}" ]]; then
    local color
    color="$(_get_color "${level}")"
    local reset
    reset="$(_get_color RESET)"
    echo -e "${color}[${level}]${reset} ${message}" >&2
  fi
}

# Convenience functions
log_debug() { log DEBUG "$@"; }
log_info()  { log INFO "$@"; }
log_warn()  { log WARN "$@"; }
log_error() { log ERROR "$@"; }

# Fatal error - logs and exits
abort() {
  log_error "atmosenv: $*"
  exit 1
}

# Early death - for initialization errors
early_death() {
  local script="${0##*/}"
  log_error "${script}: $*"
  exit 1
}
