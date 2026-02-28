#!/usr/bin/bash

# ==============================================================================
# COLOR DEFINITIONS
# ==============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
# ==============================================================================

# ==============================================================================
# PROMPT FUNCTION: Standardized Yes/No interactive handler
# ==============================================================================
AUTO_ACCEPT_ALL=false

ask_prompt() {
    local prompt_text="$1"

    # If the user previously selected "Accept All" at the master prompt, bypass and return true.
    if [ "$AUTO_ACCEPT_ALL" = true ]; then
        return 0
    fi

    while true; do
        # Use echo -e -n to print colored prompt without a trailing newline,
        # then read the user input on the same line.
        echo -e -n "${YELLOW}${prompt_text} [Y/n]: ${NC}"
        read -r yn
        case $yn in
            [Yy]* | "" ) return 0 ;; # Default to Yes
            [Nn]* ) return 1 ;;      # Deny/Skip
            * ) echo -e "${RED}Please answer yes (Y/y) or no (N/n).${NC}" ;;
        esac
    done
}
# ==============================================================================

# Welcome to my semi-automatized FEDORA (42+) Post installation Script:
echo ""
echo -e "${CYAN}===============================================================================================${NC}"
echo -e "${CYAN}   Welcome to my semi-automatized FEDORA KDE Post installation Script         ${NC}"
echo -e "${CYAN}   This script can be run either as a currently logged in [HOME USER] or ROOT ${NC}"
echo -e "${CYAN}   Feel free to Auto-Accept ALL (A), Confirm (Y) or Deny (N) prompting options to fit your needs    ${NC}"
echo -e "${CYAN}===============================================================================================${NC}"
echo ""
#

# VARIABLE DEFINITIONS; Define your FEDORA VERSION HERE:
echo ""
echo -e "${BLUE}VARIABLE DEFINITIONS; Define your FEDORA VERSION HERE ...${NC}"
while true; do
    echo -e -n "${YELLOW}Please specify your Fedora version (Options: 42, 43, 44, or Rawhide): ${NC}"
    read -r user_input

    # Convert input to lowercase to seamlessly handle variations like "Rawhide" or "RAWHIDE"
    formatted_input="${user_input,,}"

    case "$formatted_input" in
        42|43|44)
            releasever="$formatted_input"
            break
            ;;
        rawhide)
            # The 'Rawhide' string must remain exactly as is, case-sensitive (capital 'R')
            # This is critical for Open Build Service (OBS) repository URLs (e.g., Fedora_Rawhide)
            releasever="Rawhide"
            break
            ;;
        *)
            echo -e "${RED}Invalid selection. You must enter 42, 43, 44, or Rawhide.${NC}"
            ;;
    esac
done
echo -e "${GREEN}FEDORA VERSION SET TO: $releasever${NC}"
echo ""
#

# ==============================================================================
# GLOBAL AUTO-ACCEPT PROMPT (Top of hierarchy)
# ==============================================================================
echo -e "${CYAN}==========================================================================================${NC}"
echo -e "${YELLOW}Would you like to ENABLE AUTO-ACCEPT ALL, including REBOOT for the rest of this installation?   ${NC}"
echo -e "${YELLOW} - YES (A): Skips all individual prompts and installs EVERYTHING automatically. ${NC}"
echo -e "${YELLOW} - NO (N): Prompts you individually for each software category (Default).     ${NC}"
echo -e "${CYAN}==========================================================================================${NC}"
while true; do
    echo -e -n "${YELLOW}Enable Auto-Accept All? [a/N]: ${NC}"
    read -r auto_yn
    case $auto_yn in
        [Aa]* | [Yy]* )
            AUTO_ACCEPT_ALL=true
            echo -e "${GREEN}Global 'Auto Accept All' enabled. The script will now run unattended.${NC}"
            break
            ;;
        [Nn]* | "" )
            AUTO_ACCEPT_ALL=false
            echo -e "${BLUE}Individual prompting retained. You will be asked for each step.${NC}"
            break
            ;;
        * )
            echo -e "${RED}Please answer Accept All (A/a) or No (N/n). Default is No (N).${NC}"
            ;;
    esac
done
echo ""
#

# Change/modify the password prompt timeout for the [sudo] command:
if ask_prompt "Disable sudo password prompt timeout (Defaults timestamp_timeout=-1)?"; then
    echo -e "${GREEN}Modifying sudo password prompt timeout (-1) to last until logout/reboot:${NC}"
    # Utilizing a drop-in file in /etc/sudoers.d/ is the safest programmatic alternative to manual 'visudo'
    echo "Defaults timestamp_timeout=-1" | sudo tee "/etc/sudoers.d/99-disable-timeout" > /dev/null

    # Strict 0440 permissions are mandatorily required by the sudoers system
    sudo chmod 0440 "/etc/sudoers.d/99-disable-timeout"
    echo -e "${CYAN}Wrote configuration options: [Defaults timestamp_timeout=-1] into: [/etc/sudoers.d/99-disable-timeout] file.${NC}"
else
    echo -e "${RED}Skipped modifying sudo password prompt timeout.${NC}"
fi
echo ""
#

