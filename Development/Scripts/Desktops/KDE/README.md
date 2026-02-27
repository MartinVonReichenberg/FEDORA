# **🚀 Fedora KDE Plasma — Advanced Comprehensive Convenient Semi-Automatic ALL-IN-ONE Post-Installation Script**
___
### **Welcome to my FEDORA KDE ALL-IN-ONE Semi-Automatic Bash Script!**
___

A robust, comprehensive, and highly interactive Bash provisioning script designed specifically for **Fedora KDE Plasma** (Versions 42, 43, 44, and Rawhide).

This script transforms a fresh Fedora installation into a fully optimized, codec-rich, gaming-ready, and developer-friendly workstation. It intelligently handles repository management, architecture-specific multimedia codecs, software deployment (RPMs and Flatpaks), networking configurations, and system maintenance in a single, streamlined execution.


## **✨ Key Features**
___
### **🛠 Dual Deployment Modes**

* **Auto-Accept All (Unattended Mode):** Press `[A]` at the master prompt to authorize the entire payload. The script will deploy everything automatically and initiate a visual 20-second abortable safe-reboot countdown upon completion.  
* **Step-by-Step (Interactive Mode):** Press `[N]` at the master prompt to evaluate and manually confirm/deny (`[Y/n]`) every individual software category and system tweak.


### **🛡 Intelligent Execution & Failsafes**

* **Target User Validation (Root vs. Sudo):** Whether executed via standard `sudo [./script.sh]` or directly within a pure root shell (`su -`), the script intelligently traces the intended human user. It explicitly prevents the erroneous assignment of standard unprivileged groups (`audio`, `video`, `vboxusers`) to the system root account.  
* **VPN Topology Safety Override:** Bypasses the "Auto-Accept All" master rule specifically for VPN deployment. It strictly pauses to force a mutually exclusive choice between NetBird, Tailscale, ZeroTier, or ALL, preventing automated routing table collisions and virtual network daemon bloat.  
* **Architectural Codec Resolution:** Flawlessly resolves modern 64-bit (`x86_64`) vs. legacy 32-bit (`i686`) DNF dependency conflicts. It successfully provisions legacy 32-bit WINE/Proton GStreamer libraries without triggering dummy `noopenh264` stub conflicts against Cisco's modern 64-bit OpenH264 implementation.  
* **Context-Aware Repository Syncing:** The DNF-to-Zypper repository synchronization (`/etc/zypp/repos.d/`) tracks script execution state and will safely skip itself if the required Zypper CLI tool was not installed in earlier prompts.


### **📦 Comprehensive Provisioning**

* **Package Managers:** Optimizes DNF (`best=False`; `defaultyes=true` and `max_parallel_downloads=10`) and provides optional Zypper integration.  
* **Repositories:** RPM Fusion (Free/Non-Free), Terra, WINE HQ, FlatHub, Opera, Vivaldi, and targeted Open Build Service (OBS) repositories (including custom HOME repositories).  
* **Hardware Acceleration:** Swaps Mesa drivers to full freeworld variants for AMD/Intel and installs essential libva VDPAU drivers for Nvidia architectures.  
* **Virtualization & Kernel Sync:** Installs kernel-devel-matched to lock headers to your current running kernel, installs VirtualBox, automatically compiles host modules (akmods), restarts the vboxdrv daemon, and handles correct user group injection.  
* **Shell Enhancements:** Injects custom functions (sufido, backward-kill-subword) directly into the Fish shell ecosystem.


## **📋 Prerequisites**
___
Before executing this script, ensure you have:

1. **Fedora Linux** (42, 43, 44, or Rawhide) with the **KDE Plasma** Desktop Environment.  
2. An active internet connection.  
3. Administrative (sudo or root) privileges.


## **🚀 Installation & Usage**
___
1. **Clone the repository:**  
   ```
   git clone 'https://github.com/MartinVonReichenberg/FEDORA.git' 
   cd './FEDORA/Development/Scripts/Desktops/KDE/'
   ```

