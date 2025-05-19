#!/bin/bash

# K1 Auto-Root Installation Script
# Credits:
# - Created by: heyfinal
# - Scripted with assistance from: Claude (Anthropic)
# - Based on Creality Helper Script by: Guilouz (https://github.com/Guilouz/Creality-Helper-Script)
#
# Description:
# This script automates the process of rooting your Creality K1/K1C/K1 Max 3D printer
# and installing essential Klipper components for fluid integration with Bambu Studio.
# 
# Features:
# - Plays epic background music while running (F-Zero or Top Gun themes)
# - Automatic installation with minimal user input
# - Comprehensive setup for Bambu Studio integration

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Music options
MUTE_CITY_MIDI="https://www.vgmusic.com/music/console/nintendo/snes/Mute_City_(Better).mid"
BIG_BLUE_MIDI="https://www.vgmusic.com/music/console/nintendo/snes/F-Zero_-_Big_Blue.mid"
TOP_GUN_MIDI="https://bitmidi.com/uploads/73426.mid"

# Function to check and install required dependencies
check_dependencies() {
    echo -e "${YELLOW}Checking for required dependencies...${NC}"
    
    # Check for sshpass
    if ! command -v sshpass &> /dev/null; then
        echo -e "${RED}Error: sshpass is not installed.${NC}"
        echo -e "Please install sshpass to continue:"
        echo -e "  - ${YELLOW}Ubuntu/Debian:${NC} sudo apt-get install sshpass"
        echo -e "  - ${YELLOW}Mac (Homebrew):${NC} brew install hudochenkov/sshpass/sshpass"
        echo -e "  - ${YELLOW}Windows:${NC} Use Git Bash or WSL and install sshpass"
        exit 1
    fi
    
    # Check for timidity (MIDI player)
    if ! command -v timidity &> /dev/null; then
        echo -e "${YELLOW}TiMidity++ (MIDI player) is not installed.${NC}"
        echo -e "Would you like to install it to enable background music? (y/n)"
        read install_timidity
        if [[ "$install_timidity" =~ ^[Yy]$ ]]; then
            if [[ "$OSTYPE" == "linux-gnu"* ]]; then
                sudo apt-get update && sudo apt-get install -y timidity
            elif [[ "$OSTYPE" == "darwin"* ]]; then
                brew install timidity
            else
                echo -e "${RED}Unable to automatically install TiMidity++.${NC}"
                echo -e "${YELLOW}Please install it manually if you want background music.${NC}"
                PLAY_MUSIC=false
            fi
        else
            PLAY_MUSIC=false
        fi
    fi
    
    echo -e "${GREEN}Dependency check completed.${NC}"
}

# Function to play background music
play_music() {
    local midi_url=$1
    local midi_file=$(basename "$midi_url")
    
    if [ "$PLAY_MUSIC" = true ] && command -v timidity &> /dev/null; then
        echo -e "${BLUE}Downloading background music...${NC}"
        if ! curl -s -o "/tmp/$midi_file" "$midi_url"; then
            echo -e "${RED}Failed to download MIDI file.${NC}"
            return 1
        fi
        
        echo -e "${GREEN}Starting background music...${NC}"
        timidity "/tmp/$midi_file" -Os -iA &
        MUSIC_PID=$!
        
        # Register cleanup function to stop music when script ends
        trap stop_music EXIT INT TERM
    fi
}

# Function to stop background music
stop_music() {
    if [ -n "$MUSIC_PID" ]; then
        echo -e "${YELLOW}Stopping background music...${NC}"
        kill $MUSIC_PID 2>/dev/null || true
    fi
}