# Instruct DNF solver to use lower version package if the newest one cannot be obtained;
if ask_prompt "Configure DNF to use lower version packages (best=False)?"; then
    echo -e "${GREEN}Instructing DNF solver to use lower version of a package...${NC}"
    sudo tee -a "/etc/dnf/dnf.conf" <<EOF
best=False
EOF
    echo -e "${CYAN}Wrote configuration options: [best=False] into: [/etc/dnf/dnf.conf] configuration file.${NC}"
else
    echo -e "${RED}Skipped DNF [best=False] configuration.${NC}"
fi
echo ""
#

# Set prompting of DNF confirmation for transactional changes from NO (N) to YES (Y):
if ask_prompt "Set DNF default prompt to YES (defaultyes=true)?"; then
    echo -e "${GREEN}Set prompting of DNF confirmation for transactional changes from NO (N) to YES (Y) ...${NC}"
    sudo tee -a "/etc/dnf/dnf.conf" <<EOF
defaultyes=true
EOF
    echo -e "${CYAN}Wrote configuration options: [defaultyes=True] into: [/etc/dnf/dnf.conf] configuration file.${NC}"
else
    echo -e "${RED}Skipped DNF [defaultyes=true] configuration.${NC}"
fi
echo ""
#

# Set DNF maximum parallel downloads to 10:
if ask_prompt "Set DNF maximum parallel downloads to 10?"; then
    echo -e "${GREEN}Set DNF maximum parallel downloads to 10 ...${NC}"
    sudo tee -a "/etc/dnf/dnf.conf" <<EOF
max_parallel_downloads=10
EOF
    echo -e "${CYAN}Set DNF maximum parallel downloads to 10: [max_parallel_downloads=10] into: [/etc/dnf/dnf.conf] configuration file.${NC}"
else
    echo -e "${RED}Skipped DNF [max_parallel_downloads=10] configuration.${NC}"
fi
echo ""
#

# Install, setup and enable RPM Fusion repository Fedora 42+:
if ask_prompt "Install and enable RPM Fusion (Free & Non-Free/Proprietary) repositories?"; then
    echo -e "${GREEN}Installing, enabling and setting up RPM Fusion repository Fedora 42+:${NC}"
    echo ""
    # FREE variant:
    echo -e "${BLUE}FREE variant:${NC}"
    sudo dnf -y install "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm"
    echo ""
    # NON-FREE/Proprietary variant:
    echo -e "${BLUE}NON-FREE/Proprietary variant:${NC}"
    sudo dnf -y install "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
else
    echo -e "${RED}Skipped RPM Fusion repositories installation.${NC}"
fi
echo ""
#

# Install, setup and enable Terra repository Fedora 42+:
if ask_prompt "Install and enable Terra repository?"; then
    echo -e "${GREEN}Installing, enabling and setting up Terra repository Fedora 42+:${NC}"
    # Note: Using ${releasever,,} dynamically converts 'Rawhide' to 'rawhide' specifically for Terra's URL format.
    sudo dnf -y install --nogpgcheck --repofrompath "terra,https://repos.fyralabs.com/terra${releasever,,}" "terra-release"
else
    echo -e "${RED}Skipped Terra repository installation.${NC}"
fi
echo ""
#

# Refresh all repositories:
if ask_prompt "Refresh all repositories and upgrade @core?"; then
    echo -e "${GREEN}Refreshing all repositories:${NC}"
    sudo dnf -y makecache --refresh && sudo dnf -y install "@core" && sudo dnf -y upgrade "@core"
else
    echo -e "${RED}Skipped repository refresh and @core upgrade.${NC}"
fi
echo ""
#

# Enable OpenH264 codecs on Fedora 42+:
if ask_prompt "Enable OpenH264 codecs (fedora-cisco-openh264)?"; then
    echo -e "${GREEN}Enabling OpenH264 codecs on Fedora 42+:${NC}"
    sudo dnf -y config-manager setopt "fedora-cisco-openh264.enabled=1"
else
    echo -e "${RED}Skipped OpenH264 codecs enablement.${NC}"
fi
echo ""
#

# Install and enable AppStream metadata:
if ask_prompt "Install RPM Fusion AppStream metadata?"; then
    echo -e "${GREEN}Installing and enabling AppStream metadata:${NC}"
    sudo dnf -y install rpmfusion-\*-appstream-data
else
    echo -e "${RED}Skipped AppStream metadata installation.${NC}"
fi
echo ""
#

# Swap and switch to full-featured FFMPEG codecs:
if ask_prompt "Swap ffmpeg-free for full-featured ffmpeg?"; then
    echo -e "${GREEN}Swapping and switching to full-featured FFMPEG codecs:${NC}"
    sudo dnf -y swap "ffmpeg-free" "ffmpeg" --allowerasing
else
    echo -e "${RED}Skipped FFMPEG swap.${NC}"
fi
echo ""
#

# Install additional codecs:
if ask_prompt "Install general multimedia/sound and video codec groups?"; then
    echo -e "${GREEN}Installing additional codecs:${NC}"
    sudo dnf -y install "@multimedia" && sudo dnf -y upgrade "@multimedia"
    sudo dnf -y install "@sound-and-video" && sudo dnf -y upgrade "@sound-and-video"
