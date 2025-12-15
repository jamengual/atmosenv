#!/usr/bin/env bash
# run.sh - Run all atmosenv tests

set -uo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
echo "╔══════════════════════════════════════╗"
echo "║       atmosenv Test Suite            ║"
echo "╚══════════════════════════════════════╝"
echo -e "${NC}"

# Track overall results
TOTAL_SUITES=0
PASSED_SUITES=0
FAILED_SUITES=0

# Run a test suite
run_suite() {
  local test_file="${1}"
  local name
  name="$(basename "${test_file}" .sh)"

  ((TOTAL_SUITES++))

  echo ""
  echo -e "${BLUE}Running: ${name}${NC}"
  echo "----------------------------------------"

  if bash "${test_file}"; then
    ((PASSED_SUITES++))
    return 0
  else
    ((FAILED_SUITES++))
    return 1
  fi
}

# Parse arguments
SPECIFIC_TEST=""
while [[ $# -gt 0 ]]; do
  case "${1}" in
    -h|--help)
      echo "Usage: ${0} [OPTIONS] [TEST_FILE]"
      echo ""
      echo "Options:"
      echo "  -h, --help     Show this help message"
      echo "  -i, --install  Enable installation tests (downloads binaries)"
      echo ""
      echo "Examples:"
      echo "  ${0}                    Run all tests"
      echo "  ${0} test_basic.sh      Run specific test file"
      echo "  ${0} -i                 Run all tests including installation"
      exit 0
      ;;
    -i|--install)
      export ATMOSENV_TEST_INSTALL=true
      ;;
    *)
      SPECIFIC_TEST="${1}"
      ;;
  esac
  shift
done

# Find test files
if [[ -n "${SPECIFIC_TEST}" ]]; then
  # Run specific test
  test_file="${SCRIPT_DIR}/${SPECIFIC_TEST}"
  if [[ ! -f "${test_file}" ]]; then
    test_file="${SCRIPT_DIR}/test_${SPECIFIC_TEST}"
  fi
  if [[ ! -f "${test_file}" ]]; then
    test_file="${SCRIPT_DIR}/test_${SPECIFIC_TEST}.sh"
  fi

  if [[ -f "${test_file}" ]]; then
    run_suite "${test_file}"
  else
    echo -e "${RED}Error: Test file not found: ${SPECIFIC_TEST}${NC}"
    exit 1
  fi
else
  # Run all test files
  for test_file in "${SCRIPT_DIR}"/test_*.sh; do
    if [[ -f "${test_file}" ]] && [[ "${test_file}" != *"test_common.sh" ]]; then
      run_suite "${test_file}" || true
    fi
  done
fi

# Print overall summary
echo ""
echo -e "${BLUE}"
echo "╔══════════════════════════════════════╗"
echo "║          Overall Summary             ║"
echo "╚══════════════════════════════════════╝"
echo -e "${NC}"
echo "  Test Suites Run:    ${TOTAL_SUITES}"
echo -e "  Test Suites Passed: ${GREEN}${PASSED_SUITES}${NC}"
echo -e "  Test Suites Failed: ${RED}${FAILED_SUITES}${NC}"
echo ""

if [[ ${FAILED_SUITES} -gt 0 ]]; then
  echo -e "${RED}Some tests failed!${NC}"
  exit 1
else
  echo -e "${GREEN}All tests passed!${NC}"
  exit 0
fi