# Display banner
echo -e "${BLUE}"
echo "██╗  ██╗ ██╗     █████╗ ██╗   ██╗████████╗ ██████╗       ██████╗  ██████╗  ██████╗ ████████╗"
echo "██║ ██╔╝███║    ██╔══██╗██║   ██║╚══██╔══╝██╔═══██╗      ██╔══██╗██╔═══██╗██╔═══██╗╚══██╔══╝"
echo "█████╔╝  ╚██║    ███████║██║   ██║   ██║   ██║   ██║█████╗██████╔╝██║   ██║██║   ██║   ██║   "
echo "██╔═██╗   ██║    ██╔══██║██║   ██║   ██║   ██║   ██║╚════╝██╔══██╗██║   ██║██║   ██║   ██║   "
echo "██║  ██╗  ██║    ██║  ██║╚██████╔╝   ██║   ╚██████╔╝      ██║  ██║╚██████╔╝╚██████╔╝   ██║   "
echo "╚═╝  ╚═╝  ╚═╝    ╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝       ╚═╝  ╚═╝ ╚═════╝  ╚═════╝    ╚═╝   "
echo -e "${NC}"
echo -e "Automated installation script for Creality K1 Series Printers"
echo -e "Created by ${GREEN}heyfinal${NC} with assistance from ${CYAN}Claude${NC}"
echo -e "Based on Creality Helper Script by ${MAGENTA}Guilouz${NC}"
echo -e "${YELLOW}----------------------------------------------------------------------${NC}"
echo ""

# Check for required dependencies
check_dependencies

# Check for sshpass installation
if ! command -v sshpass &> /dev/null; then
    echo -e "${RED}Error: sshpass is not installed.${NC}"
    echo -e "Please install sshpass to continue:"
    echo -e "  - ${YELLOW}Ubuntu/Debian:${NC} sudo apt-get install sshpass"
    echo -e "  - ${YELLOW}Mac (Homebrew):${NC} brew install hudochenkov/sshpass/sshpass"
    echo -e "  - ${YELLOW}Windows:${NC} Use Git Bash or WSL and install sshpass"
    exit 1
fi

# Default values
DEFAULT_PASSWORD="creality_2023"
DEFAULT_REMOTE_ACCESS="octoeverywhere"
USB_DEVICE=""
INSTALL_FLUIDD=true
INSTALL_MAINSAIL=false
INSTALL_KAMP=true
INSTALL_INPUT_SHAPER=true
INSTALL_ENTWARE=true
INSTALL_KLIPPER_SHELL=true
INSTALL_TIMELAPSE=true
INSTALL_BUZZER=false
INSTALL_REMOTE_ACCESS=false
REMOTE_ACCESS_CHOICE=""
PLAY_MUSIC=true

# User input function with validation
function get_valid_input() {
    local prompt="$1"
    local validation_regex="$2"
    local default_value="$3"
    local error_message="$4"
    local input=""
    
    while true; do
        if [ -z "$default_value" ]; then
            echo -ne "${prompt}: "
        else
            echo -ne "${prompt} [${default_value}]: "
        fi
        
        read input
        
        # Use default if provided and input is empty
        if [ -z "$input" ] && [ -n "$default_value" ]; then
            input="$default_value"
        fi
        
        # Validate input
        if [[ "$input" =~ $validation_regex ]]; then
            echo "$input"
            return 0
        else
            echo -e "${RED}${error_message}${NC}"
        fi
    done
}

# Welcome message and information
echo -e "${YELLOW}This script will automate the process of rooting your Creality K1 printer${NC}"
echo -e "${YELLOW}and installing components for integrating with Bambu Studio.${NC}"
echo -e "${RED}WARNING: Rooting your printer will void your warranty.${NC}"
echo -e "${RED}Proceed at your own risk!${NC}"
echo ""
echo -e "Press ${GREEN}ENTER${NC} to continue or ${RED}CTRL+C${NC} to abort..."
read