else
    echo -e "${RED}Skipped general multimedia codec groups.${NC}"
fi
echo ""
#

# Install hardware accelerated codecs:
if ask_prompt "Install hardware accelerated codecs (AMD/INTEL/NVIDIA - ALL GPUs)?"; then
    echo -e "${GREEN}Installing hardware accelerated codecs ...${NC}"
    echo ""
    # For ALL GPUs / AMD:
    echo -e "${BLUE}For ALL GPUs / AMD (Both 32-bit & 64-bit):${NC}"
    sudo dnf -y swap "mesa-va-drivers.x86_64" "mesa-va-drivers-freeworld.x86_64"
    sudo dnf -y swap "mesa-va-drivers.i686"   "mesa-va-drivers-freeworld.i686"
    echo ""
    # For INTEL GPUs:
    echo -e "${BLUE}For INTEL GPUs (Both 32-bit & 64-bit):${NC}"
    sudo dnf -y install intel-media-driver.{i686,x86_64}
    sudo dnf -y install libva-intel-driver.{i686,x86_64}
    echo ""
    # For NVIDIA GPUs:
    echo -e "${BLUE}For NVIDIA GPUs (Both 32-bit & 64-bit):${NC}"
    echo -e "${CYAN}These are essential for NVIDIA GPUs; But recommended for any GPU due to extra dependencies suitable for all GPUs ...${NC}"
    sudo dnf -y install libva-nvidia-driver.{i686,x86_64}
else
    echo -e "${RED}Skipped hardware accelerated codecs installation.${NC}"
fi
echo ""
#

# Install, configure and activate VirtualBox:
if ask_prompt "Install, configure and activate VirtualBox?"; then
    echo -e "${GREEN}Installing VirtualBox:${NC}"
    sudo dnf -y install --skip-unavailable "VirtualBox"
    echo ""

    echo -e "${CYAN}Executing post-installation commands (building akmods and restarting vboxdrv)...${NC}"
    sudo akmods
    sudo systemctl restart vboxdrv
    sudo lsmod | grep -i vbox
    echo ""

    # Determine the actual human user, even if the script is executed by 'root'
    TARGET_USER="${SUDO_USER:-$USER}"

    if [ "$TARGET_USER" = "root" ]; then
        echo -e "${YELLOW}Notice: Script is executing as the 'root' user.${NC}"
        echo -e -n "${YELLOW}Please enter the specific home username to add to VirtualBox groups (or leave blank to skip): ${NC}"
        read -r input_user
        if [ -z "$input_user" ]; then
            TARGET_USER=""
        elif id "$input_user" &>/dev/null; then
            TARGET_USER="$input_user"
        else
            echo -e "${RED}Error: The user '$input_user' does not exist on this system.${NC}"
            TARGET_USER=""
        fi
    fi

    if [ -n "$TARGET_USER" ]; then
        if ask_prompt "Add target user ($TARGET_USER) to VirtualBox groups (users, vboxusers)?"; then
            echo -e "${GREEN}Adding $TARGET_USER to VirtualBox groups...${NC}"
            sudo usermod -a -G 'users,vboxusers' "$TARGET_USER"
            echo -e "${CYAN}Successfully added $TARGET_USER to VirtualBox groups.${NC}"
        else
            echo -e "${RED}Skipped adding $TARGET_USER to VirtualBox groups.${NC}"
            echo -e "${YELLOW}If you wish to do it manually later, issue: [sudo usermod -a -G 'users,vboxusers' $TARGET_USER]${NC}"
        fi
    else
        echo -e "${RED}Skipped VirtualBox user group configuration phase due to invalid or unspecified target user.${NC}"
    fi
else
    echo -e "${RED}Skipped VirtualBox installation.${NC}"
fi
echo ""
#

# Add HOME (Martin von Reichenberg) repositories from Open Build Service (OBS):
if ask_prompt "Would you like to add Open Build Service (OBS) HOME (from Martin von Reichenberg) Repositories?"; then
    echo -e "${GREEN}Adding HOME (Martin von Reichenberg) repositories from Open Build Service (OBS); meant only for Fedora 42+:${NC}"

    echo -e "${BLUE}Adding Custom BASE - SYSTEM Utilities Packages HOME (Martin von Reichenberg) Repository:${NC}"
    sudo dnf config-manager addrepo \
        --from-repofile="https://download.opensuse.org/repositories/home:MartinVonReichenberg:Base:System/Fedora_$releasever/home:MartinVonReichenberg:Base:System.repo"

    echo -e "${BLUE}Adding Custom NETWORK Programs & Utilities Packages HOME (Martin von Reichenberg) Repository:${NC}"
    sudo dnf config-manager addrepo \
        --from-repofile="https://download.opensuse.org/repositories/home:MartinVonReichenberg:network/Fedora_$releasever/home:MartinVonReichenberg:network.repo"

    echo -e "${BLUE}Adding Customized qBitTorrent Program HOME (Martin von Reichenberg) Repository:${NC}"
    sudo dnf config-manager addrepo \
        --from-repofile="https://download.opensuse.org/repositories/home:MartinVonReichenberg:Network:qBittorrent/Fedora_$releasever/home:MartinVonReichenberg:Network:qBittorrent.repo"

    echo -e "${BLUE}Adding Custom KDE Extra Applications Packages HOME (Martin von Reichenberg) Repository:${NC}"
    sudo dnf config-manager addrepo \
        --from-repofile="https://download.opensuse.org/repositories/home:MartinVonReichenberg:KDE:Extra/Fedora_$releasever/home:MartinVonReichenberg:KDE:Extra.repo"

    echo -e "${BLUE}Adding Custom GAMING Packages HOME (Martin von Reichenberg) Repository:${NC}"
    sudo dnf config-manager addrepo \
        --from-repofile="https://download.opensuse.org/repositories/home:MartinVonReichenberg:games:tools/Fedora_$releasever/home:MartinVonReichenberg:games:tools.repo"

    echo -e "${BLUE}Adding Custom HADWARE Packages HOME (Martin von Reichenberg) Repository:${NC}"
    sudo dnf config-manager addrepo \
        --from-repofile="https://download.opensuse.org/repositories/home:MartinVonReichenberg:branches:hardware/Fedora_$releasever/home:MartinVonReichenberg:branches:hardware.repo"
