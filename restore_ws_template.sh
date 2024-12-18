#!/bin/bash

# This bash script setups the workspaces as you need!
# It opens desired apps via CLI and moves them into the desired workspace
# The template is:
# open_and_move app_cmd expected_title workspace_num x_start y_start width height
# It finds the certain app by looking for expected_title

# NOTION: Workspaces number should go in the ascending mode (to be created one by one) starting from 0.

# NOTION: To start with, set up your own workspaces manually. After, run get_ws.sh script. It will export your workspace in JSON format.
## After that, go to LLM (Claude, Ollama, ChatGPT) and write next prompt:

## """ here is the contents of workspace_info.json:
## """ <your JSON contents>
## """ Adjust the next bash script 'open_and_move' commands accordingly to recreate my workspaces.
## """ <THIS BASH SCRIPT code >

## Now, adjust them manually as LLM Agent could be wrong and be happy! YOU ALL SET UP!

# Ensure wmctrl is installed
if ! command -v wmctrl &> /dev/null; then
    echo "wmctrl could not be found. Please install it using: sudo apt install wmctrl"
    exit
fi

# Function to open and move applications
open_and_move() {
    local app_cmd=$1
    local expected_title=$2
    local workspace=$3
    local x=$4
    local y=$5
    local width=$6
    local height=$7

    # Check if window exists
    win_id=$(wmctrl -l | grep "$expected_title" | awk '{print $1}')
    if [ -n "$win_id" ]; then
        echo "$expected_title" window already exists
    else
        # Open application
        echo launched cmd { $app_cmd }
        $app_cmd &
        # Wait for the window to open
        sleep 5
    fi

    # Find window ID by its title
    local win_id
    while true; do
        win_id=$(wmctrl -l | grep "$expected_title" | awk '{print $1}')
        if [ -n "$win_id" ]; then
            break
        fi
        echo "Waiting for $expected_title to appear..."
        sleep 1
    done

    # Move and resize the window
    wmctrl -ir "$win_id" -t "$workspace"
    wmctrl -ir "$win_id" -e 0,"$x","$y","$width","$height"

    echo "$expected_title moved to workspace $workspace"
}

# Example calls for each listed window in your JSON

# --------------------- (LOWER Display) -----------------------
## Open Visual Studio Code windows
open_and_move "code --new-window /home/user/dir2/" "dir2" 0 1 1155 2560 1403
open_and_move 'code --new-window --folder-uri vscode-remote://ssh-remote+server/home/server/dir3' "dir3" 1 1 1155 2560 1403
# # Open Obsidian
open_and_move "true" "Obsidian" 2 1 1155 2560 1403 # as this app couldn't be run via CLI, we use "true" as a command (You need to open it manually before running this script)



# --------------------- (UPPER Display) -----------------------
# # Open Yandex Browser windows
open_and_move "yandex-browser --new-window https://gitlab.com" "Gitlab" 0 752 54 1848 1053
# # Open Calendar in Microsoft Teams
open_and_move "teams" "Microsoft Teams" 1 752 54 1848 1053


# Add more as needed.

echo "Workspaces have been restored. Check if all windows are correctly positioned."