# Choose background music
if [ "$PLAY_MUSIC" = true ]; then
    echo -e "${CYAN}Choose background music to play during installation:${NC}"
    echo -e "1) ${GREEN}F-Zero - Mute City${NC} (Classic racing theme)"
    echo -e "2) ${YELLOW}F-Zero - Big Blue${NC} (Energetic racing theme)"
    echo -e "3) ${MAGENTA}Top Gun Anthem${NC} (Epic 80s theme)"
    echo -e "4) ${RED}No music${NC}"
    echo -ne "Enter your choice [1]: "
    read MUSIC_CHOICE
    echo ""
    
    case "$MUSIC_CHOICE" in
        2)
            MIDI_URL="$BIG_BLUE_MIDI"
            echo -e "You selected: ${YELLOW}F-Zero - Big Blue${NC}"
            ;;
        3)
            MIDI_URL="$TOP_GUN_MIDI"
            echo -e "You selected: ${MAGENTA}Top Gun Anthem${NC}"
            ;;
        4)
            PLAY_MUSIC=false
            echo -e "You selected: ${RED}No music${NC}"
            ;;
        *)
            MIDI_URL="$MUTE_CITY_MIDI"
            echo -e "You selected: ${GREEN}F-Zero - Mute City${NC} (default)"
            ;;
    esac
    
    # Start playing the selected music
    if [ "$PLAY_MUSIC" = true ]; then
        play_music "$MIDI_URL"
    fi
fi

# Get printer IP address
IP_REGEX='^([0-9]{1,3}\.){3}[0-9]{1,3}$'
PRINTER_IP=$(get_valid_input "Enter your printer's IP address" "$IP_REGEX" "" "Invalid IP address format")

# Get SSH password
echo -ne "Enter SSH password [${DEFAULT_PASSWORD}]: "
read -s SSH_PASSWORD
echo ""
if [ -z "$SSH_PASSWORD" ]; then
    SSH_PASSWORD="$DEFAULT_PASSWORD"
fi

# Confirm connectivity
echo -e "${YELLOW}Testing connection to the printer...${NC}"
if ! sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$PRINTER_IP "echo Connected successfully"; then
    echo -e "${RED}Failed to connect to the printer. Please check your IP address and password.${NC}"
    exit 1
fi
echo -e "${GREEN}Connection successful!${NC}"

# Configuration options
echo ""
echo -e "${BLUE}=== Configuration Options ===${NC}"

# Choose web interface
echo -e "${CYAN}Which web interface would you like to install?${NC}"
echo -e "1) ${GREEN}Fluidd${NC} (Recommended)"
echo -e "2) ${YELLOW}Mainsail${NC}"
echo -e "3) ${MAGENTA}Both${NC}"
echo -ne "Enter your choice [1]: "
read INTERFACE_CHOICE
echo ""

case "$INTERFACE_CHOICE" in
    2)
        INSTALL_FLUIDD=false
        INSTALL_MAINSAIL=true
        echo -e "You selected: ${YELLOW}Mainsail${NC}"
        ;;
    3)
        INSTALL_FLUIDD=true
        INSTALL_MAINSAIL=true
        echo -e "You selected: ${MAGENTA}Both Fluidd and Mainsail${NC}"
        ;;
    *)
        INSTALL_FLUIDD=true
        INSTALL_MAINSAIL=false
        echo -e "You selected: ${GREEN}Fluidd${NC} (default)"
        ;;
esac

# Remote access option
echo ""
echo -e "${CYAN}Would you like to install remote access?${NC}"
echo -e "1) ${GREEN}OctoEverywhere${NC} (Recommended)"
echo -e "2) ${YELLOW}Obico${NC}"
echo -e "3) ${RED}None${NC}"
echo -ne "Enter your choice [1]: "
read REMOTE_CHOICE
echo ""

case "$REMOTE_CHOICE" in
    1)
        INSTALL_REMOTE_ACCESS=true
        REMOTE_ACCESS_CHOICE="octoeverywhere"
        echo -e "You selected: ${GREEN}OctoEverywhere${NC}"
        ;;
    2)
        INSTALL_REMOTE_ACCESS=true
        REMOTE_ACCESS_CHOICE="obico"
        echo -e "You selected: ${YELLOW}Obico${NC}"
        ;;
    3)
        INSTALL_REMOTE_ACCESS=false
        echo -e "You selected: ${RED}No remote access${NC}"
        ;;
    *)
        INSTALL_REMOTE_ACCESS=true
        REMOTE_ACCESS_CHOICE="octoeverywhere"
        echo -e "You selected: ${GREEN}OctoEverywhere${NC} (default)"
        ;;
