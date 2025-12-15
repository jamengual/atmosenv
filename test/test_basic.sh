#!/usr/bin/env bash
# test_basic.sh - Basic functionality tests

set -uo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common utilities
source "${SCRIPT_DIR}/test_common.sh"

echo "========================================"
echo "Running Basic Tests"
echo "========================================"

setup_test_env
trap cleanup_test_env EXIT

# Test 1: atmosenv --help
run_test "atmosenv --help returns help text" '
  output="$(atmosenv --help 2>&1)"
  assert_contains "${output}" "Usage:"
'

# Test 2: atmosenv --version
run_test "atmosenv --version returns version" '
  output="$(atmosenv --version 2>&1)"
  assert_match "${output}" "[0-9]+\.[0-9]+\.[0-9]+"
'

# Test 3: atmosenv help subcommand
run_test "atmosenv help shows usage" '
  output="$(atmosenv help 2>&1)"
  assert_contains "${output}" "Commands:"
'

# Test 4: Unknown command fails
run_test "atmosenv unknown-command fails" '
  assert_exit_code 1 atmosenv unknown-command
'

# Test 5: atmosenv list with no versions
run_test "atmosenv list with no versions installed" '
  # Reset log level to see warnings
  ATMOSENV_LOG_LEVEL=WARN output="$(atmosenv list 2>&1)"
  assert_contains "${output}" "No Atmos versions installed"
'

# Test 6: atmosenv version-file returns path
run_test "atmosenv version-file returns a path" '
  output="$(atmosenv version-file 2>&1)"
  assert_contains "${output}" "atmosenv"
'

# Test 7: .atmos-version file detection
run_test ".atmos-version file is detected" '
  echo "1.200.0" > "${TEST_DIR}/.atmos-version"
  cd "${TEST_DIR}"
  output="$(atmosenv version-file 2>&1)"
  assert_contains "${output}" ".atmos-version"
'

# Test 8: atmosenv init - outputs shell script
run_test "atmosenv init - outputs shell initialization" '
  output="$(atmosenv init - 2>&1)"
  assert_contains "${output}" "PATH"
'

# Test 9: atmosenv init bash shows instructions
run_test "atmosenv init bash shows instructions" '
  output="$(atmosenv init bash 2>&1)"
  assert_contains "${output}" "bashrc"
'

# Test 10: atmosenv init zsh shows instructions
run_test "atmosenv init zsh shows instructions" '
  output="$(atmosenv init zsh 2>&1)"
  assert_contains "${output}" "zshrc"
'

# Test 11: install --help
run_test "atmosenv install --help shows usage" '
  output="$(atmosenv install --help 2>&1)"
  assert_contains "${output}" "Usage:"
'

# Test 12: use --help
run_test "atmosenv use --help shows usage" '
  output="$(atmosenv use --help 2>&1)"
  assert_contains "${output}" "Usage:"
'

# Test 13: uninstall --help
run_test "atmosenv uninstall --help shows usage" '
  output="$(atmosenv uninstall --help 2>&1)"
  assert_contains "${output}" "Usage:"
'

# Test 14: list-remote --help
run_test "atmosenv list-remote --help shows usage" '
  output="$(atmosenv list-remote --help 2>&1)"
  assert_contains "${output}" "Usage:"
'

# Print summary
print_summary
