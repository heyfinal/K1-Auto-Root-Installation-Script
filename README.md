# K1 Auto-Root Installation Script

![K1 Auto-Root Banner](https://github.com/heyfinal/k1_full_auto_root_install/raw/main/banner.png)

An automated solution for rooting Creality K1 series printers and integrating them with Bambu Studio, complete with epic background music.

## 🚀 One-Command Installation

Copy and paste this single command in your terminal to automatically download and run the script:

```bash
curl -sSL https://raw.githubusercontent.com/heyfinal/k1_full_auto_root_install/main/k1-auto-root.sh | bash
```

That's it! The script will download, run automatically, and guide you through the process with minimal input required.

## 📋 Features

- **Automatic printer discovery** on your local network
- **Epic background music** while rooting (F-Zero or Top Gun themes)
- **One-click installation** of essential components:
  - Moonraker and Nginx
  - Fluidd and/or Mainsail web interfaces
  - Klipper extensions and plugins
  - Input Shaper fixes
  - KAMP (Adaptive Meshing)
  - Remote access (optional)
- **Seamless integration** with Bambu Studio
- **Minimal user input required**

## 📋 Prerequisites

- Linux, macOS, or Windows with WSL/Git Bash
- Network connection to your K1 printer
- Printer must be turned on and connected to your network

## 🔧 Manual Installation (Alternative)

If you prefer to examine the script before running it, you can use these steps instead:

1. Download the script:
   ```bash
   wget https://raw.githubusercontent.com/heyfinal/k1_full_auto_root_install/main/k1-auto-root.sh
   ```

2. Make it executable:
   ```bash
   chmod +x k1-auto-root.sh
   ```

3. Run the script:
   ```bash
   ./k1-auto-root.sh
   ```

## 🎮 How It Works

1. **Network Scanning**:
   - Automatically scans your local network to find K1 printers
   - Identifies your printer by its unique signature
   - No need to manually enter IP addresses

2. **Installation**:
   - Connects to your printer via SSH
   - Installs the Creality Helper Script
   - Configures all components based on your preferences
   - Sets up integration with Bambu Studio

3. **Post-Installation**:
   - Provides access URLs for your new web interfaces
   - Guides you through the next steps for Bambu Studio integration

## 🔒 Security Note

This script uses the default root password for K1 printers (`creality_2023`). If you've changed your password, the script will prompt you to enter it.

## 🎵 Music Options

The script includes three epic background tracks:
- **F-Zero - Mute City**: Classic Nintendo racing theme
- **F-Zero - Big Blue**: Energetic racing track from the SNES era
- **Top Gun Anthem**: The iconic 80s movie theme

## ⚙️ Configuration Options

During installation, you'll be prompted to choose:
- Which web interface to install (Fluidd/Mainsail/Both)
- Whether to install remote access (OctoEverywhere/Obico/None)
- Which background music to play

All other options are preconfigured for optimal performance.

## 🔄 After Installation

1. Restart your printer
2. Access your new interface at:
   - Fluidd: `http://[your-printer-IP]:4408`
   - Mainsail: `http://[your-printer-IP]:4409`
3. Download and install Bambu Studio from: [Bambu Studio Releases](https://github.com/bambulab/BambuStudio/releases)

## ❓ Troubleshooting

- **Printer Not Found**: Ensure your printer is powered on and connected to the network
- **SSH Connection Failed**: Verify that SSH is enabled on your printer through the touchscreen settings
- **Music Not Playing**: Install TiMidity++ manually or try without music

## 🙏 Credits

- **Created by**: [heyfinal](https://github.com/heyfinal)
- **Scripted with assistance from**: Claude (Anthropic)
- **Based on Creality Helper Script by**: [Guilouz](https://github.com/Guilouz)

## ⚠️ Warning

Rooting your printer may void your warranty. Proceed at your own risk!

## 📜 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🌟 Star the Repository

If this script helped you, please consider giving it a star on GitHub:
[https://github.com/heyfinal/k1_full_auto_root_install](https://github.com/heyfinal/k1_full_auto_root_install)

## Installation