esac

# Optional: USB device if needed
echo ""
echo -e "${CYAN}Do you need to specify a USB storage device? (Only needed for special cases)${NC}"
echo -e "Enter the device name or leave blank if not needed: "
read USB_DEVICE

# Installation confirmation
echo ""
echo -e "${YELLOW}======= Installation Summary =======${NC}"
echo -e "Printer IP: ${CYAN}$PRINTER_IP${NC}"
if [ "$INSTALL_FLUIDD" = true ] && [ "$INSTALL_MAINSAIL" = true ]; then
    echo -e "Web Interface: ${MAGENTA}Fluidd and Mainsail${NC}"
elif [ "$INSTALL_FLUIDD" = true ]; then
    echo -e "Web Interface: ${GREEN}Fluidd${NC}"
else
    echo -e "Web Interface: ${YELLOW}Mainsail${NC}"
fi

if [ "$INSTALL_REMOTE_ACCESS" = true ]; then
    echo -e "Remote Access: ${GREEN}$REMOTE_ACCESS_CHOICE${NC}"
else
    echo -e "Remote Access: ${RED}None${NC}"
fi

if [ -n "$USB_DEVICE" ]; then
    echo -e "USB Device: ${CYAN}$USB_DEVICE${NC}"
else
    echo -e "USB Device: ${YELLOW}Not specified${NC}"
fi

echo -e "${YELLOW}=================================${NC}"
echo ""
echo -e "The script will now install the Helper Script and configure your printer."
echo -e "This process may take 10-15 minutes. Please do not turn off your printer or close this window."
echo -e "Press ${GREEN}ENTER${NC} to start installation or ${RED}CTRL+C${NC} to abort..."
read

# Installation process
echo ""
echo -e "${BLUE}=== Starting Installation ===${NC}"

# Connect to the printer and run installation

