# Homebrew formula for atmosenv
# This file should be placed in: homebrew-atmosenv/Formula/atmosenv.rb
# Users install with: brew tap jamengual/atmosenv && brew install atmosenv

class Atmosenv < Formula
  desc "Atmos version manager inspired by tfenv"
  homepage "https://github.com/jamengual/atmosenv"
  url "https://github.com/jamengual/atmosenv/archive/refs/tags/v0.1.2.tar.gz"
  sha256 "a433cac6a28bf95aa0be70cb4dc47e6b3eafb89775629b304eb4af5733d2c9d6"
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
    prefix.install %w[bin libexec]

    # Install share directory if it exists
    prefix.install "share" if File.directory?("share")

    # Create wrapper scripts that set environment variables
    bin.env_script_all_files libexec/"bin",
                             ATMOSENV_ROOT:       prefix,
                             ATMOSENV_CONFIG_DIR: "${ATMOSENV_CONFIG_DIR:-${XDG_CONFIG_HOME:-${HOME}/.config}/atmosenv}"
  end

  def post_install
    # Ensure config directory structure exists
    config_dir = Pathname.new(ENV["HOME"])/".config"/"atmosenv"
    config_dir.mkpath unless config_dir.directory?
    (config_dir/"versions").mkpath unless (config_dir/"versions").directory?
  end

  test do
    # Test help command works
    assert_match "atmosenv", shell_output("#{bin}/atmosenv --help")

    # Test version output
    assert_match(/\d+\.\d+\.\d+/, shell_output("#{bin}/atmosenv --version"))

    # Create isolated test environment
    test_config = testpath/".config/atmosenv"
    test_config.mkpath
    (test_config/"versions").mkpath

    # Test list command in empty state
    with_env(ATMOSENV_CONFIG_DIR: test_config.to_s, HOME: testpath.to_s) do
      output = shell_output("#{bin}/atmosenv list 2>&1")
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

      Configuration:
        Versions are stored in: ~/.config/atmosenv/versions/
        Default version file:   ~/.config/atmosenv/version
        Project version file:   .atmos-version (in your project root)
    EOS
  end
end
