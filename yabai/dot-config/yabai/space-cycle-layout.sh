stype=$(yabai -m query --spaces --space mouse | jq '.type' | xargs)

if [[ $stype == "bsp" ]]; then
    yabai -m space mouse --layout stack
else
    yabai -m space mouse --layout bsp
fi
