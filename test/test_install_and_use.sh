#!/usr/bin/env bash
# test_install_and_use.sh - Tests for install and use commands
# Note: These tests require network access to GitHub

set -uo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common utilities
source "${SCRIPT_DIR}/test_common.sh"

echo "========================================"
echo "Running Install and Use Tests"
echo "========================================"
echo "(These tests require network access)"
echo ""

setup_test_env
trap cleanup_test_env EXIT

# Test 1: list-remote returns versions
run_test "atmosenv list-remote returns versions" '
  output="$(atmosenv list-remote -n 5 2>&1)"
  assert_match "${output}" "[0-9]+\.[0-9]+\.[0-9]+"
'

# Test 2: list-remote with limit
run_test "atmosenv list-remote -n 3 limits output" '
  output="$(atmosenv list-remote -n 3 2>&1)"
  line_count=$(echo "${output}" | grep -c "^[0-9]" || true)
  [[ ${line_count} -le 3 ]]
'

# Test 3: list-remote --prereleases includes RCs
run_test "atmosenv list-remote --prereleases includes pre-releases" '
  output="$(atmosenv list-remote -a -p 2>&1)"
  # Just check it runs without error for now
  [[ -n "${output}" ]]
'

# Skip actual install tests by default (they download large binaries)
if [[ "${ATMOSENV_TEST_INSTALL:-false}" == "true" ]]; then
  echo ""
  echo "Running installation tests (ATMOSENV_TEST_INSTALL=true)"
  echo ""

  # Test 4: Install a specific version
  run_test "atmosenv install specific version" '
    atmosenv install 1.200.0 2>&1
    assert_file_exists "${ATMOSENV_CONFIG_DIR}/versions/1.200.0/atmos"
  '

  # Test 5: Install latest
  run_test "atmosenv install latest" '
    atmosenv install latest 2>&1
    # Check that at least one version is installed
    [[ -n "$(ls -A "${ATMOSENV_CONFIG_DIR}/versions/" 2>/dev/null)" ]]
  '

  # Test 6: Use installed version
  run_test "atmosenv use switches version" '
    atmosenv use 1.200.0 2>&1
    current="$(atmosenv version-name 2>&1)"
    assert_contains "${current}" "1.200.0"
  '

  # Test 7: List shows installed versions
  run_test "atmosenv list shows installed versions" '
    output="$(atmosenv list 2>&1)"
    assert_contains "${output}" "1.200.0"
  '

  # Test 8: Uninstall version
  run_test "atmosenv uninstall removes version" '
    atmosenv uninstall -f 1.200.0 2>&1
    [[ ! -d "${ATMOSENV_CONFIG_DIR}/versions/1.200.0" ]]
  '
else
  echo ""
  echo -e "${YELLOW}Skipping installation tests (set ATMOSENV_TEST_INSTALL=true to enable)${NC}"
  echo ""
fi

# Print summary
print_summary
