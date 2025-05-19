#!/bin/bash

# UGRC - Universal GitHub Repository Creator with GitHub CLI
# Created by Claude for heyfinal
# 
# FEATURES:
# - Password protected script launch
# - Epic Top Gun theme music during execution
# - Automatically detects project files in current directory
# - Uses GitHub CLI for reliable authentication
# - Creates and populates GitHub repository
# - Generates one-liner installation command if applicable

# Text colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# MIDI music sources (with multiple fallback options)
TOP_GUN_MIDI="https://storage.googleapis.com/heyfinal-public/topgun.mid"
BACKUP_MIDI_1="https://bitmidi.com/uploads/73426.mid"
BACKUP_MIDI_2="https://www.midiworld.com/download/4167"

# Function to detect OS and install packages
auto_install_dependencies() {
    # Detect operating system
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux installation
        
        # Check for apt (Debian, Ubuntu, etc.)
        if command -v apt-get &> /dev/null; then
            echo -e "${YELLOW}Detected Debian/Ubuntu-based system. Installing dependencies...${NC}"
            sudo apt-get update
            
            # Install curl if needed
            if ! command -v curl &> /dev/null; then
                sudo apt-get install -y curl
            fi
            
            # Install GitHub CLI
            if ! command -v gh &> /dev/null; then
                echo -e "${YELLOW}Installing GitHub CLI...${NC}"
                curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
                echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
                sudo apt-get update
                sudo apt-get install -y gh
            fi
            
            # Install TiMidity++
            if ! command -v timidity &> /dev/null; then
                echo -e "${YELLOW}Installing TiMidity++...${NC}"
                sudo apt-get install -y timidity timidity-daemon
            fi
            
            # Start TiMidity daemon
            echo -e "${GREEN}Starting TiMidity daemon...${NC}"
            if command -v systemctl &> /dev/null && systemctl is-active --quiet timidity.service; then
                sudo systemctl restart timidity
            else
                timidity -iA -Os &>/dev/null &
            fi
            sleep 2
            
        # Check for dnf (Fedora, RHEL, etc.)
        elif command -v dnf &> /dev/null; then
            echo -e "${YELLOW}Detected Fedora/RHEL-based system. Installing dependencies...${NC}"
            
            # Install curl if needed
            if ! command -v curl &> /dev/null; then
                sudo dnf install -y curl
            fi
            
            # Install GitHub CLI
            if ! command -v gh &> /dev/null; then
                echo -e "${YELLOW}Installing GitHub CLI...${NC}"
                sudo dnf install -y 'dnf-command(config-manager)'
                sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
                sudo dnf install -y gh
            fi
            
            # Install TiMidity++
            if ! command -v timidity &> /dev/null; then
                echo -e "${YELLOW}Installing TiMidity++...${NC}"
                sudo dnf install -y timidity++
            fi
            
            # Start TiMidity daemon
            echo -e "${GREEN}Starting TiMidity daemon...${NC}"
            timidity -iA -Os &>/dev/null &
            sleep 2
            
        # Check for pacman (Arch Linux)
        elif command -v pacman &> /dev/null; then
            echo -e "${YELLOW}Detected Arch-based system. Installing dependencies...${NC}"
            
            # Install curl if needed
            if ! command -v curl &> /dev/null; then
                sudo pacman -Sy --noconfirm curl
            fi
            
            # Install GitHub CLI
            if ! command -v gh &> /dev/null; then
                echo -e "${YELLOW}Installing GitHub CLI...${NC}"
                sudo pacman -Sy --noconfirm github-cli
            fi
            
            # Install TiMidity++
            if ! command -v timidity &> /dev/null; then
                echo -e "${YELLOW}Installing TiMidity++...${NC}"
                sudo pacman -Sy --noconfirm timidity++
            fi
            
            # Start TiMidity daemon
            echo -e "${GREEN}Starting TiMidity daemon...${NC}"
            timidity -iA -Os &>/dev/null &
            sleep 2
            
        else
            echo -e "${RED}Unsupported Linux distribution. Please install dependencies manually:${NC}"
            echo -e "  - ${CYAN}GitHub CLI (gh): https://github.com/cli/cli#installation${NC}"
            echo -e "  - ${CYAN}TiMidity++: Use your distribution's package manager${NC}"
            exit 1
        fi
        
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS installation
        
        # Check for Homebrew
        if ! command -v brew &> /dev/null; then
            echo -e "${YELLOW}Installing Homebrew...${NC}"
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            
            # Make sure Homebrew is in PATH
            if [[ -f /opt/homebrew/bin/brew ]]; then
                eval "$(/opt/homebrew/bin/brew shellenv)"
            elif [[ -f /usr/local/bin/brew ]]; then
                eval "$(/usr/local/bin/brew shellenv)"
            else
                echo -e "${RED}Homebrew installed but not found in PATH. Please restart your terminal.${NC}"
                exit 1
            fi
        fi
        
        # Install GitHub CLI
        if ! command -v gh &> /dev/null; then
            echo -e "${YELLOW}Installing GitHub CLI...${NC}"
            brew install gh
        fi
        
        # Install TiMidity++
        if ! command -v timidity &> /dev/null; then
            echo -e "${YELLOW}Installing TiMidity++...${NC}"
            brew install timidity
        fi
        
        # Start TiMidity daemon
        echo -e "${GREEN}Starting TiMidity daemon...${NC}"
        timidity -iA -Os &>/dev/null &
        sleep 2
        
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        # Windows/Git Bash/MinGW installation
        echo -e "${RED}Windows detected. Please install dependencies manually:${NC}"
        echo -e "  - ${CYAN}GitHub CLI (gh): winget install --id GitHub.cli${NC}"
        echo -e "  - ${CYAN}TiMidity++: https://sourceforge.net/projects/timidity/${NC}"
        echo -e "${YELLOW}After installing, restart this script.${NC}"
        exit 1
    else
        echo -e "${RED}Unsupported operating system. Please install dependencies manually:${NC}"
        echo -e "  - ${CYAN}GitHub CLI (gh): https://github.com/cli/cli#installation${NC}"
        echo -e "  - ${CYAN}TiMidity++: https://timidity.sourceforge.net/${NC}"
        exit 1
    fi
}