else
    echo -e "${RED}Skipped OBS HOME (from Martin von Reichenberg) Repositories.${NC}"
fi
echo ""
#

# Add WINE (Wine H.Q.) Repository:
if ask_prompt "Add WINE (Wine H.Q.) Repository?"; then
    echo -e "${GREEN}Adding WINE (Wine H.Q.) Repository:${NC}"
    # Note: Using ${releasever,,} dynamically converts 'Rawhide' to 'rawhide' specifically for WineHQ's URL format.
    sudo dnf config-manager addrepo \
        --from-repofile="https://dl.winehq.org/wine-builds/fedora/${releasever,,}/winehq.repo"
else
    echo -e "${RED}Skipped WINE Repository addition.${NC}"
fi
echo ""
#

# Refresh & upgrade packages on Fedora 42+:
if ask_prompt "Refresh and upgrade all packages now?"; then
    echo -e "${GREEN}Refresh & upgrade packages on Fedora 42+:${NC}"
    sudo dnf -y upgrade --refresh
else
    echo -e "${RED}Skipped package upgrade.${NC}"
fi
echo ""
#

# Add FlatHub repository for Flatpak:
if ask_prompt "Add FlatHub repository for Flatpak?"; then
    echo -e "${GREEN}Adding FlatHub repository for Flatpak ...${NC}"
    sudo flatpak remote-add --if-not-exists "flathub" "https://dl.flathub.org/repo/flathub.flatpakrepo"
else
    echo -e "${RED}Skipped FlatHub repository addition.${NC}"
fi
echo ""
#

# Add and enable Opera repository:
if ask_prompt "Add Opera browser repository?"; then
    echo -e "${GREEN}Adding and enabling Opera repository:${NC}"
    sudo rpm --import "https://rpm.opera.com/rpmrepo.key"
    sudo tee "/etc/yum.repos.d/opera.repo" <<EOF
[opera]
name=Opera Repository
type=rpm-md
baseurl=https://rpm.opera.com/rpm
gpgcheck=1
gpgkey=https://rpm.opera.com/rpmrepo.key
enabled=1
EOF
    echo -e "${CYAN}Added [opera.repo] repository file into [/etc/yum.repos.d/] directory.${NC}"
else
    echo -e "${RED}Skipped Opera repository addition.${NC}"
fi
echo ""
#

# Add and enable Vivaldi repository:
if ask_prompt "Add Vivaldi browser repository?"; then
    echo -e "${GREEN}Adding and enabling Vivaldi repository:${NC}"
    sudo rpm --import "https://repo.vivaldi.com/stable/linux_signing_key.pub"
    sudo tee "/etc/yum.repos.d/vivaldi.repo" <<EOF
[vivaldi]
name=Vivaldi Repository
type=rpm-md
baseurl=https://repo.vivaldi.com/archive/rpm/x86_64
enabled=0
gpgcheck=1
gpgkey=https://repo.vivaldi.com/archive/linux_signing_key.pub
EOF
    echo -e "${CYAN}Added [vivaldi.repo] repository file into [/etc/yum.repos.d/] directory.${NC}"
else
    echo -e "${RED}Skipped Vivaldi repository addition.${NC}"
fi
echo ""
#

# ==============================================================================
# MASS PACKAGE INSTALLATION (CATEGORIZED AND ALPHABETIZED)
# ==============================================================================
echo -e "${CYAN}Initiating recommended packages installation phase.${NC}"
sudo dnf -y upgrade --refresh
echo ""

# Development & Build Tools:
if ask_prompt "Install Development & Build Tools (OBS tools, LSPs, formatters, kernel headers)?"; then
    echo -e "${GREEN}Installing Development & Build Tools:${NC}"
    sudo dnf -y install --skip-unavailable \
        'bash-language-server' 'gh' 'kernel-devel' 'kernel-devel-matched' "obs-build*" "obs-service*" "osc*" \
        'rpm-spec-language-server' 'shfmt'
