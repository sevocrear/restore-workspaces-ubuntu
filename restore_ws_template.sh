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

    # Parse trailing geometry/workspace/repo from the argument list.
    # Call format (backwards-compatible):
    #   open_and_move app_cmd title1 [title2 ...] workspace x y width height repo
    local args=("$@")
    local argc=${#args[@]}

    if [ "$argc" -lt 7 ]; then
        echo -e "${RED}open_and_move: not enough arguments (got $argc, expected at least 7).${NC}"
        return 1
    fi

    local workspace_index=$((argc-6))
    local x_index=$((argc-5))
    local y_index=$((argc-4))
    local width_index=$((argc-3))
    local height_index=$((argc-2))
    local repo_index=$((argc-1))

    local workspace=${args[$workspace_index]}
    local x=${args[$x_index]}
    local y=${args[$y_index]}
    local width=${args[$width_index]}
    local height=${args[$height_index]}
    local repo=${args[$repo_index]}

    # Titles are everything between app_cmd and the trailing six fields.
    local titles=()
    local i
    for ((i=0; i<workspace_index; i++)); do
        titles+=("${args[$i]}")
    done

    # Example args: "$IDL --new-window --folder-uri vscode-remote://ssh-remote+$MACHINE-ad10/home/ilia.sevostianov/adcu-upload-tool" "adcu-upload-tool" $IDL_TITLE "SSH" 7 $X $Y $WIDTH $HEIGHT "git@gitlab.int.e-kama.com:adas/adcu-upload-tool.git"
    # Firstly, if we connect to ssh, check if there is a repo there. If not, git clone it on remote machine.

    if [[ "$app_cmd" == *"ssh-remote"* && -n "$repo" ]]; then
        echo -e "${YELLOW}Checking if repo exists on remote machine...${NC}"
        echo -e "${YELLOW}App command: $app_cmd${NC}"
        echo -e "${YELLOW}Repo: $repo${NC}"
        # TODO: extract machine from app_cmd
        REMOTE_MACHINE=$(echo "$app_cmd" | grep -oP 'ssh-remote\+\K[^/]+')
        echo -e "${YELLOW}Machine: $REMOTE_MACHINE${NC}"
        ssh -A "$REMOTE_MACHINE" "if [ -d $repo ]; then echo 'Repo exists'; else echo 'Repo does not exist. Trying to clone...'; git clone $repo; fi"
    fi

    if [ "${DEBUG:-0}" -ne 0 ]; then
        echo -e "${YELLOW}open_and_move: app_cmd='$app_cmd' workspace=$workspace x=$x y=$y width=$width height=$height repo='$repo' titles=(${titles[*]})${NC}"
    fi

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

    # Find window ID by its title, with timeout
    local max_wait_seconds=${OPEN_AND_MOVE_MAX_WAIT:-30}
    local waited=0
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
        waited=$((waited+1))
        if [ "$waited" -ge "$max_wait_seconds" ]; then
            echo -e "${RED}Timed out after ${max_wait_seconds}s waiting for window with titles (${titles[@]}).${NC}"
            return 1
        fi
    done

    # Move and resize the window with retries
    max_retries=3
    retry=0
    while [ $retry -lt $max_retries ]; do
        if [ "$workspace" -ge 0 ]; then
            echo -e "${YELLOW}Moving window $win_id to workspace $workspace${NC}"
            wmctrl -ir "$win_id" -t "$workspace"
        else
            # workspace == -1 is a special value in this project meaning:
            # "keep current workspace but move to the right display".
            echo -e "${YELLOW}Leaving window $win_id on its current workspace (special workspace=-1), only moving/resizing.${NC}"
        fi
        wmctrl -ir "$win_id" -e 0,"$x","$y","$width","$height"
        sleep 0.7

        # Check if window is on the correct workspace (when workspace >= 0).
        # Geometry can differ slightly because of decorations, panels,
        # scaling, etc., so we don't enforce exact x/y/width/height matches.
        if [ "$workspace" -ge 0 ]; then
            current_ws=$(wmctrl -l | awk -v id="$win_id" '$1==id {print $2}')
            if [ "$current_ws" = "$workspace" ]; then
                if [ "${DEBUG:-0}" -ne 0 ]; then
                    geometry=$(xwininfo -id "$win_id" 2>/dev/null | grep -E 'Absolute upper-left X|Absolute upper-left Y|Width|Height' || true)
                    echo -e "${GREEN}Window $win_id is on workspace $workspace. Geometry (for debug only):${NC}"
                    echo "$geometry"
                else
                    echo -e "${GREEN}Window $win_id moved to workspace $workspace.${NC}"
                fi
                break
            fi
        else
            # For workspace=-1 (right display case) we don't validate workspace,
            # only consider the move successful after applying geometry.
            if [ "${DEBUG:-0}" -ne 0 ]; then
                geometry=$(xwininfo -id "$win_id" 2>/dev/null | grep -E 'Absolute upper-left X|Absolute upper-left Y|Width|Height' || true)
                echo -e "${GREEN}Window $win_id moved/resized on its current workspace (workspace=-1 case). Geometry (for debug only):${NC}"
                echo "$geometry"
            else
                echo -e "${GREEN}Window $win_id moved/resized on its current workspace (workspace=-1 case).${NC}"
            fi
            break
        fi
        retry=$((retry+1))
        echo -e "${YELLOW}Retrying move/resize for window $win_id ($retry/$max_retries)...${NC}"
    done

    if [ $retry -eq $max_retries ]; then
        echo -e "${RED}Failed to move/resize window $win_id after $max_retries attempts.${NC}"
    fi
}

X=132 # X offset wrt to the top tray
Y=64 # Y offset wrt to the left tab

W_LEFT_DISPLAY=2560
H_LEFT_DISPLAY=1440
WIDTH=$((W_LEFT_DISPLAY-X))

HEIGHT=$((H_LEFT_DISPLAY-Y))

X_RIGHT_DISPLAY=5120
Y_RIGHT_DISPLAY=0
WIDTH_RIGHT_DISPLAY=1920
HEIGHT_RIGHT_DISPLAY=1080

echo -e "${YELLOW}WIDTH: $WIDTH${NC}"
echo -e "${YELLOW}HEIGHT: $HEIGHT${NC}"


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

