#!/usr/bin/env bash
# test_common.sh - Common test utilities for atmosenv

set -uo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Resolve ATMOSENV_ROOT for tests
resolve_test_root() {
  local source="${BASH_SOURCE[0]}"
  local dir

  while [[ -L "${source}" ]]; do
    dir="$(cd -P "$(dirname "${source}")" && pwd)"
    source="$(readlink "${source}")"
    [[ "${source}" != /* ]] && source="${dir}/${source}"
  done

  dir="$(cd -P "$(dirname "${source}")" && pwd)"
  echo "$(cd "${dir}/.." && pwd)"
}

export ATMOSENV_ROOT="${ATMOSENV_ROOT:-$(resolve_test_root)}"
export PATH="${ATMOSENV_ROOT}/bin:${ATMOSENV_ROOT}/libexec:${PATH}"

# Create temporary test directory
setup_test_env() {
  export TEST_DIR
  TEST_DIR="$(mktemp -d)"
  export ATMOSENV_CONFIG_DIR="${TEST_DIR}/.config/atmosenv"
  export HOME="${TEST_DIR}"
  mkdir -p "${ATMOSENV_CONFIG_DIR}/versions"

  # Set log level to reduce noise during tests
  export ATMOSENV_LOG_LEVEL="ERROR"
}

# Clean up test directory
cleanup_test_env() {
  if [[ -n "${TEST_DIR:-}" ]] && [[ -d "${TEST_DIR}" ]]; then
    rm -rf "${TEST_DIR}"
  fi
}

# Run a test and track results
run_test() {
  local name="${1}"
  local cmd="${2}"

  ((TESTS_RUN++))

  echo -n "  Testing: ${name}... "

  local output
  local exit_code

  output="$(eval "${cmd}" 2>&1)" && exit_code=0 || exit_code=$?

  if [[ ${exit_code} -eq 0 ]]; then
    echo -e "${GREEN}PASS${NC}"
    ((TESTS_PASSED++))
    return 0
  else
    echo -e "${RED}FAIL${NC}"
    echo "    Output: ${output}"
    ((TESTS_FAILED++))
    return 1
  fi
}

# Assert that output contains expected string
assert_contains() {
  local output="${1}"
  local expected="${2}"

  if [[ "${output}" == *"${expected}"* ]]; then
    return 0
  else
    echo "Expected to contain: '${expected}'"
    echo "Actual output: '${output}'"
    return 1
  fi
}

# Assert that output matches regex
assert_match() {
  local output="${1}"
  local pattern="${2}"

  if [[ "${output}" =~ ${pattern} ]]; then
    return 0
  else
    echo "Expected to match: '${pattern}'"
    echo "Actual output: '${output}'"
    return 1
  fi
}

# Assert that command exits with expected code
assert_exit_code() {
  local expected="${1}"
  shift
  local actual

  "$@" >/dev/null 2>&1 && actual=0 || actual=$?

  if [[ ${actual} -eq ${expected} ]]; then
    return 0
  else
    echo "Expected exit code: ${expected}"
    echo "Actual exit code: ${actual}"
    return 1
  fi
}

# Assert file exists
assert_file_exists() {
  local file="${1}"

  if [[ -f "${file}" ]]; then
    return 0
  else
    echo "File does not exist: ${file}"
    return 1
  fi
}

# Assert directory exists
assert_dir_exists() {
  local dir="${1}"

  if [[ -d "${dir}" ]]; then
    return 0
  else
    echo "Directory does not exist: ${dir}"
    return 1
  fi
}

# Print test summary
print_summary() {
  echo ""
  echo "========================================"
  echo "Test Summary"
  echo "========================================"
  echo "  Total:  ${TESTS_RUN}"
  echo -e "  Passed: ${GREEN}${TESTS_PASSED}${NC}"
  echo -e "  Failed: ${RED}${TESTS_FAILED}${NC}"
  echo "========================================"

  if [[ ${TESTS_FAILED} -gt 0 ]]; then
    return 1
  fi
  return 0
}

# Early death for fatal errors
early_death() {
  echo -e "${RED}FATAL:${NC} $*" >&2
  exit 1
}
