class KioskSetup < Formula
  desc "Setup minimal window management to launch Google Chrome in fullscreen"
  homepage "https://github.com/OrtheSnowJames/homebrew-kiosk"
  version "1.0.0"

  # URL to the raw setup script in your GitHub repository
  url "https://raw.githubusercontent.com/OrtheSnowJames/homebrew-kiosk/main/bin/kiosk-setup.sh"
  sha256 "6cee74a7a4a0def2857563aa4368a99d9b99d3af6451ad8434c1f2c47692362b"

  depends_on "curl" => :build

  def install
    # Install the setup script into Homebrew's bin directory
    bin.install "kiosk-setup.sh" => "kiosk-setup"
  end

  def caveats
    <<~EOS
      To complete the kiosk setup, run:
        kiosk-setup

      This script will:
        - Install Xorg and xinit
        - Install Google Chrome
        - Configure .xinitrc for kiosk mode
        - Optionally set up automatic startup on tty1

      Ensure you have sudo privileges as the script requires them for installations.
      Supported package managers: apt, yum, zypper, pacman, apk.
    EOS
  end
end