# Function to check and install required dependencies
check_dependencies() {
    echo -e "${YELLOW}Checking for required dependencies...${NC}"
    
    # Variables to track what needs to be installed
    NEED_GH=false
    NEED_TIMIDITY=false
    
    # Check for GitHub CLI
    if ! command -v gh &> /dev/null; then
        NEED_GH=true
    fi
    
    # Check for timidity (MIDI player)
    if ! command -v timidity &> /dev/null; then
        NEED_TIMIDITY=true
    fi
    
    # Install dependencies if needed
    if [ "$NEED_GH" = true ] || [ "$NEED_TIMIDITY" = true ]; then
        echo -e "${YELLOW}Some dependencies are missing. Installing them now...${NC}"
        auto_install_dependencies
    else
        # Make sure TiMidity daemon is running
        echo -e "${GREEN}Initializing Top Gun soundtrack...${NC}"
        timidity -iA -Os &>/dev/null &
        sleep 1
    fi
    
    # Verify GitHub CLI is installed and authenticated
    if ! command -v gh &> /dev/null; then
        echo -e "${RED}GitHub CLI (gh) installation failed.${NC}"
        echo -e "${YELLOW}Please install it manually: https://github.com/cli/cli#installation${NC}"
        exit 1
    fi
    
    # Check if logged in to GitHub CLI
    if ! gh auth status &> /dev/null; then
        echo -e "${YELLOW}Authenticating with GitHub...${NC}"
        echo -e "${CYAN}A browser window will open for you to login to GitHub.${NC}"
        gh auth login --web
        
        # Verify authentication worked
        if ! gh auth status &> /dev/null; then
            echo -e "${RED}GitHub CLI authentication failed.${NC}"
            echo -e "${YELLOW}Please run 'gh auth login' manually.${NC}"
            exit 1
        fi
    fi
    
    # Set music flag
    if command -v timidity &> /dev/null; then
        PLAY_MUSIC=true
    else
        echo -e "${RED}TiMidity++ installation failed. Music will not play.${NC}"
        PLAY_MUSIC=false
    fi
    
    echo -e "${GREEN}Dependency check completed.${NC}"
}

