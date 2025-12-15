#!/usr/bin/env bash
# bashlog.sh - Logging framework for atmosenv
# Inspired by tfenv's logging approach

# Logging levels
declare -A LOG_LEVELS
LOG_LEVELS=([DEBUG]=0 [INFO]=1 [WARN]=2 [ERROR]=3)

# Configuration (can be overridden via environment)
: "${ATMOSENV_LOG_LEVEL:=INFO}"
: "${ATMOSENV_LOG_COLORS:=1}"

# Color definitions
declare -A COLORS
if [[ "${ATMOSENV_LOG_COLORS}" == "1" ]] && [[ -t 2 ]]; then
  COLORS=(
    [DEBUG]="\033[0;36m"    # Cyan
    [INFO]="\033[0;32m"     # Green
    [WARN]="\033[0;33m"     # Yellow
    [ERROR]="\033[0;31m"    # Red
    [RESET]="\033[0m"
  )
else
  COLORS=([DEBUG]="" [INFO]="" [WARN]="" [ERROR]="" [RESET]="")
fi

# Log function
# Usage: log LEVEL "message"
log() {
  local level="${1:-INFO}"
  shift
  local message="$*"

  local current_level="${LOG_LEVELS[${ATMOSENV_LOG_LEVEL}]:-1}"
  local msg_level="${LOG_LEVELS[${level}]:-1}"

  if [[ "${msg_level}" -ge "${current_level}" ]]; then
    local color="${COLORS[${level}]}"
    local reset="${COLORS[RESET]}"
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