else
    echo -e "${RED}Skipped Development & Build Tools.${NC}"
fi
echo ""
#

# Gaming & Controller Utilities:
if ask_prompt "Install Gaming & Controller Utilities (Steam, Dualsensectl, DXVK)?"; then
    echo -e "${GREEN}Installing Gaming & Controller Utilities:${NC}"
    sudo dnf -y install --skip-unavailable \
        'dualsensectl' 'dxvk-native' 'egl-wayland' 'glfw' 'steam'
else
    echo -e "${RED}Skipped Gaming & Controller Utilities.${NC}"
fi
echo ""
#

# KDE Desktop Utilities & Science:
if ask_prompt "Install KDE Desktop Utilities & Science (Kate, Kleopatra, Stellarium)?"; then
    echo -e "${GREEN}Installing KDE Desktop Utilities & Science:${NC}"
    sudo dnf -y install --skip-unavailable \
        'kate' 'kgpg' 'kleopatra' 'koi' 'stellarium'
else
    echo -e "${RED}Skipped KDE Desktop Utilities & Science.${NC}"
fi
echo ""
#

# Multimedia Codecs, Fonts & Media Players:
if ask_prompt "Install specific Multimedia Codecs (x264, x265, GStreamer), Fonts & Players (VLC)?"; then
    echo -e "${GREEN}Installing Multimedia Codecs (x264, x265, GStreamer), Fonts & Media Players (VLC):${NC}"

    # -------------------------------------------------------------------------------------------------------------------------
    # Note on Architecture (32-bit vs 64-bit):
    # Core GStreamer packages require {i686,x86_64} for legacy WINE/Proton 32-bit gaming support.
    # The packages below WITHOUT architecture braces strictly conflict or do not exist in the 32-bit repositories.
    # Including 32-bit requests for 'openh264' will cause a critical dummy 'noopenh264' stub conflict.
    # -------------------------------------------------------------------------------------------------------------------------

    sudo dnf -y install --skip-unavailable \
        gstreamer1.{i686,x86_64} gstreamer1-plugin-dav1d.{i686,x86_64} gstreamer1-plugin-fmp4.{i686,x86_64} \
        gstreamer1-plugin-gtk4.{i686,x86_64} gstreamer1-plugin-hsv.{i686,x86_64} gstreamer1-plugin-libav.{i686,x86_64} \
        gstreamer1-plugin-mp4.{i686,x86_64} gstreamer1-plugins-base.{i686,x86_64} gstreamer1-plugins-good.{i686,x86_64} \
        gstreamer1-plugins-good-extras.{i686,x86_64} gstreamer1-plugins-good-gtk.{i686,x86_64} \
        gstreamer1-plugins-good-qt.{i686,x86_64} gstreamer1-plugins-good-qt6.{i686,x86_64} \
        gstreamer1-plugins-ugly.{i686,x86_64} gstreamer1-vaapi.{i686,x86_64} x265.{i686,x86_64} \
        'gstreamer1-plugin-openh264' 'gstreamer1-plugins-bad-free' 'gstreamer1-plugins-fc' \
        'mozilla-openh264' 'openh264' 'vlc' 'vlc-plugins-base' 'x264'
else
    echo -e "${RED}Skipped specific Multimedia Codecs & Players.${NC}"
fi
echo ""
#

# System Fonts, Extra Fonts & Asian Language Support:
if ask_prompt "Install System Fonts, Extra Fonts & Asian Language Support (Inter, Roboto, Hack Nerd, CJK)?"; then
    echo -e "${GREEN}Installing System Fonts & Asian Language Support:${NC}"
    sudo dnf -y install --skip-unavailable \
        'google-noto-cjk-fonts' 'google-noto-color-emoji-fonts' 'google-noto-sans-cjk-fonts' 'google-noto-serif-cjk-fonts' \
        'google-roboto-fonts' 'google-roboto-mono-fonts' 'hack-fonts' 'hack-nerd-fonts' 'liberation-fonts-all' \
        'rsms-inter-fonts' 'rsms-inter-vf-fonts' 'vlgothic-fonts' 'wqy-microhei-fonts' 'wqy-zenhei-fonts'
else
    echo -e "${RED}Skipped System Fonts, Extra Fonts & Asian Language Support.${NC}"
fi
echo ""
#

# Dedicated VPN Tools:
# Note: This section explicitly overrides the global AUTO_ACCEPT_ALL behavior.
# The user must actively choose the desired VPN topology (or deliberately skip) to avoid network conflicts.
echo -e "${GREEN}Dedicated VPN Tools Installation:${NC}"
while true; do
    echo -e "${CYAN}==============================================================================${NC}"
    echo -e "${YELLOW}Please specify your preferred VPN Tool (Exception to Auto-Accept All):${NC}"
    echo -e "  ${BLUE}[N]${NC} = NetBird"
    echo -e "  ${BLUE}[T]${NC} = Tailscale"
    echo -e "  ${BLUE}[Z]${NC} = ZeroTier (ZeroTier-One from HOME OBS)"
    echo -e "  ${BLUE}[A]${NC} = ALL of them"
    echo -e "${CYAN}==============================================================================${NC}"
    echo -e -n "${YELLOW}Your choice [N/T/Z/A] (Leave blank/Enter to SKIP): ${NC}"
    read -r vpn_input

    # If the input is completely empty, break the loop and skip the installation entirely.
    if [ -z "$vpn_input" ]; then
        vpn_choice="skip"
        break
    fi

    # Format the input to strictly lowercase to seamlessly handle variations.
    formatted_vpn="${vpn_input,,}"
    case "$formatted_vpn" in
        n|netbird)
            vpn_choice="netbird"
            break
            ;;
        t|tailscale)
            vpn_choice="tailscale"
            break
            ;;
        z|zerotier)
            vpn_choice="zerotier"
            break
            ;;
        a|all)
            vpn_choice="all"
            break
            ;;
        *)
            echo -e "${RED}Invalid selection. Please type N, T, Z, A, or press [Enter] to skip.${NC}"
            ;;
    esac
