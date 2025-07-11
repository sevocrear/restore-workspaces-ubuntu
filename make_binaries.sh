#! /bin/bash

sudo chmod a+x *.sh

sudo cp ./restore_ws_template.sh /usr/bin/restore_ws_template.sh

# Find in file current_dir=$(pwd) and replace with current directory
sudo cp ./restore_ws_work.sh /usr/bin/restore_ws_work
sudo sed -i "s|current_dir=$(pwd)|current_dir=/usr/bin/|" /usr/bin/restore_ws_work

sudo cp ./restore_ws_freelance.sh /usr/bin/restore_ws_freelance
sudo sed -i "s|current_dir=$(pwd)|current_dir=/usr/bin/|" /usr/bin/restore_ws_freelance

sudo cp ./close_all_open_windows.sh /usr/bin/close_all_open_windows