# Function to play Top Gun theme music
play_music() {
    local midi_url=$1
    local midi_file=$(basename "$midi_url")
    
    if [ "$PLAY_MUSIC" = true ]; then
        echo -e "${BLUE}Downloading Top Gun Anthem...${NC}"
        if ! curl -s -o "/tmp/$midi_file" "$midi_url"; then
            echo -e "${RED}Failed to download MIDI file.${NC}"
            return 1
        fi
        
        # Test if MIDI file was downloaded properly
        if [ ! -s "/tmp/$midi_file" ]; then
            echo -e "${RED}Downloaded MIDI file is empty. Using backup local file...${NC}"
            # Create a simple local MIDI file if download fails
            cat > "/tmp/backup.mid" << 'EOF'
MThd      MTrk    ÿQ ÿX ÿY  À °d ±P ²d ³P ´d µP ¶d ·P À °d ±P ²d ³P >c Ec Jc >c Ec Jc Ac Ec Hc Ac Ec Hc @c Ec Hc @c Ec Hc >c Ec Jc >c Ec Jc Ac Ec Jc Ac Ec Jc Cc Ec Jc ÿ/
EOF
            midi_file="backup.mid"
        fi
        
        echo -e "${GREEN}Starting Top Gun theme music...${NC}"
        # Try different TiMidity options for better compatibility
        if timidity -idq "/tmp/$midi_file" -Os -o /tmp/timidity.output &>/dev/null & then
            MUSIC_PID=$!
            echo -e "${GREEN}Music playback started.${NC}"
        elif timidity "/tmp/$midi_file" -Os -iA &>/dev/null & then
            MUSIC_PID=$!
            echo -e "${GREEN}Music playback started (alternate mode).${NC}"
        elif timidity "/tmp/$midi_file" &>/dev/null & then
            MUSIC_PID=$!
            echo -e "${GREEN}Music playback started (basic mode).${NC}"
        else
            echo -e "${RED}Failed to play MIDI file. Music will be disabled.${NC}"
            PLAY_MUSIC=false
            return 1
        fi
        
        # Register cleanup function to stop music when script ends
        trap stop_music EXIT INT TERM
    fi
}

# Function to stop music
stop_music() {
    if [ -n "$MUSIC_PID" ]; then
        echo -e "${YELLOW}Stopping music...${NC}"
        kill $MUSIC_PID 2>/dev/null || true
    fi
}

# Banner
echo -e "${BLUE}"
cat << "EOF"

██╗   ██╗ ██████╗ ██████╗  ██████╗
██║   ██║██╔════╝ ██╔══██╗██╔════╝
██║   ██║██║  ███╗██████╔╝██║     
██║   ██║██║   ██║██╔══██╗██║     
╚██████╔╝╚██████╔╝██║  ██║╚██████╗
 ╚═════╝  ╚═════╝ ╚═╝  ╚═╝ ╚═════╝
         by final

EOF
echo -e "${GREEN}[ POWERED BY TOP GUN TECHNOLOGY ]${NC}"
echo -e "${YELLOW}----------------------------------------------------------------------${NC}"
echo ""

# Password protection
echo -e "${YELLOW}Password required to continue:${NC}"
read -s AUTH_PASSWORD
echo ""

# Verify password
if [ "$AUTH_PASSWORD" != "werds" ]; then
    echo -e "${RED}Incorrect password. Exiting.${NC}"
    exit 1
fi

echo -e "${GREEN}Password accepted. Proceeding...${NC}"

# Check dependencies and prepare music
check_dependencies

# Try to play music right away if TiMidity is available
if [ "$PLAY_MUSIC" = true ]; then
    # Try primary source first
    if ! play_music "$TOP_GUN_MIDI"; then
        echo -e "${YELLOW}Trying backup MIDI source...${NC}"
        if ! play_music "$BACKUP_MIDI_1"; then
            echo -e "${YELLOW}Trying second backup MIDI source...${NC}"
            if ! play_music "$BACKUP_MIDI_2"; then
                echo -e "${RED}All music sources failed. Proceeding without music.${NC}"
                PLAY_MUSIC=false
            fi
        fi
    fi
    
    # Pause briefly to let music start
    sleep 1
fi

# Detect current directory and files
CURRENT_DIR=$(pwd)
FOLDER_NAME=$(basename "$CURRENT_DIR")
echo -e "${CYAN}Current project folder:${NC} $FOLDER_NAME"

# Check if files exist in the current directory
FILE_COUNT=$(find . -maxdepth 1 -type f | wc -l)
if [ "$FILE_COUNT" -eq 0 ]; then
    echo -e "${RED}No files found in current directory!${NC}"
    echo -e "Please run this script in a folder containing your project files."
    exit 1
fi

echo -e "${GREEN}Found $FILE_COUNT files in current directory.${NC}"

