#!/bin/bash

# UGRC - Universal GitHub Repository Creator
# Created by Claude for heyfinal
# 
# FEATURES:
# - Password protected script launch
# - Epic Top Gun theme music during execution
# - Automatically detects project files in current directory
# - Parses README.md for repository name and description
# - Creates and populates GitHub repository
# - Generates one-liner installation command if applicable

# GitHub credentials - SECURED BY PASSWORD
GITHUB_USERNAME="heyfinal"
GITHUB_PASSWORD="Littles2023!"

# MIDI music source (Top Gun Anthem)
TOP_GUN_MIDI="https://bitmidi.com/uploads/73426.mid"

# Text colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to check and install required dependencies
check_dependencies() {
    echo -e "${YELLOW}Checking for required dependencies...${NC}"
    
    # Check for timidity (MIDI player)
    if ! command -v timidity &> /dev/null; then
        echo -e "${YELLOW}TiMidity++ (MIDI player) is not installed.${NC}"
        echo -e "Would you like to install it to enable the epic Top Gun theme? (y/n)"
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
    else
        PLAY_MUSIC=true
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
        
        echo -e "${GREEN}Starting Top Gun theme music...${NC}"
        timidity "/tmp/$midi_file" -Os -iA &
        MUSIC_PID=$!
        
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

# Check dependencies and prepare music
check_dependencies
if [ "$PLAY_MUSIC" = true ]; then
    play_music "$TOP_GUN_MIDI"
fi

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

# Configure git 
git config --local user.name "$GITHUB_USERNAME"
git config --local user.email "github@heyfinal.com"

# Commit if there are changes
if git diff --staged --quiet; then
    echo -e "${YELLOW}No changes to commit.${NC}"
else
    echo -e "${YELLOW}Committing changes...${NC}"
    git commit -m "Initial commit: $REPO_NAME"
fi

# Create a GitHub repository using the GitHub API with basic auth
echo -e "${YELLOW}Creating GitHub repository: $REPO_NAME${NC}"

# Check if repository already exists
REPO_CHECK=$(curl -s -o /dev/null -w "%{http_code}" -u "$GITHUB_USERNAME:$GITHUB_PASSWORD" \
  "https://api.github.com/repos/$GITHUB_USERNAME/$REPO_NAME")

if [ "$REPO_CHECK" = "200" ]; then
    echo -e "${YELLOW}Repository already exists. Using existing repository.${NC}"
else
    # Create the repository
    REPO_CREATE_RESPONSE=$(curl -s -u "$GITHUB_USERNAME:$GITHUB_PASSWORD" -X POST \
      -H "Accept: application/vnd.github.v3+json" \
      https://api.github.com/user/repos \
      -d "{\"name\":\"$REPO_NAME\",\"description\":\"$REPO_DESC\",\"private\":false}")

    # Check if repo creation was successful
    if [[ "$REPO_CREATE_RESPONSE" == *"Bad credentials"* ]]; then
        echo -e "${RED}Authentication failed. Check your GitHub username and password.${NC}"
        exit 1
    elif [[ "$REPO_CREATE_RESPONSE" != *"html_url"* ]]; then
        echo -e "${RED}Failed to create repository. Error: $REPO_CREATE_RESPONSE${NC}"
        exit 1
    else
        echo -e "${GREEN}Repository created successfully.${NC}"
    fi
fi

# Set the remote URL
git remote add origin "https://$GITHUB_USERNAME:$GITHUB_PASSWORD@github.com/$GITHUB_USERNAME/$REPO_NAME.git"

# Push the repository
echo -e "${YELLOW}Pushing to GitHub...${NC}"
if ! git push -u origin master 2>/dev/null; then
    echo -e "${YELLOW}Trying default branch 'main' instead...${NC}"
    if ! git push -u origin main 2>/dev/null; then
        echo -e "${RED}Failed to push to GitHub.${NC}"
        echo -e "${YELLOW}Pushing to a new branch 'main'...${NC}"
        git checkout -b main
        if ! git push -u origin main; then
            echo -e "${RED}Failed to push to GitHub. Please check your connection and credentials.${NC}"
            exit 1
        fi
    fi
fi

echo -e "${GREEN}Successfully pushed to GitHub repository!${NC}"
echo -e "${YELLOW}Repository URL: ${NC}https://github.com/$GITHUB_USERNAME/$REPO_NAME"

# Check if this is a script that could be installed via curl | bash
SCRIPT_FILES=$(find . -maxdepth 1 -name "*.sh" -type f)
if [ -n "$SCRIPT_FILES" ]; then
    MAIN_SCRIPT=$(echo "$SCRIPT_FILES" | head -1)
    MAIN_SCRIPT=${MAIN_SCRIPT:2} # Remove the './' prefix
    
    echo -e "${YELLOW}Detected possible installation script: $MAIN_SCRIPT${NC}"
    echo -e "${CYAN}Generate one-liner installation command? (y/n)${NC}"
    read GENERATE_ONELINER
    
    if [[ "$GENERATE_ONELINER" =~ ^[Yy]$ ]]; then
        ONELINER="curl -sSL https://raw.githubusercontent.com/$GITHUB_USERNAME/$REPO_NAME/main/$MAIN_SCRIPT | bash"
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

echo -e "${GREEN}=== Repository Setup Complete! ===${NC}"
echo -e "Your repository is now available at: ${CYAN}https://github.com/$GITHUB_USERNAME/$REPO_NAME${NC}"

# Stop music if it's playing 
stop_music

echo -e "${MAGENTA}Thank you for using UGRC!${NC}"
