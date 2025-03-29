#!/bin/bash

# This bash script setups the workspaces as you need!
# It opens desired apps via CLI and moves them into the desired workspace
# The template is:
# open_and_move app_cmd expected_title1 title2 ... workspace_num x_start y_start width height
# It finds the certain app by looking for expected_title

# NOTION: Workspaces number should go in the ascending mode (to be created one by one) starting from 0.

# NOTION: To start with, set up your own workspaces manually. After, run get_ws.sh script. It will export your workspace in JSON format.
## After that, go to LLM (Claude, Ollama, ChatGPT) and write next prompt:

## """ here is the contents of workspace_info.json:
## """ <your JSON contents>
## """ Adjust the next bash script 'open_and_move' commands accordingly to recreate my workspaces.
## """ <THIS BASH SCRIPT code >

## Now, adjust them manually as LLM Agent could be wrong and be happy! YOU ALL SET UP!


# Function to open and move applications
# Color codes
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
NC='\033[0m'  # No Color

# Set default values if not provided via args
IDL=${1:-"cursor"} # core or cursor
MACHINE=${2:-"carbon-ad10"} # specify remote ego

# Conditional assignment of IDL_TITLE based on the value of IDL
if [ "$IDL" = "code" ]; then
    IDL_TITLE="Visual Studio Code"
elif [ "$IDL" = "cursor" ]; then
    IDL_TITLE="Cursor"
else
    IDL_TITLE="Unknown IDE"
fi
# Output the result
echo "IDL_TITLE is set to: $IDL_TITLE"

# Ensure wmctrl is installed
if ! command -v wmctrl &> /dev/null; then
    echo -e "${RED}wmctrl could not be found. Please install it using: sudo apt install wmctrl${NC}"
    exit
fi

# Function to open and move applications
open_and_move() {
    local app_cmd=$1
    shift
    local titles=("$@")
    local workspace=${titles[-5]}
    local x=${titles[-4]}
    local y=${titles[-3]}
    local width=${titles[-2]}
    local height=${titles[-1]}
    # Remove last five elements to keep only titles in the array
    unset 'titles[-1]' 'titles[-1]' 'titles[-1]' 'titles[-1]' 'titles[-1]'

    # Function to check if window exists for given titles
    window_exists() {
        local command="wmctrl -l"
        for title in "${titles[@]}"; do
            command+=" | grep -e '$title'"
        done

        # Execute the constructed command
        result=$(eval $command | awk '{print $1}')
        if win_id=$result; then
            if [ -n "$win_id" ]; then
                return 0
            fi
        fi
        return 1
    }

    # Check if any window exists
    if window_exists; then
        echo -e "${GREEN}A window $win_id with all titles (${titles[@]}) exists${NC}"
    else
        # Open application
        echo -e "${YELLOW}Launching command: $app_cmd${NC}"
        $app_cmd &
        sleep 5
    fi

    # Find window ID by its title
    local win_id=""
    while true; do
        local command="wmctrl -l"
        for title in "${titles[@]}"; do
            command+=" | grep -e '$title'"
        done

        # Execute the constructed command
        result=$(eval $command | awk '{print $1}')
        # Ensure to consider the case where titles might not directly follow each other
        if win_id=$result; then
            if [ -n "$win_id" ]; then
                    break 2
            fi
        fi
        echo -e "${BLUE}Waiting for window with titles (${titles[@]}) to appear...${NC}"
        sleep 1
    done

    # Move and resize the window
    wmctrl -ir "$win_id" -t "$workspace"
    wmctrl -ir "$win_id" -e 0,"$x","$y","$width","$height"

    echo -e "${YELLOW}Window $win_id moved to workspace $workspace${NC}"
}

X=132
Y=64
WIDTH=2494
HEIGHT=1408
W_H=2560

# --------------------- (LOWER Display) -----------------------
open_and_move "true" "Saved Messages" 0 $X $Y $WIDTH $HEIGHT
open_and_move "true" "Obsidian" 1 $X $Y $WIDTH $HEIGHT

open_and_move "$IDL --new-window --folder-uri vscode-remote://ssh-remote+ws/data/dir" "dir" $IDL_TITLE "SSH" 7 $X $Y $WIDTH $HEIGHT

open_and_move "$IDL --new-window /media/sevocrear/data/Crypto_Dir/ATOM/code/restore-workspaces-ubuntu" "restore-workspaces-ubuntu" $IDL_TITLE 8 $X $Y $WIDTH $HEIGHT

open_and_move "yandex-browser" "" -1 $W_H 0 1920 1080

# Add more as needed.


echo -e "${GREEN}Workspaces have been restored. Check if all windows are correctly positioned.${NC}"

