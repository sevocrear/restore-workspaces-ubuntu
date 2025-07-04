
FILTER="restore-workspaces-ubuntu -ve 'Ilia Sevostianov' -ve Obsidian -ve Yandex"
wmctrl -l |  grep -ve restore-workspaces-ubuntu -ve 'Ilia Sevostianov' -ve Obsidian -ve Yandex |  awk '{ print $1 }' | xargs -I{} wmctrl -ic {}