# Function to create the remote installation script
create_remote_script() {
    cat > install_remote.sh << 'EOL'
#!/bin/sh

# Remote installation script
echo "=== Starting K1 Auto-Root Installation ==="
echo "Setting up prerequisites..."

# Update package list and install git
cd /root

# Clone the Helper Script
echo "Downloading Helper Script..."
rm -rf /usr/data/helper-script
git config --global http.sslVerify false
git clone --depth 1 https://github.com/Guilouz/Creality-Helper-Script.git /usr/data/helper-script

# Make sure we have execution permissions
chmod +x /usr/data/helper-script/helper.sh

# Create automation script
echo "Creating automation script..."
cat > /tmp/auto_install.expect << 'EOF'
#!/usr/bin/expect -f
set timeout -1

# Start the helper script
spawn sh /usr/data/helper-script/helper.sh

# Main menu - select Installation menu (1)
expect "Please select your choice:"
send "1\r"

# Install Moonraker and NGINX
expect "Please select your choice:"
send "1\r"
expect "Type anything to continue:"
send "\r"

EOF

# Add conditional installation for Entware
if [ "$INSTALL_ENTWARE" = "true" ]; then
cat >> /tmp/auto_install.expect << 'EOF'
# Install Entware
expect "Please select your choice:"
send "4\r"
expect "Type anything to continue:"
send "\r"

EOF
fi

# Add conditional installation for Fluidd
if [ "$INSTALL_FLUIDD" = "true" ]; then
cat >> /tmp/auto_install.expect << 'EOF'
# Install Fluidd
expect "Please select your choice:"
send "2\r"
expect "Type anything to continue:"
send "\r"

EOF
fi

# Add conditional installation for Mainsail
if [ "$INSTALL_MAINSAIL" = "true" ]; then
cat >> /tmp/auto_install.expect << 'EOF'
# Install Mainsail
expect "Please select your choice:"
send "3\r"
expect "Type anything to continue:"
send "\r"

EOF
fi

# Add conditional installation for KAMP
if [ "$INSTALL_KAMP" = "true" ]; then
cat >> /tmp/auto_install.expect << 'EOF'
# Install KAMP
expect "Please select your choice:"
send "8\r"
expect "Type anything to continue:"
send "\r"

EOF
fi

# Add conditional installation for Klipper Shell Command
if [ "$INSTALL_KLIPPER_SHELL" = "true" ]; then
cat >> /tmp/auto_install.expect << 'EOF'
# Install Klipper Shell Command
expect "Please select your choice:"
send "9\r"
expect "Type anything to continue:"
send "\r"

EOF
fi

# Add conditional installation for Input Shaper Fix
if [ "$INSTALL_INPUT_SHAPER" = "true" ]; then
cat >> /tmp/auto_install.expect << 'EOF'
# Go back to main menu
expect "Please select your choice:"
send "b\r"

# Go to Improvements menu
expect "Please select your choice:"
send "3\r"

# Install Input Shaper Fix
expect "Please select your choice:"
send "1\r"
expect "Type anything to continue:"
send "\r"

EOF
fi

# Add conditional installation for Timelapse
if [ "$INSTALL_TIMELAPSE" = "true" ]; then
cat >> /tmp/auto_install.expect << 'EOF'
# Install Timelapse
expect "Please select your choice:"
send "5\r"
expect "Type anything to continue:"
send "\r"

EOF
fi

# Add conditional installation for Buzzer support
if [ "$INSTALL_BUZZER" = "true" ]; then
cat >> /tmp/auto_install.expect << 'EOF'
# Install Buzzer support
expect "Please select your choice:"
send "6\r"
expect "Type anything to continue:"
send "\r"

EOF
fi

# Install OctoEverywhere if selected
if [ "$INSTALL_REMOTE_ACCESS" = "true" ] && [ "$REMOTE_ACCESS_CHOICE" = "octoeverywhere" ]; then
cat >> /tmp/auto_install.expect << 'EOF'
# Go back to main menu
expect "Please select your choice:"
send "b\r"

# Go to Installation menu
expect "Please select your choice:"
send "1\r"

# Install OctoEverywhere
expect "Please select your choice:"
send "6\r"
expect "Type anything to continue:"
send "\r"

EOF
fi

# Install Obico if selected
if [ "$INSTALL_REMOTE_ACCESS" = "true" ] && [ "$REMOTE_ACCESS_CHOICE" = "obico" ]; then
cat >> /tmp/auto_install.expect << 'EOF'
# Go back to main menu
expect "Please select your choice:"
send "b\r"

# Go to Installation menu
expect "Please select your choice:"
send "1\r"

# Install Obico
expect "Please select your choice:"
send "7\r"
expect "Type anything to continue:"
send "\r"

EOF
fi

# Exit the installation
cat >> /tmp/auto_install.expect << 'EOF'
# Back to main menu one final time
expect "Please select your choice:"
send "b\r"

# Exit
expect "Please select your choice:"
send "e\r"

expect eof
EOF

# Make the expect script executable
chmod +x /tmp/auto_install.expect

# Check if expect is available
if ! command -v expect &> /dev/null; then
    echo "Installing expect..."
    if command -v opkg &> /dev/null; then
        opkg update
        opkg install expect
    else
        echo "Cannot install expect. Please install Entware first."
        exit 1
    fi
fi

# Run the automated installation
echo "Running automated installation..."
/tmp/auto_install.expect

# Clean up
rm -f /tmp/auto_install.expect

echo "Installation completed successfully!"

# Get the printer's interfaces to display to the user
PRINTER_IP=$(ip route get 1 | awk '{print $7;exit}')
echo ""
echo "==== INSTALLATION COMPLETED ===="
echo "Your printer has been successfully rooted and configured!"
echo ""
echo "Access your printer using:"
if [ "$INSTALL_FLUIDD" = "true" ]; then
    echo "Fluidd: http://$PRINTER_IP:4408"
fi
if [ "$INSTALL_MAINSAIL" = "true" ]; then
    echo "Mainsail: http://$PRINTER_IP:4409"
fi
echo ""
echo "Please restart your printer for all changes to take effect."
echo "=== Thank you for using K1 Auto-Root Installation Script ==="
EOL

    # Replace placeholders with actual values
    sed -i "s/\$INSTALL_ENTWARE/$INSTALL_ENTWARE/g" install_remote.sh
    sed -i "s/\$INSTALL_FLUIDD/$INSTALL_FLUIDD/g" install_remote.sh
    sed -i "s/\$INSTALL_MAINSAIL/$INSTALL_MAINSAIL/g" install_remote.sh
    sed -i "s/\$INSTALL_KAMP/$INSTALL_KAMP/g" install_remote.sh
    sed -i "s/\$INSTALL_KLIPPER_SHELL/$INSTALL_KLIPPER_SHELL/g" install_remote.sh
    sed -i "s/\$INSTALL_INPUT_SHAPER/$INSTALL_INPUT_SHAPER/g" install_remote.sh
    sed -i "s/\$INSTALL_TIMELAPSE/$INSTALL_TIMELAPSE/g" install_remote.sh
    sed -i "s/\$INSTALL_BUZZER/$INSTALL_BUZZER/g" install_remote.sh
    sed -i "s/\$INSTALL_REMOTE_ACCESS/$INSTALL_REMOTE_ACCESS/g" install_remote.sh
    sed -i "s/\$REMOTE_ACCESS_CHOICE/$REMOTE_ACCESS_CHOICE/g" install_remote.sh
}

