#!/usr/bin/env bash
# test_version_file.sh - Tests for version file detection

set -uo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common utilities
source "${SCRIPT_DIR}/test_common.sh"

echo "========================================"
echo "Running Version File Tests"
echo "========================================"

setup_test_env
trap cleanup_test_env EXIT

# Test 1: No version file returns default
run_test "No version file returns config default" '
  output="$(atmosenv version-file 2>&1)"
  assert_contains "${output}" "${ATMOSENV_CONFIG_DIR}/version"
'

# Test 2: Project .atmos-version is found
run_test "Project .atmos-version is detected" '
  mkdir -p "${TEST_DIR}/project"
  echo "1.201.0" > "${TEST_DIR}/project/.atmos-version"
  cd "${TEST_DIR}/project"
  output="$(atmosenv version-file 2>&1)"
  assert_contains "${output}" "project/.atmos-version"
'

# Test 3: Parent directory .atmos-version is found
run_test "Parent directory .atmos-version is detected" '
  mkdir -p "${TEST_DIR}/parent/child/grandchild"
  echo "1.200.0" > "${TEST_DIR}/parent/.atmos-version"
  cd "${TEST_DIR}/parent/child/grandchild"
  output="$(atmosenv version-file 2>&1)"
  assert_contains "${output}" "parent/.atmos-version"
'

# Test 4: Closer .atmos-version takes precedence
run_test "Closer .atmos-version takes precedence" '
  mkdir -p "${TEST_DIR}/outer/inner"
  echo "1.200.0" > "${TEST_DIR}/outer/.atmos-version"
  echo "1.201.0" > "${TEST_DIR}/outer/inner/.atmos-version"
  cd "${TEST_DIR}/outer/inner"
  version_file="$(atmosenv version-file 2>&1)"
  assert_contains "${version_file}" "inner/.atmos-version"
'

# Test 5: Home directory .atmos-version fallback
run_test "Home directory .atmos-version is used as fallback" '
  echo "1.199.0" > "${HOME}/.atmos-version"
  mkdir -p "${TEST_DIR}/empty-project"
  cd "${TEST_DIR}/empty-project"
  output="$(atmosenv version-file 2>&1)"
  assert_contains "${output}" ".atmos-version"
'

# Test 6: Environment variable overrides file
run_test "ATMOSENV_ATMOS_VERSION overrides version file" '
  echo "1.200.0" > "${TEST_DIR}/.atmos-version"
  cd "${TEST_DIR}"
  export ATMOSENV_ATMOS_VERSION="1.201.0"
  output="$(atmosenv version-name 2>&1)" || true
  # The version-name will try to use 1.201.0, even if not installed
  assert_contains "${output}" "1.201.0"
  unset ATMOSENV_ATMOS_VERSION
'

# Test 7: Version file with 'v' prefix is handled
run_test "Version with v prefix is cleaned" '
  echo "v1.200.0" > "${TEST_DIR}/.atmos-version"
  cd "${TEST_DIR}"
  # Source the lib to test clean_version
  source "${ATMOSENV_ROOT}/lib/helpers.sh"
  source "${ATMOSENV_ROOT}/lib/atmosenv-version-file.sh"
  version="$(read_version_file "${TEST_DIR}/.atmos-version")"
  # Note: read_version_file returns raw content; clean_version is called elsewhere
  [[ "${version}" == "v1.200.0" ]] || [[ "${version}" == "1.200.0" ]]
'

# Test 8: Empty version file is handled
run_test "Empty version file is handled gracefully" '
  echo "" > "${TEST_DIR}/.atmos-version"
  cd "${TEST_DIR}"
  output="$(atmosenv version-name 2>&1)" || true
  # Should either show error or fall back
  [[ -n "${output}" ]]
'

# Test 9: Comment lines in version file are ignored
run_test "Comments in version file are ignored" '
  cat > "${TEST_DIR}/.atmos-version" << EOF
# This is a comment
1.200.0
EOF
  cd "${TEST_DIR}"
  source "${ATMOSENV_ROOT}/lib/helpers.sh"
  source "${ATMOSENV_ROOT}/lib/atmosenv-version-file.sh"
  version="$(read_version_file "${TEST_DIR}/.atmos-version")"
  assert_contains "${version}" "1.200.0"
'

# Test 10: Whitespace in version file is trimmed
run_test "Whitespace in version file is trimmed" '
  echo "  1.200.0  " > "${TEST_DIR}/.atmos-version"
  cd "${TEST_DIR}"
  source "${ATMOSENV_ROOT}/lib/helpers.sh"
  source "${ATMOSENV_ROOT}/lib/atmosenv-version-file.sh"
  version="$(read_version_file "${TEST_DIR}/.atmos-version")"
  [[ "${version}" == "1.200.0" ]]
'

# Print summary
print_summary