# Check for README.md file
if [ ! -f "README.md" ] && [ ! -f "readme.md" ]; then
    echo -e "${YELLOW}No README.md file found. Creating a minimal one...${NC}"
    
    # Prompt for repository name
    echo -e "${CYAN}Enter repository name:${NC} (default: $FOLDER_NAME)"
    read REPO_NAME
    
    if [ -z "$REPO_NAME" ]; then
        REPO_NAME="$FOLDER_NAME"
    fi
    
    # Prompt for repository description
    echo -e "${CYAN}Enter repository description:${NC}"
    read REPO_DESC
    
    # Create a minimal README.md
    echo "# $REPO_NAME" > README.md
    echo "" >> README.md
    echo "$REPO_DESC" >> README.md
    
    echo -e "${GREEN}Created basic README.md file.${NC}"
else
    # Parse the README.md file
    if [ -f "README.md" ]; then
        README_FILE="README.md"
    else
        README_FILE="readme.md"
    fi
    
    echo -e "${GREEN}Found README.md file. Parsing for project details...${NC}"
    
    # Try to extract the repository name from the first heading
    REPO_NAME=$(grep -m 1 '^# ' "$README_FILE" | sed 's/^# //')
    
    # If no heading found, use folder name
    if [ -z "$REPO_NAME" ]; then
        REPO_NAME="$FOLDER_NAME"
    fi
    
    # Try to extract description from the first paragraph after the heading
    REPO_DESC=$(sed -n '/^# /,/^$/p' "$README_FILE" | grep -v '^# ' | grep -v '^$' | head -1)
    
    # If no description found, extract any paragraph
    if [ -z "$REPO_DESC" ]; then
        REPO_DESC=$(grep -v '^#' "$README_FILE" | grep -v '^$' | head -1)
    fi
    
    # If still no description, ask user
    if [ -z "$REPO_DESC" ]; then
        echo -e "${YELLOW}No clear description found in README.md.${NC}"
        echo -e "${CYAN}Enter repository description:${NC}"
        read REPO_DESC
    fi
fi

# Confirm repository details
echo -e "${YELLOW}======= Repository Details =======${NC}"
echo -e "Name: ${CYAN}$REPO_NAME${NC}"
echo -e "Description: ${CYAN}$REPO_DESC${NC}"
echo -e "${YELLOW}=================================${NC}"
echo ""

echo -e "${CYAN}Do you want to use these details? (y/n)${NC}"
read CONFIRM

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo -e "${CYAN}Enter repository name:${NC} (default: $REPO_NAME)"
    read NEW_REPO_NAME
    
    if [ -n "$NEW_REPO_NAME" ]; then
        REPO_NAME="$NEW_REPO_NAME"
    fi
    
    echo -e "${CYAN}Enter repository description:${NC} (default: current)"
    read NEW_REPO_DESC
    
    if [ -n "$NEW_REPO_DESC" ]; then
        REPO_DESC="$NEW_REPO_DESC"
    fi
    
    echo -e "${GREEN}Updated repository details.${NC}"
fi

# Check for existing git repository
if [ -d ".git" ]; then
    echo -e "${YELLOW}Existing git repository found.${NC}"
    
    # Check if there is a remote already
    REMOTE_URL=$(git config --get remote.origin.url)
    
    if [ -n "$REMOTE_URL" ]; then
        echo -e "${YELLOW}Remote repository already configured: $REMOTE_URL${NC}"
        echo -e "${CYAN}Do you want to overwrite this with a new GitHub repository? (y/n)${NC}"
        read OVERWRITE
        
        if [[ ! "$OVERWRITE" =~ ^[Yy]$ ]]; then
            echo -e "${GREEN}Keeping existing remote configuration.${NC}"
            exit 0
        else
            echo -e "${YELLOW}Removing existing remote...${NC}"
            git remote remove origin
        fi
    fi
else
    echo -e "${YELLOW}Initializing new git repository...${NC}"
    git init
    # Create .gitignore if it doesn't exist
    if [ ! -f ".gitignore" ]; then
        echo -e "${YELLOW}Creating .gitignore file...${NC}"
        cat > ".gitignore" << 'EOF'
# Logs
logs
*.log

# Dependency directories
node_modules/
jspm_packages/

# Editor directories and files
.idea
.vscode
*.swp
*.swo
.DS_Store
EOF
    fi
fi

# Add all files to git
echo -e "${YELLOW}Adding files to git...${NC}"
git add .

