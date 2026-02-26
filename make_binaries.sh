#! /bin/bash

set -e

sudo chmod a+x ./*.sh

# Remove old binaries
sudo rm -f /usr/bin/restore_ws_template.sh /usr/bin/restore_ws_work /usr/bin/restore_ws_freelance /usr/bin/close_all_open_windows | true

# Install scripts to /usr/bin. Each restore_ws_*.sh script sources
# restore_ws_template.sh relative to its own location, so copying all of
# them into the same directory keeps things working both from the repo
# and from /usr/bin.
sudo cp ./restore_ws_template.sh /usr/bin/restore_ws_template.sh
sudo cp ./restore_ws_work.sh /usr/bin/restore_ws_work
sudo cp ./restore_ws_freelance.sh /usr/bin/restore_ws_freelance
sudo cp ./close_all_open_windows.sh /usr/bin/close_all_open_windows

echo "Binaries installed: restore_ws_work, restore_ws_freelance, close_all_open_windows"