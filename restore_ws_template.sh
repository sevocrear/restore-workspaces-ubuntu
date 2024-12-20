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

        result=$(eval $command | awk '{print $1}')
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


# --------------------- (LOWER Display) -----------------------
## Open Visual Studio Code windows
open_and_move "code --new-window carla" "carla-test" "Visual Studio Code" 1 0 1180 2560 1440
open_and_move "code --new-window dir2" "unified_pipeline" "Visual Studio Code" 2 0 1180 2560 1440
open_and_move "code --new-window dir3" "fpga" "Visual Studio Code" 3 0 1180 2560 1440
open_and_move "code --new-window any_dir_4" "ansible" "Visual Studio Code" 4 0 1180 2560 1440
open_and_move 'code --new-window --folder-uri vscode-remote://ssh-remote+server-vpn/home/vpn/is_temp_dir_3' "is_temp_dir_3" "Visual Studio Code"  5 0 1180 2560 1440
# # Open Obsidian
open_and_move "true" "Obsidian" 0 0 1180 2560 1440
open_and_move "echo telegram" "@sevoc123" 6 0 1180 2560 1440
open_and_move "code --new-window ./restore-workspaces-ubuntu" "restore-workspaces-ubuntu" "Visual Studio Code" 7 0 1180 2560 1440



# --------------------- (UPPER Display) -----------------------
# # Open Yandex Browser windows
open_and_move "yandex-browser --new-window url" "ADAS" "infra" "ansible" 4 0 0 1920 1080
open_and_move "yandex-browser --new-window https://url" "dir4" 3 0 0 1920 1080
open_and_move "yandex-browser --new-window https://url1" "youtube" 2 0 0 1920 1080
open_and_move "yandex-browser --new-window http://url2" "g4f" 0 0 0 1920 1080
open_and_move "yandex-browser --new-window https://url3" "fun" 5 0 0 1920 1080
# Open CarlaUE4 (assuming it's a terminal app or game engine window)
open_and_move "true" "CarlaUE4" 1 0 0 1920 1080
# # Open Calendar in Microsoft Teams
open_and_move "teams" "Microsoft Teams" 6 0 0 1920 1080
open_and_move "yandex-browser --new-window https://github.com/sevocrear/restore-workspaces-ubuntu" "Restore Your Ubuntu Workspace with ease" 7 0 0 1920 1080


# Add more as needed.


echo -e "${GREEN}Workspaces have been restored. Check if all windows are correctly positioned.${NC}"