# Configure git user info (using GitHub CLI to get user info)
USER_INFO=$(gh api user)
USER_NAME=$(echo "$USER_INFO" | grep -o '"name": *"[^"]*"' | head -1 | sed 's/"name": *"\(.*\)"/\1/')
USER_EMAIL=$(gh api user/emails | grep -o '"email": *"[^"]*"' | head -1 | sed 's/"email": *"\(.*\)"/\1/')

if [ -n "$USER_NAME" ]; then
    git config --local user.name "$USER_NAME"
else
    git config --local user.name "heyfinal"
fi

if [ -n "$USER_EMAIL" ]; then
    git config --local user.email "$USER_EMAIL"
else
    git config --local user.email "github@heyfinal.com"
fi

# Commit if there are changes
if git diff --staged --quiet; then
    echo -e "${YELLOW}No changes to commit.${NC}"
else
    echo -e "${YELLOW}Committing changes...${NC}"
    git commit -m "Initial commit: $REPO_NAME"
fi

# Create a GitHub repository using GitHub CLI
echo -e "${YELLOW}Creating GitHub repository: $REPO_NAME${NC}"

# Check if repository already exists
if gh repo view "heyfinal/$REPO_NAME" &> /dev/null; then
    echo -e "${YELLOW}Repository already exists. Using existing repository.${NC}"
else
    # Create the repository
    if ! gh repo create "$REPO_NAME" --public --description "$REPO_DESC" --source=. --remote=origin; then
        echo -e "${RED}Failed to create repository. Please check your GitHub CLI authentication.${NC}"
        echo -e "${YELLOW}Run 'gh auth login' to re-authenticate.${NC}"
        exit 1
    else
        echo -e "${GREEN}Repository created successfully.${NC}"
    fi
fi

# Push the repository
echo -e "${YELLOW}Pushing to GitHub...${NC}"
if ! git push -u origin HEAD; then
    echo -e "${RED}Failed to push to GitHub. Please check your connection and authentication.${NC}"
    exit 1
fi

echo -e "${GREEN}Successfully pushed to GitHub repository!${NC}"
echo -e "${YELLOW}Repository URL: ${NC}https://github.com/heyfinal/$REPO_NAME"

# Check if this is a script that could be installed via curl | bash
SCRIPT_FILES=$(find . -maxdepth 1 -name "*.sh" -type f)
if [ -n "$SCRIPT_FILES" ]; then
    MAIN_SCRIPT=$(echo "$SCRIPT_FILES" | head -1)
    MAIN_SCRIPT=${MAIN_SCRIPT:2} # Remove the './' prefix
    
    echo -e "${YELLOW}Detected possible installation script: $MAIN_SCRIPT${NC}"
    echo -e "${CYAN}Generate one-liner installation command? (y/n)${NC}"
    read GENERATE_ONELINER
    
    if [[ "$GENERATE_ONELINER" =~ ^[Yy]$ ]]; then
        ONELINER="curl -sSL https://raw.githubusercontent.com/heyfinal/$REPO_NAME/main/$MAIN_SCRIPT | bash"
        echo -e "${GREEN}Installation one-liner:${NC}"
        echo -e "${CYAN}$ONELINER${NC}"
        
        # Update README.md with one-liner if it doesn't already have it
        if ! grep -q "curl -sSL.*$REPO_NAME" README.md; then
            echo -e "${YELLOW}Adding one-liner to README.md...${NC}"
            
            # Find an appropriate place to add the one-liner
            if grep -q "## Installation" README.md; then
                # Add after installation heading
                sed -i '/## Installation/a \\\n```bash\n'"$ONELINER"'\n```\n' README.md
            elif grep -q "# Installation" README.md; then
                # Add after installation heading
                sed -i '/# Installation/a \\\n```bash\n'"$ONELINER"'\n```\n' README.md
            else
                # Add at the end
                echo -e "\n## Installation\n\n```bash\n$ONELINER\n```" >> README.md
            fi
            
            # Commit and push the updated README
            git add README.md
            git commit -m "Add installation one-liner to README"
            git push
        fi
    fi
fi

# Stop music if it's playing 
stop_music

echo -e "${GREEN}=== Repository Setup Complete! ===${NC}"
echo -e "Your repository is now available at: ${CYAN}https://github.com/heyfinal/$REPO_NAME${NC}"

echo -e "${MAGENTA}Thank you for using UGRC!${NC}"