done

if [ "$vpn_choice" = "skip" ]; then
    echo -e "${RED}Skipped Dedicated VPN Tools installation.${NC}"
else
    if [[ "$vpn_choice" == "netbird" || "$vpn_choice" == "all" ]]; then
        echo -e "${GREEN}Adding NetBird repository and installing NetBird (+ UI):${NC}"
        sudo curl -fsSL "https://pkgs.netbird.io/install.sh" | sudo sh
        sudo dnf -y install --skip-unavailable netbird netbird-ui
        echo -e "${CYAN}Added NetBird repository and installed packages.${NC}"
    fi
    if [[ "$vpn_choice" == "tailscale" || "$vpn_choice" == "all" ]]; then
        echo -e "${GREEN}Installing Tailscale (from official Fedora repositories):${NC}"
        sudo dnf -y install --skip-unavailable tailscale
        echo -e "${CYAN}Installed Tailscale package.${NC}"
    fi
    if [[ "$vpn_choice" == "zerotier" || "$vpn_choice" == "all" ]]; then
        echo -e "${GREEN}Adding Custom NETWORK VPN (ZeroTier) HOME Repository and installing ZeroTier:${NC}"
        sudo dnf config-manager addrepo \
            --from-repofile="https://download.opensuse.org/repositories/home:MartinVonReichenberg:network:vpn/Fedora_$releasever/home:MartinVonReichenberg:network:vpn.repo"
        sudo dnf -y install --skip-unavailable zerotier-one
        echo -e "${CYAN}Added ZeroTier HOME repository and installed packages.${NC}"
    fi
fi
echo ""
#

# Network & Internet Tools:
if ask_prompt "Install Network & Internet Tools (Web Browsers, Instant Messaging apps, Torrent, Remote)?"; then
    echo -e "${GREEN}Installing Network & Internet Tools:${NC}"
    sudo dnf -y install --skip-unavailable \
        'bftpd' 'discord' 'filezilla' 'google-chrome-stable' 'opera-extras' 'opera-stable' \
        'qbittorrent' 'telegram' 'winbox'
else
    echo -e "${RED}Skipped Network & Internet Tools.${NC}"
fi
echo ""
#

# System Utilities & CLI + Packaging Tools:
if ask_prompt "Install System Utilities & CLI + Packaging Tools (Htop, Fish, Zypper, etc.)?"; then
    echo -e "${GREEN}Installing System Utilities & CLI + Packaging Tools:${NC}"
    sudo dnf -y install --skip-unavailable \
        'atop' 'bat' 'btop' 'cowsay' 'fish' 'fortune' 'fuse' 'htop' 'inxi' 'mc' 'micro' 'pcp' 'xclip' 'xsel' 'zypper'
else
    echo -e "${RED}Skipped System Utilities & CLI + Packaging Tools.${NC}"
fi
echo ""
#

# Direct Third-Party RPM URLs (Security & Utilities):
if ask_prompt "Install Direct Third-Party RPMs (Bitwarden, Proton tools, Etcher)?"; then
    echo -e "${GREEN}Installing Direct Third-Party RPMs:${NC}"
    sudo dnf -y install --skip-unavailable \
        "https://github.com/balena-io/etcher/releases/download/v2.1.4/balena-etcher-2.1.4-1.x86_64.rpm" \
        "https://github.com/bitwarden/clients/releases/download/desktop-v2026.1.1/Bitwarden-2026.1.1-x86_64.rpm" \
        "https://proton.me/download/authenticator/linux/ProtonAuthenticator-1.1.4-1.x86_64.rpm" \
        "https://proton.me/download/mail/linux/1.12.1/ProtonMail-desktop-beta.rpm" \
        "https://proton.me/download/pass/linux/proton-pass-1.34.2-1.x86_64.rpm"
else
    echo -e "${RED}Skipped Direct Third-Party RPMs.${NC}"
fi
echo ""
#

# Install and Update additional Flatpak Applications:
if ask_prompt "Install specific Flatpak Applications (ZapZap/WhatsApp, Termius SSH, YouTube Music, ProtonUp-Qt, VacuumTube)?"; then
    echo -e "${GREEN}Installing Flatpak Applications (ZapZap/WhatsApp, Termius SSH, YouTube Music, ProtonUp-Qt, VacuumTube):${NC}"
    sudo flatpak update  -y
    sudo flatpak install -y \
        'app.ytmdesktop.ytmdesktop' 'com.rtosta.zapzap' 'com.termius.Termius' 'net.davidotek.pupgui2' 'rocks.shy.VacuumTube'
