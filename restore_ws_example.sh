#!/bin/bash

current_dir=$(pwd)
source $current_dir/restore_ws_template.sh

MACHINE="Remote-Car"
IDL_TITLE="cursor"
IDL="cursor"
# Read IDL_TITLE from the first argument
IDL_TITLE=$1
if [ -z "$IDL_TITLE" ]; then
    IDL_TITLE="Cursor"
    IDL="cursor"
fi

# READ MACHINE from the second argument
MACHINE=$2
if [ -z "$MACHINE" ]; then
    MACHINE="Remote-Car"
fi

# --------------------- (LOWER Display) -----------------------
open_and_move "true" "Saved Messages" 0 $X $Y $WIDTH $HEIGHT
open_and_move "true" "Obsidian" 1 $X $Y $WIDTH $HEIGHT

open_and_move "$IDL --new-window --folder-uri vscode-remote://ssh-remote+$MACHINE/root/budget_web_app_tg" "budget_web_app_tg"  "SSH" $IDL_TITLE 3 $X $Y $WIDTH $HEIGHT



open_and_move "$IDL --new-window /media/sevocrear/data/Crypto_Dir/ATOM/code/restore-workspaces-ubuntu" "restore-workspaces-ubuntu" $IDL_TITLE 4 $X $Y $WIDTH $HEIGHT

open_and_move "yandex-browser ya.ru" "Яндекс" -1 $W_H 0 1920 1080

# Add more as needed.


echo -e "${GREEN}Workspaces have been restored. Check if all windows are correctly positioned.${NC}"

