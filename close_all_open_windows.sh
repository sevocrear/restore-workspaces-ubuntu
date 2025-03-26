FILTER=$1
if [ -z "$FILTER" ]; then
  FILTER=""
fi

wmctrl -l | grep $FILTER | grep -ve "restore-workspaces-ubuntu" |  awk '{ print $1 }' | xargs -I{} wmctrl -ic {}