else
    echo -e "${RED}Skipped Flatpak Applications.${NC}"
fi
echo ""
#

# Add [sufido] command alias for Fish shell:
if ask_prompt "Add 'sufido' command alias for Fish shell?"; then
    sudo tee "/etc/fish/functions/sufido.fish" <<EOF
function sufido --description "Start a root Fish shell with: [su] and change directory to: [/]"
sudo su --shell /usr/bin/fish -c "cd '/' ; exec fish"
end
EOF
    echo ""
    echo -e "${CYAN}Added [sufido.fish] function file into [/etc/fish/functions/] directory.${NC}"
else
    echo -e "${RED}Skipped adding 'sufido' Fish shell alias.${NC}"
fi
echo ""
#

# Add [backward-kill-subword] function for Fish shell:
if ask_prompt "Add 'backward-kill-subword' function for Fish shell?"; then
    sudo tee "/etc/fish/functions/backward-kill-subword.fish" <<EOF
function backward-kill-subword
    # Temporarily treat dots, slashes, dashes, and underscores as word separators
    # This overrides the global setting just for this single execution
    set -l fish_word_selection_characters "/.-_"

    # Execute the standard backward kill using the new separator rules
    commandline -f backward-kill-word
end
EOF
    echo ""
    echo -e "${CYAN}Added [backward-kill-subword.fish] function file into [/etc/fish/functions/] directory.${NC}"
else
    echo -e "${RED}Skipped adding 'backward-kill-subword' Fish shell function.${NC}"
fi
echo ""
#

# Copy all DNF (YUM) Repositories to ZYPPER Repositories directory:
if ask_prompt "Copy ALL DNF (YUM) Repositories to ZYPPER directory?"; then
    sudo cp -v -f -a /etc/yum.repos.d/* -t "/etc/zypp/repos.d/"
    echo -e "${CYAN}Copied all DNF (YUM) Repositories to ZYPPER Repositories directory . . .${NC}"
    echo ""
    echo -e "${BLUE}Check ZYPPER Repositories listing [ls]:${NC}"
    ls -lAh "/etc/zypp/repos.d/"
else
    echo -e "${RED}Skipped DNF -> ZYPPER repository synchronization.${NC}"
fi
echo ""
#

# Disable Firewall SystemD Service:
if ask_prompt "Disable Firewalld SystemD Service?"; then
    echo -e "${GREEN}Disabling Firewall SystemD Service:${NC}"
    sudo systemctl disable --now "firewalld"
else
    echo -e "${RED}Skipped Firewalld disablement.${NC}"
fi
echo ""
#

# Set SELINUX from ENFORCING to PERMISSIVE using [setenforce] command:
if ask_prompt "Set SELinux to PERMISSIVE mode?"; then
    echo -e "${GREEN}Set SELINUX from ENFORCING to PERMISSIVE using [setenforce 0] command:${NC}"
    sudo setenforce '0'
else
    echo -e "${RED}Skipped setting SELinux to Permissive.${NC}"
fi
echo ""
#

# FOR THOSE WHO WANT TO PERMANENTLY DISABLE SELINUX as it rather annoys than helps:
# echo -e "${CYAN}Disabling annoying SELINUX ...${NC}"
# sudo sed -i "s/^SELINUX=.*/SELINUX=disabled/" "/etc/selinux/config"
# sudo grubby --update-kernel ALL --args selinux=0
# echo -e "${GREEN}DONE${NC}"
# echo ""
#

# Autoremove orphaned and unused packages:
if ask_prompt "Autoremove orphaned/unused packages (dnf autoremove)?"; then
    echo -e "${GREEN}Removing orphaned and unused packages...${NC}"
    sudo dnf -y autoremove
else
    echo -e "${RED}Skipped DNF autoremove.${NC}"
fi
echo ""
#

# Refreshing & Upgrading the system once again:
if ask_prompt "Refresh and Upgrade the system one final time?"; then
    echo -e "${GREEN}Refreshing & Upgrading the system once again ...${NC}"
    sudo dnf -y upgrade --refresh
else
    echo -e "${RED}Skipped final system upgrade.${NC}"
fi
echo ""
#

# Update available firmware for your current hardware - if there is any; only for UEFI:
if ask_prompt "Check and update hardware firmware via fwupdmgr (UEFI only)?"; then
    echo -e "${GREEN}Update available firmware for your current hardware - if there is any; only for UEFI:${NC}"
    sudo fwupdmgr refresh --force
    sudo fwupdmgr get-remotes # Lists currently enabled repositories.
    sudo fwupdmgr get-devices # Lists devices with available updates.
    sudo fwupdmgr get-updates # Fetches list of available updates.
    sudo fwupdmgr update --force
else
    echo -e "${RED}Skipped firmware updates.${NC}"
fi
echo ""
#

