FILTER=$1
if [ -z "$FILTER" ]; then
  wmctrl -l | grep -ve "restore-workspaces-ubuntu" |  awk '{ print $1 }' | xargs -I{} wmctrl -ic {}
  exit
fi

wmctrl -l | grep $FILTER | grep -ve "restore-workspaces-ubuntu" |  awk '{ print $1 }' | xargs -I{} wmctrl -ic {}