2. **Make the script executable:**  
   ```
   chmod -v +x './FEDORA-KDE-DESKTOP--Post_Installation_Script.sh'
   ```

3. **Execute the script:**  
   ```
   './FEDORA-KDE-DESKTOP--Post_Installation_Script.sh'
   ```

4. **Follow the Prompts:**  
   * **Version Definition:** Type your Fedora version (e.g., 42, 43, 44, or Rawhide).  
   * **Execution Mode:** Choose between Auto-Accept All (A) or Interactive Step-by-Step (Y/N).  
   * **VPN Exception:** When prompted midway, select your specific VPN overlay (N for NetBird, T for Tailscale, Z for ZeroTier, A for ALL, or simply hit `[Enter]` to skip).


## **🧰 Software Payload Categories**
___
If you choose the step-by-step interactive mode, you will be prompted to install the following categorized arrays:

* **Development & Build Tools:** OBS packaging tools (osc, obs-build), Language Servers (Bash, RPM Spec), GitHub CLI, kernel-devel, and kernel-devel-matched.  
* **Gaming & Controller Utilities:** Steam, Dualsensectl, DXVK (Native), EGL-Wayland.  
* **KDE Desktop Utilities & Science:** Kate, Kleopatra, Koi, Stellarium.  
* **Multimedia Codecs & Media Players:** VLC, comprehensive GStreamer1 suites (32-bit/64-bit), x264/x265, full FFmpeg swap.  
* **System Fonts & CJK Support:** Google Noto (CJK/Emoji), Hack Nerd Fonts, RSMS Inter, Liberation.  
* **Dedicated VPN Tools:** NetBird (Upstream URL), Tailscale (Official Fedora Repo), ZeroTier-One (Custom OBS Repo).  
* **Network & Internet Tools:** Web Browsers (Chrome, Opera, Vivaldi), Messaging (Telegram, Discord), Torrenting (qBittorrent), Winbox (MikroTik management).  
* **System Utilities & CLI Tools:** Htop, Btop, Fish, Zypper, Bat, Micro, xclip.  
* **Direct 3rd-Party RPMs:** Bitwarden Desktop, Proton Mail Beta, Proton Pass, Proton Authenticator, Balena Etcher.  
* **Flatpak Applications:** YouTube Music Desktop, ZapZap (WhatsApp), Termius SSH, ProtonUp-Qt.


## **🧹 Maintenance & Finalization Phase**
___
At the conclusion of the software deployment, the script automatically transitions into a system maintenance phase:

1. **Firewalld & SELinux Configuration:** Safely disables the default Firewalld SystemD service and sets SELinux to Permissive mode to prevent arbitrary permission blocking on complex setups.  
2. **DNF Autoremove:** Purges orphaned dependencies and unused packages from the deployment process.  
3. **Final System Refresh:** Executes a final `dnf upgrade --refresh` on the newly cleaned dependency tree.  
4. **Firmware Updates:** Executes a full fwupdmgr refresh and update for UEFI-supported hardware.  
5. **Database Syncing:** Updates SmartDriveDB and updatedb (plocate).  
6. **User Group Injection:** Validates the human user and appends required groups (audio, games, gamemode, users, video, wheel).  
7. **Graceful Reboot:** Initiates a dynamic 20-second abortable countdown (in unattended mode) to allow manual interruption before restarting the system to apply kernel and group changes.


## **⚖️ Disclaimer & License**
___
Feel free to modify, re-edit, share, redistribute and provide feedback to this Bash script according to your needs and/or wishes.

This script is not subjected to any license or to any form of restrictions; anything is allowed . . .

*Disclaimer:*   
This script significantly alters system-level configurations, repositories, and packages. While it is rigorously structured with extensive fail-safes, user-validation checks, and conditional logic, it is provided **"as is" without warranty of any kind**.

Always ensure you understand the commands being executed, particularly regarding SELinux transitions, repository syncing, and firewall management. Review the code to ensure it meets your specific security and administrative requirements before deployment.