# Create the remote installation script
create_remote_script

# Copy the script to the printer
echo -e "${YELLOW}Copying installation script to the printer...${NC}"
sshpass -p "$SSH_PASSWORD" scp -o StrictHostKeyChecking=no install_remote.sh root@$PRINTER_IP:/tmp/

# Make the script executable and run it
echo -e "${YELLOW}Making the script executable...${NC}"
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$PRINTER_IP "chmod +x /tmp/install_remote.sh"

echo -e "${GREEN}Starting the installation on the printer...${NC}"
echo -e "${YELLOW}This may take 10-15 minutes. Please be patient...${NC}"
sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no root@$PRINTER_IP "/tmp/install_remote.sh"

# Clean up
rm -f install_remote.sh

# Stop background music if it's playing
stop_music

echo ""
echo -e "${GREEN}===========================================${NC}"
echo -e "${GREEN}       Installation Complete!              ${NC}"
echo -e "${GREEN}===========================================${NC}"
echo ""
echo -e "Your Creality K1 printer has been successfully rooted and configured!"
echo -e "You can now access your printer using:"
if [ "$INSTALL_FLUIDD" = true ]; then
    echo -e "- ${CYAN}Fluidd:${NC} http://$PRINTER_IP:4408"
fi
if [ "$INSTALL_MAINSAIL" = true ]; then
    echo -e "- ${CYAN}Mainsail:${NC} http://$PRINTER_IP:4409"
fi
echo ""
echo -e "${YELLOW}Please restart your printer for all changes to take effect.${NC}"
echo -e "${YELLOW}After restarting, allow 1-2 minutes for all services to start.${NC}"
echo ""
echo -e "${BLUE}To integrate with Bambu Studio:${NC}"
echo -e "1. Download and install Bambu Studio from: ${CYAN}https://github.com/bambulab/BambuStudio/releases${NC}"
echo -e "2. In Bambu Studio, go to Settings > Printer Settings"
echo -e "3. Add your K1 printer and configure it to communicate through Fluidd/Mainsail"
echo ""
echo -e "${MAGENTA}Thank you for using the K1 Auto-Root Installation Script!${NC}"
echo -e "${GREEN}Created by:${NC} heyfinal"
echo -e "${GREEN}Scripted with assistance from:${NC} Claude (Anthropic)"
echo -e "${GREEN}Based on Creality Helper Script by:${NC} Guilouz"

exit 0
