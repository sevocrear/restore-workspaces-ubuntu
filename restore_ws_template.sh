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
open_and_move() {
    local app_cmd=$1
    shift
    local titles=("$@")
    local workspace=${titles[-6]}
    local x=${titles[-5]}
    local y=${titles[-4]}
    local width=${titles[-3]}
    local height=${titles[-2]}
    local repo=${titles[-1]}
    # Example args: "$IDL --new-window --folder-uri vscode-remote://ssh-remote+$MACHINE-ad10/home/ilia.sevostianov/adcu-upload-tool" "adcu-upload-tool" $IDL_TITLE "SSH" 7 $X $Y $WIDTH $HEIGHT "git@gitlab.int.e-kama.com:adas/adcu-upload-tool.git"
    # Firsty, if we connect to ssh, check if there is a repo there. If not, git clone it on remote machine.

    if [[ "$app_cmd" == *"ssh-remote"* ]]; then
        echo -e "${YELLOW}Checking if repo exists on remote machine...${NC}"
        echo -e "${YELLOW}App command: $app_cmd${NC}"
        echo -e "${YELLOW}Repo: $repo${NC}"
        # TODO: extract machine from app_cmd
        REMOTE_MACHINE=$(echo "$app_cmd" | grep -oP 'ssh-remote\+\K[^/]+')
        echo -e "${YELLOW}Machine: $REMOTE_MACHINE${NC}"
        ssh -A $REMOTE_MACHINE "if [ -d $repo ]; then echo 'Repo exists'; else echo 'Repo does not exist. Trying to clone...'; git clone $repo; fi"
    fi
    # Remove last six elements to keep only titles in the array
    unset 'titles[-1]' 'titles[-1]' 'titles[-1]' 'titles[-1]' 'titles[-1]' 'titles[-1]'

    # Function to check if window exists for given titles
    window_exists() {
        local win_id=""
        local command="wmctrl -l"
        for title in "${titles[@]}"; do
            command+=" | grep -e '$title'"
        done

        # Execute the constructed command
        echo -e "${YELLOW}Executing command: $command${NC}"
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
        echo -e "${GREEN}The window $win_id with all titles (${titles[@]}) exists${NC}"
    else
        # Open application
        echo -e "${YELLOW}Launching command: $app_cmd${NC}"
        $app_cmd &
        sleep 5
    fi

    # Find window ID by its title
    while true; do
        local win_id=""
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

    # Move and resize the window with retries
    max_retries=3
    retry=0
    while [ $retry -lt $max_retries ]; do
        echo -e "${YELLOW}Moving window $win_id to workspace $workspace${NC}"
        wmctrl -ir "$win_id" -t "$workspace"
        wmctrl -ir "$win_id" -e 0,"$x","$y","$width","$height"
        sleep 0.7

        # Check if window is on the correct workspace
        current_ws=$(wmctrl -l | awk -v id="$win_id" '$1==id {print $2}')
        if [ "$current_ws" = "$workspace" ]; then
            # Optionally, check geometry (x, y, width, height)
            geometry=$(xwininfo -id "$win_id" | grep -E 'Absolute upper-left X|Absolute upper-left Y|Width|Height')
            x_ok=$(echo "$geometry" | grep "Absolute upper-left X" | awk '{print $NF}')
            y_ok=$(echo "$geometry" | grep "Absolute upper-left Y" | awk '{print $NF}')
            width_ok=$(echo "$geometry" | grep "Width" | awk '{print $2}')
            height_ok=$(echo "$geometry" | grep "Height" | awk '{print $2}')
            if [ "$x_ok" = "$x" ] && [ "$y_ok" = "$y" ] && [ "$width_ok" = "$width" ] && [ "$height_ok" = "$height" ]; then
                echo -e "${GREEN}Window $win_id successfully moved and resized.${NC}"
                break
            fi
        fi
        retry=$((retry+1))
        echo -e "${YELLOW}Retrying move/resize for window $win_id ($retry/$max_retries)...${NC}"
    done

    if [ $retry -eq $max_retries ]; then
        echo -e "${RED}Failed to move/resize window $win_id after $max_retries attempts.${NC}"
    fi
}

X=132
Y=64
WIDTH=2494
HEIGHT=1408
W_H=2560

# # --------------------- (LOWER Display) -----------------------
# # Example workspace configurations - replace with your own
# open_and_move "true" "Messages" 0 $X $Y $WIDTH $HEIGHT
# open_and_move "true" "Notes" 1 $X $Y $WIDTH $HEIGHT

# open_and_move "$IDL --new-window /path/to/project1" "project1" $IDL_TITLE 2 $X $Y $WIDTH $HEIGHT

# open_and_move "$IDL --new-window --folder-uri vscode-remote://ssh-remote+$MACHINE/home/user/project2" "project2" $IDL_TITLE "SSH" 3 $X $Y $WIDTH $HEIGHT

# open_and_move "$IDL --new-window /path/to/project3" "project3" $IDL_TITLE 4 $X $Y $WIDTH $HEIGHT

# open_and_move "$IDL --new-window --folder-uri vscode-remote://ssh-remote+$MACHINE/home/user/project4" "project4" $IDL_TITLE "SSH" 5 $X $Y $WIDTH $HEIGHT

# open_and_move "$IDL --new-window /path/to/project5" "project5" $IDL_TITLE 6 $X $Y $WIDTH $HEIGHT

# open_and_move "$IDL --new-window /path/to/project6" "project6" $IDL_TITLE 7 $X $Y $WIDTH $HEIGHT

# open_and_move "$IDL --new-window /path/to/project7" "project7" $IDL_TITLE 8 $X $Y $WIDTH $HEIGHT

# open_and_move "browser example.com &" "Browser" -1 $W_H 0 1920 1080

# # Add more as needed.

# echo -e "${GREEN}Workspaces have been restored. Check if all windows are correctly positioned.${NC}"

