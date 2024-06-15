#!/bin/bash

sketchybar --add item calendar right \
           --set calendar update_freq=30 \
	   		  icon.font.style=Bold \
                          script="$CONFIG_DIR/plugins/clock.sh"
