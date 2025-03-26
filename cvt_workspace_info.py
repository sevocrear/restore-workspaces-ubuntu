import json
import re
# open_and_move "code --new-window /home/sevocrear/Documents/CARLA/carla-test/" "carla-test" "Visual Studio Code" 1 0 0 2560 1440

# Load JSON file into a dictionary
with open('workspace_info.json', 'r') as file:
    workspace_info = json.load(file)

# Print or access data
for window in workspace_info:
    workspace_id = window["desktop"]
    x = window["x"]
    y = window["y"]
    width = window["width"]
    height = window["height"]
    title = re.sub(r'[\u200e\u200f\u2066-\u2069]', '', window["title"])
    print(f'open_and_move "code --new-window dir" "{title}" {workspace_id} {x} {y} {width} {height}')