# Update SMART DRIVE DATABASE:
if ask_prompt "Update SMART Drive Database (SmartDriveDB)?"; then
    echo -e "${GREEN}Updating SMART DRIVE DATABASE (SmartDriveDB) ...${NC}"
    sudo update-smart-drivedb
else
    echo -e "${RED}Skipped SMART Drive Database update.${NC}"
fi
echo ""
#

# Update P-LOCATE DATABASE:
if ask_prompt "Update P-LOCATE Database (updatedb)?"; then
    sudo updatedb
    echo -e "${GREEN}Updated P-LOCATE DATABASE [updatedb] ...${NC}"
else
    echo -e "${RED}Skipped P-LOCATE Database update.${NC}"
fi
echo ""
#

# ==============================================================================
# Add target user (HOME USER) to recommended groups
# ==============================================================================
# Determine the actual human user, even if the script is executed by 'root'
TARGET_USER="${SUDO_USER:-$USER}"

if [ "$TARGET_USER" = "root" ]; then
    echo -e "${YELLOW}Notice: Script is executing as the 'root' user.${NC}"
    echo -e -n "${YELLOW}Please enter the specific home username to add to recommended groups (or leave blank to skip): ${NC}"
    read -r input_user
    if [ -z "$input_user" ]; then
        TARGET_USER=""
    elif id "$input_user" &>/dev/null; then
        TARGET_USER="$input_user"
    else
        echo -e "${RED}Error: The user '$input_user' does not exist on this system.${NC}"
        TARGET_USER=""
    fi
fi

if [ -n "$TARGET_USER" ]; then
    if ask_prompt "Add target user ($TARGET_USER) to recommended groups (audio, games, gamemode, users, video, wheel)?"; then
        echo -e "${GREEN}Adding $TARGET_USER to recommended groups...${NC}"
        sudo usermod -a -G 'audio,games,gamemode,users,video,wheel' "$TARGET_USER"
        echo -e "${CYAN}Successfully added $TARGET_USER to groups.${NC}"
    else
        echo -e "${RED}Skipped adding $TARGET_USER to recommended groups.${NC}"
        echo -e "${YELLOW}If you wish to do it manually later, issue: [sudo usermod -a -G 'audio,games,gamemode,users,video,wheel' $TARGET_USER]${NC}"
    fi
else
    echo -e "${RED}Skipped user group configuration phase due to invalid or unspecified target user.${NC}"
fi
echo ""
#

# ==============================================================================
# PRE-REBOOT MANUAL INTERVENTION PAUSE
# ==============================================================================
# Bypassed if AUTO_ACCEPT_ALL is true to allow entirely unattended execution.
if [ "$AUTO_ACCEPT_ALL" = false ]; then
    echo -e "${CYAN}==============================================================================${NC}"
    echo -e "${CYAN}   All automated deployment tasks have concluded.                             ${NC}"
    echo -e "${YELLOW}   If you need to execute any manual commands in another terminal tab,        ${NC}"
    echo -e "${YELLOW}   please do so now before proceeding to the final system reboot phase.       ${NC}"
    echo -e "${CYAN}==============================================================================${NC}"
    echo -e -n "${YELLOW}Press [Enter] when you are ready to proceed... ${NC}"
    read -r _dummy
    echo ""
fi
#

# ==============================================================================
# FINAL REBOOT SEQUENCE
# ==============================================================================
if [ "$AUTO_ACCEPT_ALL" = true ]; then
    # Unattended Mode: Visual 20-second abortable countdown
    echo -e "${CYAN}==============================================================================${NC}"
    echo -e "${YELLOW}   All automated deployment tasks have concluded.${NC}"
    echo -e "${CYAN}==============================================================================${NC}"

    reboot_cancelled=false
    for i in {20..1}; do
        # \r returns carriage to the beginning of the line. \033[K clears to the end of the line.
        echo -e -n "\r\033[K${CYAN}Rebooting the system in ${YELLOW}${i}${CYAN} seconds... Press '${RED}N${CYAN}' to cancel, or [Enter] to reboot now: ${NC}"

        # -t 1 enforces a 1-second timeout per loop iteration. -n 1 captures a single keystroke instantly.
        if read -r -t 1 -n 1 user_input; then
            if [[ "$user_input" == [Nn] ]]; then
                reboot_cancelled=true
                break
            else
                # If the user presses [Enter] or any other key, abort the countdown and reboot immediately
                break
            fi
        fi
    done

    echo "" # Drop to a clean new line after the loop breaks or concludes

    if [ "$reboot_cancelled" = true ]; then
        echo -e "${YELLOW}Reboot cancelled by user. Please remember to reboot later to apply all changes.${NC}"
    else
        echo -e "${GREEN}Rebooting the system...${NC}"
        sudo reboot
    fi

else
    # Interactive Step-By-Step Mode: Standard Y/N Prompt
    if ask_prompt "Would you like to reboot your operating system right now?"; then
        echo -e "${GREEN}Rebooting the system...${NC}"
        sudo reboot
    else
        echo ""
        echo -e "${YELLOW}Reboot postponed. Please remember to reboot later to apply all changes.${NC}"
    fi
fi
#

#EOF
echo ""
echo -e "${CYAN}EOF${NC}"
echo ""
#
