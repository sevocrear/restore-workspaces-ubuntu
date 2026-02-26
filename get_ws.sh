#!/bin/bash

# Get the list of windows with their workspace numbers and, when possible,
# the owning process ID, its current working directory (cwd), and for
# Cursor/VSCode-like IDE windows, a best-effort guess of the project path
# based on their storage.json.
#
# Runtime restore logic should still treat paths in restore_ws_*.sh as the
# single source of truth; this script is an aid for generating/updating them.

cursor_storage="$HOME/.config/Cursor/User/globalStorage/storage.json"
cursor_projects=""

if [ -f "$cursor_storage" ]; then
  # Extract all relevant folder URIs Cursor knows about:
  # - backupWorkspaces.folders[].folderUri
  # - windowsState.openedWindows[].folder
  cursor_projects=$(jq -r '
    [
      (.backupWorkspaces.folders[]? | .folderUri?),
      (.windowsState.openedWindows[]? | .folder?)
    ]
    | .[]
    | select(. != null)
  ' "$cursor_storage" 2>/dev/null | sed 's#^file://##')
fi

tmp_file=$(mktemp)

while read -r id desktop x y width height host title; do
  # title may contain spaces; 'read' puts the rest of the line into $title.
  # Get PID via X11 property (may be empty for some windows).
  pid=$(xprop -id "$id" _NET_WM_PID 2>/dev/null | awk -F ' = ' '{print $2}')

  cwd=""
  if [[ "$pid" =~ ^[0-9]+$ ]] && [ -e "/proc/$pid/cwd" ]; then
    cwd=$(readlink -f "/proc/$pid/cwd" 2>/dev/null || echo "")
  fi

  # For Cursor/VSCode-like IDE windows, try to guess the project path by
  # matching the folder basename from storage.json against the window title.
  project_path=""
  if [[ "$title" == *"Cursor"* || "$title" == *"Visual Studio Code"* || "$title" == *"Code -" ]]; then
    if [ -n "$cursor_projects" ]; then
      while read -r uri; do
        [ -z "$uri" ] && continue
        path="$uri"
        base="$(basename "$path")"
        if [[ "$title" == *"$base"* ]]; then
          project_path="$path"
          break
        fi
      done <<< "$cursor_projects"
    fi
  fi

  jq -n \
    --arg id "$id" \
    --argjson desktop "$desktop" \
    --argjson x "$x" \
    --argjson y "$y" \
    --argjson width "$width" \
    --argjson height "$height" \
    --arg host "$host" \
    --arg title "$title" \
    --arg pid "$pid" \
    --arg cwd "$cwd" \
    --arg project_path "$project_path" \
    '{id:$id, desktop:$desktop, x:$x, y:$y, width:$width, height:$height, host:$host, title:$title, pid:($pid|tonumber?), cwd:$cwd, projectPath:$project_path}' \
    >> "$tmp_file"
done < <(wmctrl -lG)

jq -s . "$tmp_file" > workspace_info.json
rm -f "$tmp_file"

echo "Workspace information saved to workspace_info.json"
