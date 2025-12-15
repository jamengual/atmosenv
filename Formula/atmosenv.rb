# Homebrew formula for atmosenv
# Atmos version manager inspired by tfenv

class Atmosenv < Formula
  desc "Atmos version manager inspired by tfenv"
  homepage "https://github.com/jamengual/atmosenv"
  url "https://github.com/jamengual/atmosenv/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "PLACEHOLDER_SHA256"  # Update with actual SHA256 after release
  license "Apache-2.0"
  version_scheme 1

  head "https://github.com/jamengual/atmosenv.git", branch: "main"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  no_autobump! because: :requires_manual_review

  conflicts_with "tenv", because: "atmosenv symlinks atmos binaries"
  conflicts_with "atmos", because: "atmosenv manages atmos versions"

  def install
    prefix.install %w[bin lib libexec share]
    bin.env_script_all_files libexec,
                             ATMOSENV_ROOT:       prefix,
                             ATMOSENV_CONFIG_DIR: "${ATMOSENV_CONFIG_DIR:-${XDG_CONFIG_HOME:-${HOME}/.config}/atmosenv}"
  end

  def post_install
    # Create config directory if it doesn't exist
    config_dir = var/"atmosenv"
    config_dir.mkpath unless config_dir.directory?
  end

  test do
    # Test version command
    assert_match "atmosenv", shell_output("#{bin}/atmosenv --version")

    # Test list-remote (verify we can reach GitHub API)
    output = shell_output("#{bin}/atmosenv list-remote -n 5 2>&1", 0)
    assert_match(/\d+\.\d+\.\d+/, output)

    # Test version-name without installed versions
    # Should fail gracefully
    with_env(ATMOSENV_CONFIG_DIR: testpath/".atmosenv") do
      output = shell_output("#{bin}/atmosenv version-name 2>&1", 1)
      assert_match(/no.*version/i, output)
    end
  end

  def caveats
    <<~EOS
      To use atmosenv, add the following to your shell configuration:

      For bash (~/.bash_profile or ~/.bashrc):
        eval "$(atmosenv init -)"

      For zsh (~/.zshrc):
        eval "$(atmosenv init -)"

      For fish (~/.config/fish/config.fish):
        atmosenv init - | source

      Quick start:
        atmosenv install latest    # Install latest Atmos version
        atmosenv use latest        # Switch to latest version
        atmos version              # Verify installation
    EOS
  end
end
